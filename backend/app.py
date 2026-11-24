"""MSW Community API — FastAPI + SQLite.

Run:   .venv/bin/uvicorn app:app --reload --port 8000
Docs:  http://localhost:8000/docs

Auth is a development stub: the app sends the signed-in account id in the
`X-User` header. Replace with real auth (JWT / Google sign-in) before launch.
"""
from __future__ import annotations

import json
import os
import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Optional

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

ROOT = Path(__file__).parent
DB_PATH = Path(os.environ.get("MSW_DB", ROOT / "msw.db"))
SEED_PATH = ROOT / "seed.json"

SCHEMA = """
PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, role TEXT NOT NULL,
  data TEXT NOT NULL DEFAULT '{}', status TEXT NOT NULL DEFAULT 'Active',
  is_admin INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT, author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  data TEXT NOT NULL, likes INTEGER NOT NULL DEFAULT 0, hidden INTEGER NOT NULL DEFAULT 0,
  pinned INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT, post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, text TEXT NOT NULL, time TEXT DEFAULT 'now',
  likes INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS post_likes (post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE, user_id TEXT, PRIMARY KEY (post_id, user_id));
CREATE TABLE IF NOT EXISTS post_saves (post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE, user_id TEXT, PRIMARY KEY (post_id, user_id));
CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL,
  registered INTEGER NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS event_registrations (
  event_id INTEGER REFERENCES events(id) ON DELETE CASCADE, user_id TEXT, team TEXT, track TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (event_id, user_id)
);
CREATE TABLE IF NOT EXISTS announcements (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, title TEXT NOT NULL, body TEXT NOT NULL, organiser TEXT,
  category TEXT, link TEXT, pinned INTEGER NOT NULL DEFAULT 0, time TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS opportunities (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL, applicants INTEGER NOT NULL DEFAULT 0,
  live INTEGER NOT NULL DEFAULT 1, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS applications (
  opportunity_id INTEGER REFERENCES opportunities(id) ON DELETE CASCADE, user_id TEXT, link TEXT, note TEXT,
  status TEXT NOT NULL DEFAULT 'Applied', created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (opportunity_id, user_id)
);
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id TEXT, data TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS submissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE, user_id TEXT,
  repo TEXT, demo TEXT, notes TEXT, shots TEXT DEFAULT '[]', status TEXT NOT NULL DEFAULT 'In review',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS ideas (
  id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, raised REAL NOT NULL DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS idea_decisions (
  idea_id INTEGER REFERENCES ideas(id) ON DELETE CASCADE, user_id TEXT, decision TEXT NOT NULL, amount REAL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (idea_id, user_id)
);
"""

ORG_ACCOUNTS = [
    ("lumen-labs", "Lumen Labs", "company"),
    ("kite-ai", "Kite AI", "company"),
    ("parallax", "Parallax", "company"),
    ("nikhil-varma", "Nikhil Varma", "investor"),
    ("iit-bombay-e-cell", "IIT Bombay E-Cell", "college"),
    ("msw-admin", "MSW Admin", "admin"),
]


def slug(name: str) -> str:
    out, prev_dash = [], False
    for ch in name.lower():
        if ch.isalnum():
            out.append(ch)
            prev_dash = False
        elif not prev_dash:
            out.append("-")
            prev_dash = True
    return "".join(out).strip("-")


@contextmanager
def db():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    try:
        yield con
        con.commit()
    finally:
        con.close()


def upsert_user(con: sqlite3.Connection, u: dict[str, Any]) -> str:
    uid = u.get("id") or slug(u["name"])
    data = {k: v for k, v in u.items() if k not in ("id", "name", "role")}
    con.execute(
        "INSERT INTO users (id, name, role, data) VALUES (?, ?, ?, ?) ON CONFLICT(id) DO NOTHING",
        (uid, u["name"], u.get("role", "student"), json.dumps(data)),
    )
    return uid


def init_db() -> None:
    with db() as con:
        con.executescript(SCHEMA)
        if con.execute("SELECT COUNT(*) FROM users").fetchone()[0]:
            return
        seed = json.loads(SEED_PATH.read_text()) if SEED_PATH.exists() else {}
        for uid, name, role in ORG_ACCOUNTS:
            con.execute("INSERT INTO users (id, name, role, is_admin, status) VALUES (?, ?, ?, ?, 'Verified')", (uid, name, role, int(role == "admin")))
        for u in seed.get("users", []):
            upsert_user(con, u)
        for p in seed.get("posts", []):
            author = upsert_user(con, p.pop("author"))
            comments, likes = p.pop("comments", []), p.pop("likes", 0)
            pid = con.execute("INSERT INTO posts (author_id, data, likes) VALUES (?, ?, ?)", (author, json.dumps(p), likes)).lastrowid
            for c in comments:
                con.execute("INSERT INTO comments (post_id, author_id, text, time, likes) VALUES (?, ?, ?, ?, ?)", (pid, upsert_user(con, c["author"]), c["text"], c.get("time", "now"), c.get("likes", 0)))
        for e in seed.get("events", []):
            owner = "iit-bombay-e-cell" if "IIT Bombay" in e.get("organiser", "") else "msw-admin"
            con.execute("INSERT INTO events (owner_id, data, registered) VALUES (?, ?, ?)", (owner, json.dumps(e), e.get("registered", 0)))
        for o in seed.get("opportunities", []):
            con.execute("INSERT INTO opportunities (owner_id, data, applicants, live) VALUES (?, ?, ?, ?)", (slug(o["company"]), json.dumps(o), o.get("applicants", 0), int(o.get("live", True))))
        for t in seed.get("tasks", []):
            subs = t.pop("submissions", [])
            tid = con.execute("INSERT INTO tasks (owner_id, data) VALUES (?, ?)", (slug(t["company"]), json.dumps(t))).lastrowid
            for s in subs:
                con.execute("INSERT INTO submissions (task_id, user_id, repo, demo, notes, shots, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                            (tid, upsert_user(con, s["student"]), s["repo"], s["demo"], s["notes"], json.dumps(s.get("shots", [])), s.get("status", "In review")))
        for i in seed.get("ideas", []):
            con.execute("INSERT INTO ideas (data, raised) VALUES (?, ?)", (json.dumps(i), i.get("raised", 0)))
        for a in seed.get("announcements", []):
            con.execute("INSERT INTO announcements (owner_id, title, body, organiser, category, link, pinned, time) VALUES ('iit-bombay-e-cell', ?, ?, ?, ?, ?, ?, ?)",
                        (a["title"], a["body"], a["organiser"], a.get("category"), a.get("link", ""), int(a.get("pinned", False)), a.get("time", "now")))


app = FastAPI(title="MSW Community API", version="0.1.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])


@app.on_event("startup")
def _startup() -> None:
    init_db()


# ───────────────────────── auth (development stub) ─────────────────────────

def current_user(x_user: Optional[str] = Header(default=None)) -> sqlite3.Row:
    if not x_user:
        raise HTTPException(401, "Missing X-User header")
    with db() as con:
        row = con.execute("SELECT * FROM users WHERE id = ?", (x_user,)).fetchone()
    if not row:
        raise HTTPException(401, f"Unknown user {x_user}")
    if row["status"] == "Suspended":
        raise HTTPException(403, "Account suspended")
    return row


def require_owner_or_admin(user: sqlite3.Row, owner_id: Optional[str]) -> None:
    if not (user["is_admin"] or user["id"] == owner_id):
        raise HTTPException(403, "Not allowed")


def require_admin(user: sqlite3.Row = Depends(current_user)) -> sqlite3.Row:
    if not user["is_admin"]:
        raise HTTPException(403, "Admins only")
    return user


class Login(BaseModel):
    user_id: str
    role: str


@app.post("/auth/login")
def login(body: Login):
    with db() as con:
        row = con.execute("SELECT id, name, role, status FROM users WHERE id = ?", (body.user_id,)).fetchone()
    if not row:
        raise HTTPException(404, "No such account")
    return {"user": dict(row), "token": row["id"]}


# ───────────────────────── read everything ─────────────────────────

def _person(row: sqlite3.Row) -> dict[str, Any]:
    return {"id": row["id"], "name": row["name"], "role": row["role"], **json.loads(row["data"] or "{}")}


@app.get("/health")
def health():
    return {"ok": True, "db": str(DB_PATH)}


@app.get("/bootstrap")
def bootstrap(user: sqlite3.Row = Depends(current_user)):
    uid = user["id"]
    with db() as con:
        users = {r["id"]: _person(r) for r in con.execute("SELECT * FROM users")}
        posts = []
        for r in con.execute("SELECT * FROM posts WHERE hidden = 0 OR ? ORDER BY pinned DESC, id", (user["is_admin"],)):
            comments = [{"id": c["id"], "author": users.get(c["author_id"]), "text": c["text"], "time": c["time"], "likes": c["likes"]}
                        for c in con.execute("SELECT * FROM comments WHERE post_id = ? ORDER BY id", (r["id"],))]
            posts.append({"id": r["id"], "author": users.get(r["author_id"]), "likes": r["likes"], "comments": comments, **json.loads(r["data"]),
                          "liked": bool(con.execute("SELECT 1 FROM post_likes WHERE post_id=? AND user_id=?", (r["id"], uid)).fetchone()),
                          "saved": bool(con.execute("SELECT 1 FROM post_saves WHERE post_id=? AND user_id=?", (r["id"], uid)).fetchone())})
        events = [{**json.loads(r["data"]), "id": r["id"], "registered": r["registered"],
                   "going": bool(con.execute("SELECT 1 FROM event_registrations WHERE event_id=? AND user_id=?", (r["id"], uid)).fetchone())}
                  for r in con.execute("SELECT * FROM events ORDER BY id")]
        opps = [{**json.loads(r["data"]), "id": r["id"], "applicants": r["applicants"], "live": bool(r["live"]),
                 "applied": bool(con.execute("SELECT 1 FROM applications WHERE opportunity_id=? AND user_id=?", (r["id"], uid)).fetchone())}
                for r in con.execute("SELECT * FROM opportunities ORDER BY id")]
        tasks = []
        for r in con.execute("SELECT * FROM tasks ORDER BY id"):
            subs = [{"id": s["id"], "student": users.get(s["user_id"]), "repo": s["repo"], "demo": s["demo"], "notes": s["notes"],
                     "shots": json.loads(s["shots"] or "[]"), "status": s["status"]}
                    for s in con.execute("SELECT * FROM submissions WHERE task_id = ? ORDER BY id", (r["id"],))]
            mine = [s for s in subs if s["student"] and s["student"]["id"] == uid]
            tasks.append({**json.loads(r["data"]), "id": r["id"], "submissions": subs,
                          "my_status": ("Approved" if mine and mine[-1]["status"] == "Approved" else "Submitted") if mine else "Open"})
        ideas = []
        for r in con.execute("SELECT * FROM ideas ORDER BY id"):
            d = con.execute("SELECT decision, amount FROM idea_decisions WHERE idea_id=? AND user_id=?", (r["id"], uid)).fetchone()
            ideas.append({**json.loads(r["data"]), "id": r["id"], "raised": r["raised"], "decision": d["decision"] if d else None, "my_cheque": d["amount"] if d else 0})
        anns = [dict(r) | {"pinned": bool(r["pinned"])} for r in con.execute("SELECT * FROM announcements ORDER BY pinned DESC, id DESC")]
    return {"me": users.get(uid), "users": list(users.values()), "posts": posts, "events": events, "opportunities": opps,
            "tasks": tasks, "ideas": ideas, "announcements": anns}


# ───────────────────────── posts & comments ─────────────────────────

class PostIn(BaseModel):
    body: str = ""
    src: str = "Link"
    url: str = ""
    title: str = ""
    domain: str = ""
    time: str = "now"
    grad: list[int] = []
    shares: int = 0


@app.post("/posts")
def create_post(p: PostIn, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        pid = con.execute("INSERT INTO posts (author_id, data) VALUES (?, ?)", (user["id"], p.model_dump_json())).lastrowid
    return {"id": pid}


class Toggle(BaseModel):
    liked: Optional[bool] = None
    saved: Optional[bool] = None


@app.post("/posts/{pid}/like")
def like(pid: int, t: Toggle, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        if t.liked:
            if con.execute("INSERT OR IGNORE INTO post_likes VALUES (?, ?)", (pid, user["id"])).rowcount:
                con.execute("UPDATE posts SET likes = likes + 1 WHERE id = ?", (pid,))
        elif con.execute("DELETE FROM post_likes WHERE post_id=? AND user_id=?", (pid, user["id"])).rowcount:
            con.execute("UPDATE posts SET likes = MAX(likes - 1, 0) WHERE id = ?", (pid,))
        likes = con.execute("SELECT likes FROM posts WHERE id = ?", (pid,)).fetchone()
    return {"likes": likes[0] if likes else 0}


@app.post("/posts/{pid}/save")
def save(pid: int, t: Toggle, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        if t.saved:
            con.execute("INSERT OR IGNORE INTO post_saves VALUES (?, ?)", (pid, user["id"]))
        else:
            con.execute("DELETE FROM post_saves WHERE post_id=? AND user_id=?", (pid, user["id"]))
    return {"ok": True}


class CommentIn(BaseModel):
    text: str


@app.post("/posts/{pid}/comments")
def comment(pid: int, c: CommentIn, user: sqlite3.Row = Depends(current_user)):
    if not c.text.strip():
        raise HTTPException(400, "Empty comment")
    with db() as con:
        cid = con.execute("INSERT INTO comments (post_id, author_id, text) VALUES (?, ?, ?)", (pid, user["id"], c.text.strip())).lastrowid
    return {"id": cid}


@app.delete("/posts/{pid}")
def delete_post(pid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT author_id FROM posts WHERE id = ?", (pid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["author_id"])
        con.execute("DELETE FROM posts WHERE id = ?", (pid,))
    return {"ok": True}


@app.patch("/posts/{pid}")
def moderate_post(pid: int, body: dict, user: sqlite3.Row = Depends(require_admin)):
    with db() as con:
        for k in ("hidden", "pinned"):
            if k in body:
                con.execute(f"UPDATE posts SET {k} = ? WHERE id = ?", (int(bool(body[k])), pid))
    return {"ok": True}


@app.delete("/comments/{cid}")
def delete_comment(cid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT author_id FROM comments WHERE id = ?", (cid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["author_id"])
        con.execute("DELETE FROM comments WHERE id = ?", (cid,))
    return {"ok": True}


# ───────────────────────── events & announcements (colleges) ─────────────────────────

@app.post("/events")
def create_event(e: dict, user: sqlite3.Row = Depends(current_user)):
    if user["role"] not in ("college", "student", "admin"):
        raise HTTPException(403, "Only colleges and students can post events")
    with db() as con:
        eid = con.execute("INSERT INTO events (owner_id, data) VALUES (?, ?)", (user["id"], json.dumps(e))).lastrowid
    return {"id": eid}


class RegisterIn(BaseModel):
    team: str = ""
    track: str = ""


@app.post("/events/{eid}/register")
def register(eid: int, r: RegisterIn, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        if con.execute("INSERT OR IGNORE INTO event_registrations (event_id, user_id, team, track) VALUES (?, ?, ?, ?)", (eid, user["id"], r.team, r.track)).rowcount:
            con.execute("UPDATE events SET registered = registered + 1 WHERE id = ?", (eid,))
    return {"ok": True}


@app.get("/events/{eid}/registrations")
def registrations(eid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        ev = con.execute("SELECT owner_id FROM events WHERE id = ?", (eid,)).fetchone()
        if not ev:
            raise HTTPException(404)
        require_owner_or_admin(user, ev["owner_id"])
        return [dict(r) for r in con.execute("SELECT r.*, u.name FROM event_registrations r JOIN users u ON u.id = r.user_id WHERE event_id = ?", (eid,))]


@app.delete("/events/{eid}")
def delete_event(eid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM events WHERE id = ?", (eid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        con.execute("DELETE FROM events WHERE id = ?", (eid,))
    return {"ok": True}


class AnnouncementIn(BaseModel):
    title: str
    body: str
    organiser: str = ""
    category: str = "General"
    link: str = ""
    pinned: bool = False
    time: str = "now"


@app.post("/announcements")
def create_announcement(a: AnnouncementIn, user: sqlite3.Row = Depends(current_user)):
    if user["role"] not in ("college", "admin"):
        raise HTTPException(403, "Only colleges can post announcements")
    with db() as con:
        aid = con.execute("INSERT INTO announcements (owner_id, title, body, organiser, category, link, pinned, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                          (user["id"], a.title, a.body, a.organiser or user["name"], a.category, a.link, int(a.pinned), a.time)).lastrowid
    return {"id": aid}


@app.delete("/announcements/{aid}")
def delete_announcement(aid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM announcements WHERE id = ?", (aid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        con.execute("DELETE FROM announcements WHERE id = ?", (aid,))
    return {"ok": True}


# ───────────────────────── jobs & internships (companies) ─────────────────────────

@app.post("/opportunities")
def create_opportunity(o: dict, user: sqlite3.Row = Depends(current_user)):
    if user["role"] not in ("company", "admin"):
        raise HTTPException(403, "Only companies can post jobs")
    with db() as con:
        oid = con.execute("INSERT INTO opportunities (owner_id, data, live) VALUES (?, ?, ?)", (user["id"], json.dumps(o), int(o.get("live", True)))).lastrowid
    return {"id": oid}


@app.patch("/opportunities/{oid}")
def patch_opportunity(oid: int, body: dict, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM opportunities WHERE id = ?", (oid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        if "live" in body:
            con.execute("UPDATE opportunities SET live = ? WHERE id = ?", (int(bool(body["live"])), oid))
    return {"ok": True}


class ApplyIn(BaseModel):
    link: str = ""
    note: str = ""


@app.post("/opportunities/{oid}/apply")
def apply(oid: int, a: ApplyIn, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        if con.execute("INSERT OR IGNORE INTO applications (opportunity_id, user_id, link, note) VALUES (?, ?, ?, ?)", (oid, user["id"], a.link, a.note)).rowcount:
            con.execute("UPDATE opportunities SET applicants = applicants + 1 WHERE id = ?", (oid,))
    return {"ok": True}


@app.get("/opportunities/{oid}/applications")
def applications(oid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM opportunities WHERE id = ?", (oid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        return [dict(r) for r in con.execute("SELECT a.*, u.name FROM applications a JOIN users u ON u.id = a.user_id WHERE opportunity_id = ?", (oid,))]


@app.delete("/opportunities/{oid}")
def delete_opportunity(oid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM opportunities WHERE id = ?", (oid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        con.execute("DELETE FROM opportunities WHERE id = ?", (oid,))
    return {"ok": True}


# ───────────────────────── paid tasks ─────────────────────────

@app.post("/tasks")
def create_task(t: dict, user: sqlite3.Row = Depends(current_user)):
    if user["role"] not in ("company", "admin"):
        raise HTTPException(403, "Only companies can post tasks")
    t.pop("submissions", None)
    with db() as con:
        tid = con.execute("INSERT INTO tasks (owner_id, data) VALUES (?, ?)", (user["id"], json.dumps(t))).lastrowid
    return {"id": tid}


class SubmissionIn(BaseModel):
    repo: str
    demo: str = ""
    notes: str = ""
    shots: list[int] = []


@app.post("/tasks/{tid}/submissions")
def submit(tid: int, s: SubmissionIn, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        sid = con.execute("INSERT INTO submissions (task_id, user_id, repo, demo, notes, shots) VALUES (?, ?, ?, ?, ?, ?)",
                          (tid, user["id"], s.repo, s.demo, s.notes, json.dumps(s.shots))).lastrowid
    return {"id": sid}


class ReviewIn(BaseModel):
    status: str


@app.patch("/submissions/{sid}")
def review(sid: int, r: ReviewIn, user: sqlite3.Row = Depends(current_user)):
    if r.status not in ("Approved", "Changes requested", "In review"):
        raise HTTPException(400, "Bad status")
    with db() as con:
        row = con.execute("SELECT t.owner_id FROM submissions s JOIN tasks t ON t.id = s.task_id WHERE s.id = ?", (sid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        con.execute("UPDATE submissions SET status = ? WHERE id = ?", (r.status, sid))
    return {"ok": True}


@app.delete("/tasks/{tid}")
def delete_task(tid: int, user: sqlite3.Row = Depends(current_user)):
    with db() as con:
        row = con.execute("SELECT owner_id FROM tasks WHERE id = ?", (tid,)).fetchone()
        if not row:
            raise HTTPException(404)
        require_owner_or_admin(user, row["owner_id"])
        con.execute("DELETE FROM tasks WHERE id = ?", (tid,))
    return {"ok": True}


# ───────────────────────── ideas (investors) ─────────────────────────

class DecisionIn(BaseModel):
    decision: Optional[str]
    amount: float = 0


@app.post("/ideas/{iid}/decision")
def decide(iid: int, d: DecisionIn, user: sqlite3.Row = Depends(current_user)):
    if user["role"] not in ("investor", "admin"):
        raise HTTPException(403, "Investors only")
    with db() as con:
        prev = con.execute("SELECT decision, amount FROM idea_decisions WHERE idea_id=? AND user_id=?", (iid, user["id"])).fetchone()
        if prev and prev["decision"] == "backed":
            con.execute("UPDATE ideas SET raised = MAX(raised - ?, 0) WHERE id = ?", (prev["amount"], iid))
        con.execute("DELETE FROM idea_decisions WHERE idea_id=? AND user_id=?", (iid, user["id"]))
        if d.decision in ("backed", "passed"):
            con.execute("INSERT INTO idea_decisions (idea_id, user_id, decision, amount) VALUES (?, ?, ?, ?)", (iid, user["id"], d.decision, d.amount))
            if d.decision == "backed":
                con.execute("UPDATE ideas SET raised = raised + ? WHERE id = ?", (d.amount, iid))
        raised = con.execute("SELECT raised FROM ideas WHERE id = ?", (iid,)).fetchone()
    return {"raised": raised[0] if raised else 0}


# ───────────────────────── admin ─────────────────────────

@app.get("/admin/stats")
def stats(user: sqlite3.Row = Depends(require_admin)):
    with db() as con:
        q = lambda sql: con.execute(sql).fetchone()[0]  # noqa: E731
        return {
            "users_by_role": {r["role"]: r["n"] for r in con.execute("SELECT role, COUNT(*) n FROM users GROUP BY role")},
            "posts": q("SELECT COUNT(*) FROM posts"), "comments": q("SELECT COUNT(*) FROM comments"),
            "events": q("SELECT COUNT(*) FROM events"), "registrations": q("SELECT COUNT(*) FROM event_registrations"),
            "opportunities": q("SELECT COUNT(*) FROM opportunities"), "applications": q("SELECT COUNT(*) FROM applications"),
            "tasks": q("SELECT COUNT(*) FROM tasks"), "submissions": q("SELECT COUNT(*) FROM submissions"),
            "ideas": q("SELECT COUNT(*) FROM ideas"), "committed_lakh": q("SELECT COALESCE(SUM(amount), 0) FROM idea_decisions WHERE decision='backed'"),
        }


@app.get("/admin/users")
def list_users(user: sqlite3.Row = Depends(require_admin)):
    with db() as con:
        return [dict(r) for r in con.execute("SELECT id, name, role, status, is_admin, created_at FROM users ORDER BY role, name")]


@app.patch("/users/{uid}")
def patch_user(uid: str, body: dict, user: sqlite3.Row = Depends(require_admin)):
    with db() as con:
        if "status" in body:
            con.execute("UPDATE users SET status = ? WHERE id = ?", (body["status"], uid))
        if "is_admin" in body:
            con.execute("UPDATE users SET is_admin = ? WHERE id = ?", (int(bool(body["is_admin"])), uid))
    return {"ok": True}


@app.delete("/users/{uid}")
def delete_user(uid: str, user: sqlite3.Row = Depends(require_admin)):
    with db() as con:
        con.execute("DELETE FROM users WHERE id = ?", (uid,))
    return {"ok": True}

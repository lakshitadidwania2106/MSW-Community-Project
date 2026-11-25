"""Create the tables and fill an empty database from seed.json."""
from __future__ import annotations

import json
import sqlite3
from typing import Any

from app.core.config import settings
from app.core.database import transaction
from app.models.tables import SCHEMA

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


def upsert_user(con: sqlite3.Connection, u: dict[str, Any]) -> str:
    uid = u.get("id") or slug(u["name"])
    data = {k: v for k, v in u.items() if k not in ("id", "name", "role")}
    con.execute("INSERT INTO users (id, name, role, data) VALUES (?, ?, ?, ?) ON CONFLICT(id) DO NOTHING",
                (uid, u["name"], u.get("role", "student"), json.dumps(data)))
    return uid


def seed(con: sqlite3.Connection, data: dict[str, Any]) -> None:
    for uid, name, role in ORG_ACCOUNTS:
        con.execute("INSERT INTO users (id, name, role, is_admin, status) VALUES (?, ?, ?, ?, 'Verified')", (uid, name, role, int(role == "admin")))
    for u in data.get("users", []):
        upsert_user(con, u)
    for p in data.get("posts", []):
        author = upsert_user(con, p.pop("author"))
        comments, likes = p.pop("comments", []), p.pop("likes", 0)
        pid = con.execute("INSERT INTO posts (author_id, data, likes) VALUES (?, ?, ?)", (author, json.dumps(p), likes)).lastrowid
        for c in comments:
            con.execute("INSERT INTO comments (post_id, author_id, text, time, likes) VALUES (?, ?, ?, ?, ?)",
                        (pid, upsert_user(con, c["author"]), c["text"], c.get("time", "now"), c.get("likes", 0)))
    for e in data.get("events", []):
        owner = "iit-bombay-e-cell" if "IIT Bombay" in e.get("organiser", "") else "msw-admin"
        con.execute("INSERT INTO events (owner_id, data, registered) VALUES (?, ?, ?)", (owner, json.dumps(e), e.get("registered", 0)))
    for o in data.get("opportunities", []):
        con.execute("INSERT INTO opportunities (owner_id, data, applicants, live) VALUES (?, ?, ?, ?)",
                    (slug(o["company"]), json.dumps(o), o.get("applicants", 0), int(o.get("live", True))))
    for t in data.get("tasks", []):
        subs = t.pop("submissions", [])
        tid = con.execute("INSERT INTO tasks (owner_id, data) VALUES (?, ?)", (slug(t["company"]), json.dumps(t))).lastrowid
        for s in subs:
            con.execute("INSERT INTO submissions (task_id, user_id, repo, demo, notes, shots, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                        (tid, upsert_user(con, s["student"]), s["repo"], s["demo"], s["notes"], json.dumps(s.get("shots", [])), s.get("status", "In review")))
    for i in data.get("ideas", []):
        con.execute("INSERT INTO ideas (data, raised) VALUES (?, ?)", (json.dumps(i), i.get("raised", 0)))
    for a in data.get("announcements", []):
        con.execute("INSERT INTO announcements (owner_id, title, body, organiser, category, link, pinned, time) VALUES ('iit-bombay-e-cell', ?, ?, ?, ?, ?, ?, ?)",
                    (a["title"], a["body"], a["organiser"], a.get("category"), a.get("link", ""), int(a.get("pinned", False)), a.get("time", "now")))


def init_db() -> None:
    """Create tables; seed only when the database has no users yet."""
    with transaction() as con:
        con.executescript(SCHEMA)
        if con.execute("SELECT COUNT(*) FROM users").fetchone()[0]:
            return
        data = json.loads(settings.seed_path.read_text()) if settings.seed_path.exists() else {}
        seed(con, data)

"""Everything a signed-in user needs on launch, in one response."""
from __future__ import annotations

import sqlite3
from typing import Any

from app.models import mappers


def bootstrap(con: sqlite3.Connection, user: sqlite3.Row) -> dict[str, Any]:
    uid = user["id"]
    exists = lambda sql, *args: con.execute(sql, args).fetchone() is not None  # noqa: E731
    users = {r["id"]: mappers.person(r) for r in con.execute("SELECT * FROM users")}

    posts = []
    for r in con.execute("SELECT * FROM posts WHERE hidden = 0 OR ? ORDER BY pinned DESC, id", (user["is_admin"],)):
        comments = [mappers.comment(c, users) for c in con.execute("SELECT * FROM comments WHERE post_id = ? ORDER BY id", (r["id"],))]
        posts.append(mappers.post(r, users, comments,
                                  liked=exists("SELECT 1 FROM post_likes WHERE post_id=? AND user_id=?", r["id"], uid),
                                  saved=exists("SELECT 1 FROM post_saves WHERE post_id=? AND user_id=?", r["id"], uid)))

    events = [mappers.event(r, going=exists("SELECT 1 FROM event_registrations WHERE event_id=? AND user_id=?", r["id"], uid))
              for r in con.execute("SELECT * FROM events ORDER BY id")]
    opportunities = [mappers.opportunity(r, applied=exists("SELECT 1 FROM applications WHERE opportunity_id=? AND user_id=?", r["id"], uid))
                     for r in con.execute("SELECT * FROM opportunities ORDER BY id")]
    tasks = []
    for r in con.execute("SELECT * FROM tasks ORDER BY id"):
        subs = [mappers.submission(s, users) for s in con.execute("SELECT * FROM submissions WHERE task_id = ? ORDER BY id", (r["id"],))]
        tasks.append(mappers.task(r, subs, uid))
    ideas = [mappers.idea(r, con.execute("SELECT decision, amount FROM idea_decisions WHERE idea_id=? AND user_id=?", (r["id"], uid)).fetchone())
             for r in con.execute("SELECT * FROM ideas ORDER BY id")]
    announcements = [mappers.announcement(r) for r in con.execute("SELECT * FROM announcements ORDER BY pinned DESC, id DESC")]

    return {"me": users.get(uid), "users": list(users.values()), "posts": posts, "events": events, "opportunities": opportunities,
            "tasks": tasks, "ideas": ideas, "announcements": announcements}

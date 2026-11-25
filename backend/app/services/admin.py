from __future__ import annotations

import sqlite3
from typing import Any

from app.schemas.users import UserPatch


def stats(con: sqlite3.Connection) -> dict[str, Any]:
    q = lambda sql: con.execute(sql).fetchone()[0]  # noqa: E731
    return {
        "users_by_role": {r["role"]: r["n"] for r in con.execute("SELECT role, COUNT(*) n FROM users GROUP BY role")},
        "posts": q("SELECT COUNT(*) FROM posts"), "comments": q("SELECT COUNT(*) FROM comments"),
        "events": q("SELECT COUNT(*) FROM events"), "registrations": q("SELECT COUNT(*) FROM event_registrations"),
        "opportunities": q("SELECT COUNT(*) FROM opportunities"), "applications": q("SELECT COUNT(*) FROM applications"),
        "tasks": q("SELECT COUNT(*) FROM tasks"), "submissions": q("SELECT COUNT(*) FROM submissions"),
        "ideas": q("SELECT COUNT(*) FROM ideas"),
        "committed_lakh": q("SELECT COALESCE(SUM(amount), 0) FROM idea_decisions WHERE decision='backed'"),
    }


def list_users(con: sqlite3.Connection) -> list[dict[str, Any]]:
    return [dict(r) for r in con.execute("SELECT id, name, role, status, is_admin, created_at FROM users ORDER BY role, name")]


def update_user(con: sqlite3.Connection, uid: str, body: UserPatch) -> None:
    if body.status is not None:
        con.execute("UPDATE users SET status = ? WHERE id = ?", (body.status, uid))
    if body.is_admin is not None:
        con.execute("UPDATE users SET is_admin = ? WHERE id = ?", (int(body.is_admin), uid))


def delete_user(con: sqlite3.Connection, uid: str) -> None:
    con.execute("DELETE FROM users WHERE id = ?", (uid,))

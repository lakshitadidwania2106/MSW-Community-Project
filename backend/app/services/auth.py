from __future__ import annotations

import sqlite3

from app.core.errors import NotFound


def login(con: sqlite3.Connection, user_id: str) -> dict:
    row = con.execute("SELECT id, name, role, status FROM users WHERE id = ?", (user_id,)).fetchone()
    if not row:
        raise NotFound("No such account")
    return {"user": dict(row), "token": row["id"]}

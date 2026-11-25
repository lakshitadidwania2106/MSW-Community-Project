"""Shared helper: load a row's owner column or raise 404."""
from __future__ import annotations

import sqlite3

from app.core.errors import NotFound

_OWNER_COLUMN = {"posts": "author_id", "comments": "author_id", "events": "owner_id", "announcements": "owner_id",
                 "opportunities": "owner_id", "tasks": "owner_id"}


def owner_of(con: sqlite3.Connection, table: str, row_id: int) -> str | None:
    col = _OWNER_COLUMN[table]
    row = con.execute(f"SELECT {col} FROM {table} WHERE id = ?", (row_id,)).fetchone()
    if not row:
        raise NotFound()
    return row[col]

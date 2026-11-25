"""SQLite connection handling.

Each request gets one connection (`get_db`). It commits when the request
succeeds and rolls back if anything raises.
"""
from __future__ import annotations

import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager

from app.core.config import settings


def connect() -> sqlite3.Connection:
    con = sqlite3.connect(settings.db_path)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    return con


@contextmanager
def transaction() -> Iterator[sqlite3.Connection]:
    con = connect()
    try:
        yield con
        con.commit()
    except Exception:
        con.rollback()
        raise
    finally:
        con.close()


def get_db() -> Iterator[sqlite3.Connection]:
    """FastAPI dependency: one connection per request."""
    with transaction() as con:
        yield con

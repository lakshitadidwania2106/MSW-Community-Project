"""Authentication and permission checks.

Development stub: the client sends the signed-in account id in the `X-User`
header. Replace with real sign-in (JWT, Google / GitHub OAuth) before launch.
"""
from __future__ import annotations

import sqlite3
from typing import Optional

from fastapi import Depends, Header

from app.core.database import get_db
from app.core.errors import Forbidden, Unauthorized


def current_user(x_user: Optional[str] = Header(default=None), con: sqlite3.Connection = Depends(get_db)) -> sqlite3.Row:
    if not x_user:
        raise Unauthorized("Missing X-User header")
    row = con.execute("SELECT * FROM users WHERE id = ?", (x_user,)).fetchone()
    if not row:
        raise Unauthorized(f"Unknown user {x_user}")
    if row["status"] == "Suspended":
        raise Forbidden("Account suspended")
    return row


def require_admin(user: sqlite3.Row = Depends(current_user)) -> sqlite3.Row:
    if not user["is_admin"]:
        raise Forbidden("Admins only")
    return user


def require_role(user: sqlite3.Row, roles: tuple[str, ...], message: str) -> None:
    if user["role"] not in roles:
        raise Forbidden(message)


def require_owner_or_admin(user: sqlite3.Row, owner_id: Optional[str]) -> None:
    if not (user["is_admin"] or user["id"] == owner_id):
        raise Forbidden("Not allowed")

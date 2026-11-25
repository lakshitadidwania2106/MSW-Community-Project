"""Jobs and internships posted by companies."""
from __future__ import annotations

import json
import sqlite3
from typing import Any

from app.core.security import require_owner_or_admin, require_role
from app.schemas.opportunities import ApplyIn, OpportunityPatch
from app.services.ownership import owner_of


def create(con: sqlite3.Connection, user: sqlite3.Row, data: dict[str, Any]) -> int:
    require_role(user, ("company", "admin"), "Only companies can post jobs")
    return con.execute("INSERT INTO opportunities (owner_id, data, live) VALUES (?, ?, ?)",
                       (user["id"], json.dumps(data), int(data.get("live", True)))).lastrowid


def update(con: sqlite3.Connection, user: sqlite3.Row, oid: int, body: OpportunityPatch) -> None:
    require_owner_or_admin(user, owner_of(con, "opportunities", oid))
    if body.live is not None:
        con.execute("UPDATE opportunities SET live = ? WHERE id = ?", (int(body.live), oid))


def apply(con: sqlite3.Connection, user: sqlite3.Row, oid: int, a: ApplyIn) -> None:
    if con.execute("INSERT OR IGNORE INTO applications (opportunity_id, user_id, link, note) VALUES (?, ?, ?, ?)",
                   (oid, user["id"], a.link, a.note)).rowcount:
        con.execute("UPDATE opportunities SET applicants = applicants + 1 WHERE id = ?", (oid,))


def applications(con: sqlite3.Connection, user: sqlite3.Row, oid: int) -> list[dict[str, Any]]:
    require_owner_or_admin(user, owner_of(con, "opportunities", oid))
    return [dict(r) for r in con.execute(
        "SELECT a.*, u.name FROM applications a JOIN users u ON u.id = a.user_id WHERE opportunity_id = ?", (oid,))]


def delete(con: sqlite3.Connection, user: sqlite3.Row, oid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "opportunities", oid))
    con.execute("DELETE FROM opportunities WHERE id = ?", (oid,))

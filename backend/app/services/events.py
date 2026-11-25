from __future__ import annotations

import json
import sqlite3
from typing import Any

from app.core.security import require_owner_or_admin, require_role
from app.schemas.events import AnnouncementIn, RegisterIn
from app.services.ownership import owner_of


def create(con: sqlite3.Connection, user: sqlite3.Row, data: dict[str, Any]) -> int:
    require_role(user, ("college", "student", "admin"), "Only colleges and students can post events")
    return con.execute("INSERT INTO events (owner_id, data) VALUES (?, ?)", (user["id"], json.dumps(data))).lastrowid


def register(con: sqlite3.Connection, user: sqlite3.Row, eid: int, r: RegisterIn) -> None:
    if con.execute("INSERT OR IGNORE INTO event_registrations (event_id, user_id, team, track) VALUES (?, ?, ?, ?)",
                   (eid, user["id"], r.team, r.track)).rowcount:
        con.execute("UPDATE events SET registered = registered + 1 WHERE id = ?", (eid,))


def registrations(con: sqlite3.Connection, user: sqlite3.Row, eid: int) -> list[dict[str, Any]]:
    require_owner_or_admin(user, owner_of(con, "events", eid))
    return [dict(r) for r in con.execute(
        "SELECT r.*, u.name FROM event_registrations r JOIN users u ON u.id = r.user_id WHERE event_id = ?", (eid,))]


def delete(con: sqlite3.Connection, user: sqlite3.Row, eid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "events", eid))
    con.execute("DELETE FROM events WHERE id = ?", (eid,))


def create_announcement(con: sqlite3.Connection, user: sqlite3.Row, a: AnnouncementIn) -> int:
    require_role(user, ("college", "admin"), "Only colleges can post announcements")
    return con.execute(
        "INSERT INTO announcements (owner_id, title, body, organiser, category, link, pinned, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        (user["id"], a.title, a.body, a.organiser or user["name"], a.category, a.link, int(a.pinned), a.time)).lastrowid


def delete_announcement(con: sqlite3.Connection, user: sqlite3.Row, aid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "announcements", aid))
    con.execute("DELETE FROM announcements WHERE id = ?", (aid,))

"""Paid company tasks and student submissions."""
from __future__ import annotations

import json
import sqlite3
from typing import Any

from app.core.errors import BadRequest, NotFound
from app.core.security import require_owner_or_admin, require_role
from app.schemas.tasks import REVIEW_STATUSES, SubmissionIn
from app.services.ownership import owner_of


def create(con: sqlite3.Connection, user: sqlite3.Row, data: dict[str, Any]) -> int:
    require_role(user, ("company", "admin"), "Only companies can post tasks")
    data = {k: v for k, v in data.items() if k != "submissions"}
    return con.execute("INSERT INTO tasks (owner_id, data) VALUES (?, ?)", (user["id"], json.dumps(data))).lastrowid


def submit(con: sqlite3.Connection, user: sqlite3.Row, tid: int, s: SubmissionIn) -> int:
    return con.execute("INSERT INTO submissions (task_id, user_id, repo, demo, notes, shots) VALUES (?, ?, ?, ?, ?, ?)",
                       (tid, user["id"], s.repo, s.demo, s.notes, json.dumps(s.shots))).lastrowid


def review(con: sqlite3.Connection, user: sqlite3.Row, sid: int, status: str) -> None:
    if status not in REVIEW_STATUSES:
        raise BadRequest("Bad status")
    row = con.execute("SELECT t.owner_id FROM submissions s JOIN tasks t ON t.id = s.task_id WHERE s.id = ?", (sid,)).fetchone()
    if not row:
        raise NotFound()
    require_owner_or_admin(user, row["owner_id"])
    con.execute("UPDATE submissions SET status = ? WHERE id = ?", (status, sid))


def delete(con: sqlite3.Connection, user: sqlite3.Row, tid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "tasks", tid))
    con.execute("DELETE FROM tasks WHERE id = ?", (tid,))

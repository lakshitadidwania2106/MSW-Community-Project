"""Turn database rows into the JSON shapes the app and website expect."""
from __future__ import annotations

import json
import sqlite3
from typing import Any, Optional

Person = dict[str, Any]


def person(row: sqlite3.Row) -> Person:
    return {"id": row["id"], "name": row["name"], "role": row["role"], **json.loads(row["data"] or "{}")}


def comment(row: sqlite3.Row, users: dict[str, Person]) -> dict[str, Any]:
    return {"id": row["id"], "author": users.get(row["author_id"]), "text": row["text"], "time": row["time"], "likes": row["likes"]}


def post(row: sqlite3.Row, users: dict[str, Person], comments: list[dict[str, Any]], liked: bool, saved: bool) -> dict[str, Any]:
    return {"id": row["id"], "author": users.get(row["author_id"]), "likes": row["likes"], "comments": comments, **json.loads(row["data"]),
            "hidden": bool(row["hidden"]), "pinned": bool(row["pinned"]), "liked": liked, "saved": saved}


def event(row: sqlite3.Row, going: bool) -> dict[str, Any]:
    return {**json.loads(row["data"]), "id": row["id"], "registered": row["registered"], "going": going}


def opportunity(row: sqlite3.Row, applied: bool) -> dict[str, Any]:
    return {**json.loads(row["data"]), "id": row["id"], "applicants": row["applicants"], "live": bool(row["live"]), "applied": applied}


def submission(row: sqlite3.Row, users: dict[str, Person]) -> dict[str, Any]:
    return {"id": row["id"], "student": users.get(row["user_id"]), "repo": row["repo"], "demo": row["demo"], "notes": row["notes"],
            "shots": json.loads(row["shots"] or "[]"), "status": row["status"]}


def task(row: sqlite3.Row, submissions: list[dict[str, Any]], uid: str) -> dict[str, Any]:
    mine = [s for s in submissions if s["student"] and s["student"]["id"] == uid]
    my_status = ("Approved" if mine[-1]["status"] == "Approved" else "Submitted") if mine else "Open"
    return {**json.loads(row["data"]), "id": row["id"], "submissions": submissions, "my_status": my_status}


def idea(row: sqlite3.Row, decision: Optional[sqlite3.Row]) -> dict[str, Any]:
    return {**json.loads(row["data"]), "id": row["id"], "raised": row["raised"],
            "decision": decision["decision"] if decision else None, "my_cheque": decision["amount"] if decision else 0}


def announcement(row: sqlite3.Row) -> dict[str, Any]:
    return dict(row) | {"pinned": bool(row["pinned"])}

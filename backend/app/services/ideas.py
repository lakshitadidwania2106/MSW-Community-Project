"""Investor decisions on student startup ideas."""
from __future__ import annotations

import sqlite3

from app.core.errors import NotFound
from app.core.security import require_role
from app.schemas.ideas import DecisionIn


def decide(con: sqlite3.Connection, user: sqlite3.Row, iid: int, d: DecisionIn) -> float:
    require_role(user, ("investor", "admin"), "Investors only")
    if not con.execute("SELECT 1 FROM ideas WHERE id = ?", (iid,)).fetchone():
        raise NotFound()
    prev = con.execute("SELECT decision, amount FROM idea_decisions WHERE idea_id=? AND user_id=?", (iid, user["id"])).fetchone()
    if prev and prev["decision"] == "backed":
        con.execute("UPDATE ideas SET raised = MAX(raised - ?, 0) WHERE id = ?", (prev["amount"], iid))
    con.execute("DELETE FROM idea_decisions WHERE idea_id=? AND user_id=?", (iid, user["id"]))
    if d.decision in ("backed", "passed"):
        con.execute("INSERT INTO idea_decisions (idea_id, user_id, decision, amount) VALUES (?, ?, ?, ?)", (iid, user["id"], d.decision, d.amount))
        if d.decision == "backed":
            con.execute("UPDATE ideas SET raised = raised + ? WHERE id = ?", (d.amount, iid))
    # money is in lakh; round away float noise like 7.800000000000001
    con.execute("UPDATE ideas SET raised = ROUND(raised, 2) WHERE id = ?", (iid,))
    return con.execute("SELECT raised FROM ideas WHERE id = ?", (iid,)).fetchone()[0]

from __future__ import annotations

from typing import Optional

from pydantic import BaseModel


class DecisionIn(BaseModel):
    decision: Optional[str]  # "backed" | "passed" | None (undo)
    amount: float = 0


class RaisedOut(BaseModel):
    raised: float

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel

ReviewStatus = Literal["Approved", "Changes requested", "In review"]
REVIEW_STATUSES: tuple[str, ...] = ("Approved", "Changes requested", "In review")


class SubmissionIn(BaseModel):
    repo: str
    demo: str = ""
    notes: str = ""
    shots: list[int] = []


class ReviewIn(BaseModel):
    status: str

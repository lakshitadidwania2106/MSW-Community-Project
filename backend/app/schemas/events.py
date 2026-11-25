from __future__ import annotations

from pydantic import BaseModel


class RegisterIn(BaseModel):
    team: str = ""
    track: str = ""


class AnnouncementIn(BaseModel):
    title: str
    body: str
    organiser: str = ""
    category: str = "General"
    link: str = ""
    pinned: bool = False
    time: str = "now"

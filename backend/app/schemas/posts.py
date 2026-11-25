from __future__ import annotations

from typing import Optional

from pydantic import BaseModel


class PostIn(BaseModel):
    body: str = ""
    src: str = "Link"
    url: str = ""
    title: str = ""
    domain: str = ""
    time: str = "now"
    grad: list[int] = []
    shares: int = 0


class ToggleIn(BaseModel):
    liked: Optional[bool] = None
    saved: Optional[bool] = None


class LikesOut(BaseModel):
    likes: int


class CommentIn(BaseModel):
    text: str


class ModeratePostIn(BaseModel):
    """Admin only. Fields left out are not changed."""
    hidden: Optional[bool] = None
    pinned: Optional[bool] = None

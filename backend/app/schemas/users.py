from __future__ import annotations

from typing import Optional

from pydantic import BaseModel


class UserPatch(BaseModel):
    """Admin only. Fields left out are not changed."""
    status: Optional[str] = None
    is_admin: Optional[bool] = None


class AdminUserOut(BaseModel):
    id: str
    name: str
    role: str
    status: str
    is_admin: int
    created_at: Optional[str] = None


class StatsOut(BaseModel):
    users_by_role: dict[str, int]
    posts: int
    comments: int
    events: int
    registrations: int
    opportunities: int
    applications: int
    tasks: int
    submissions: int
    ideas: int
    committed_lakh: float

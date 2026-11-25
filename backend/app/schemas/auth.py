from __future__ import annotations

from pydantic import BaseModel


class LoginIn(BaseModel):
    user_id: str
    role: str


class LoginUser(BaseModel):
    id: str
    name: str
    role: str
    status: str


class LoginOut(BaseModel):
    user: LoginUser
    token: str

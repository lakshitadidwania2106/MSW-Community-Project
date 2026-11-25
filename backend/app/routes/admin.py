from fastapi import APIRouter

from app.routes.deps import DB, Admin
from app.schemas.common import Ok
from app.schemas.users import AdminUserOut, StatsOut, UserPatch
from app.services import admin as service

router = APIRouter(tags=["admin"])


@router.get("/admin/stats", response_model=StatsOut)
def stats(con: DB, admin: Admin):
    return service.stats(con)


@router.get("/admin/users", response_model=list[AdminUserOut])
def list_users(con: DB, admin: Admin):
    return service.list_users(con)


@router.patch("/users/{uid}", response_model=Ok)
def update_user(uid: str, body: UserPatch, con: DB, admin: Admin):
    service.update_user(con, uid, body)
    return Ok()


@router.delete("/users/{uid}", response_model=Ok)
def delete_user(uid: str, con: DB, admin: Admin):
    service.delete_user(con, uid)
    return Ok()

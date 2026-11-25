from fastapi import APIRouter

from app.routes.deps import DB, User
from app.schemas.common import Created, FreeForm, Ok
from app.schemas.events import AnnouncementIn, RegisterIn
from app.services import events as service

router = APIRouter(tags=["events & announcements"])


@router.post("/events", response_model=Created)
def create_event(e: FreeForm, con: DB, user: User):
    return {"id": service.create(con, user, e)}


@router.post("/events/{eid}/register", response_model=Ok)
def register(eid: int, r: RegisterIn, con: DB, user: User):
    service.register(con, user, eid, r)
    return Ok()


@router.get("/events/{eid}/registrations")
def registrations(eid: int, con: DB, user: User):
    return service.registrations(con, user, eid)


@router.delete("/events/{eid}", response_model=Ok)
def delete_event(eid: int, con: DB, user: User):
    service.delete(con, user, eid)
    return Ok()


@router.post("/announcements", response_model=Created)
def create_announcement(a: AnnouncementIn, con: DB, user: User):
    return {"id": service.create_announcement(con, user, a)}


@router.delete("/announcements/{aid}", response_model=Ok)
def delete_announcement(aid: int, con: DB, user: User):
    service.delete_announcement(con, user, aid)
    return Ok()

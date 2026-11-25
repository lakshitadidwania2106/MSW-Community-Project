from fastapi import APIRouter

from app.routes.deps import DB, User
from app.schemas.common import Created, FreeForm, Ok
from app.schemas.tasks import ReviewIn, SubmissionIn
from app.services import tasks as service

router = APIRouter(tags=["paid tasks"])


@router.post("/tasks", response_model=Created)
def create_task(t: FreeForm, con: DB, user: User):
    return {"id": service.create(con, user, t)}


@router.post("/tasks/{tid}/submissions", response_model=Created)
def submit(tid: int, s: SubmissionIn, con: DB, user: User):
    return {"id": service.submit(con, user, tid, s)}


@router.patch("/submissions/{sid}", response_model=Ok)
def review(sid: int, r: ReviewIn, con: DB, user: User):
    service.review(con, user, sid, r.status)
    return Ok()


@router.delete("/tasks/{tid}", response_model=Ok)
def delete_task(tid: int, con: DB, user: User):
    service.delete(con, user, tid)
    return Ok()

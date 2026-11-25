from fastapi import APIRouter

from app.routes.deps import DB, Admin, User
from app.schemas.common import Created, Ok
from app.schemas.posts import CommentIn, LikesOut, ModeratePostIn, PostIn, ToggleIn
from app.services import posts as service

router = APIRouter(tags=["posts"])


@router.post("/posts", response_model=Created)
def create_post(p: PostIn, con: DB, user: User):
    return {"id": service.create(con, user, p)}


@router.post("/posts/{pid}/like", response_model=LikesOut)
def like(pid: int, t: ToggleIn, con: DB, user: User):
    return {"likes": service.set_like(con, user, pid, bool(t.liked))}


@router.post("/posts/{pid}/save", response_model=Ok)
def save(pid: int, t: ToggleIn, con: DB, user: User):
    service.set_saved(con, user, pid, bool(t.saved))
    return Ok()


@router.post("/posts/{pid}/comments", response_model=Created)
def comment(pid: int, c: CommentIn, con: DB, user: User):
    return {"id": service.add_comment(con, user, pid, c.text)}


@router.delete("/posts/{pid}", response_model=Ok)
def delete_post(pid: int, con: DB, user: User):
    service.delete(con, user, pid)
    return Ok()


@router.patch("/posts/{pid}", response_model=Ok)
def moderate_post(pid: int, body: ModeratePostIn, con: DB, admin: Admin):
    service.moderate(con, pid, body)
    return Ok()


@router.delete("/comments/{cid}", response_model=Ok)
def delete_comment(cid: int, con: DB, user: User):
    service.delete_comment(con, user, cid)
    return Ok()

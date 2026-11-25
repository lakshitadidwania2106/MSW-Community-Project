from fastapi import APIRouter

from app.routes.deps import DB, User
from app.services import feed as service

router = APIRouter(tags=["feed"])


@router.get("/bootstrap")
def bootstrap(con: DB, user: User):
    """Everything the signed-in user needs: people, posts, events, jobs, tasks, ideas, announcements."""
    return service.bootstrap(con, user)

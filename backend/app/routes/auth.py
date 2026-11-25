from fastapi import APIRouter

from app.routes.deps import DB
from app.schemas.auth import LoginIn, LoginOut
from app.services import auth as service

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=LoginOut)
def login(body: LoginIn, con: DB):
    return service.login(con, body.user_id)

from fastapi import APIRouter

from app.routes.deps import DB, User
from app.schemas.ideas import DecisionIn, RaisedOut
from app.services import ideas as service

router = APIRouter(tags=["ideas (investors)"])


@router.post("/ideas/{iid}/decision", response_model=RaisedOut)
def decide(iid: int, d: DecisionIn, con: DB, user: User):
    """Back (with an amount in lakh), pass, or undo (decision = null)."""
    return {"raised": service.decide(con, user, iid, d)}

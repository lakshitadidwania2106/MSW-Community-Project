from fastapi import APIRouter

from app.routes.deps import DB, User
from app.schemas.common import Created, FreeForm, Ok
from app.schemas.opportunities import ApplyIn, OpportunityPatch
from app.services import opportunities as service

router = APIRouter(prefix="/opportunities", tags=["jobs & internships"])


@router.post("", response_model=Created)
def create_opportunity(o: FreeForm, con: DB, user: User):
    return {"id": service.create(con, user, o)}


@router.patch("/{oid}", response_model=Ok)
def update_opportunity(oid: int, body: OpportunityPatch, con: DB, user: User):
    service.update(con, user, oid, body)
    return Ok()


@router.post("/{oid}/apply", response_model=Ok)
def apply(oid: int, a: ApplyIn, con: DB, user: User):
    service.apply(con, user, oid, a)
    return Ok()


@router.get("/{oid}/applications")
def applications(oid: int, con: DB, user: User):
    return service.applications(con, user, oid)


@router.delete("/{oid}", response_model=Ok)
def delete_opportunity(oid: int, con: DB, user: User):
    service.delete(con, user, oid)
    return Ok()

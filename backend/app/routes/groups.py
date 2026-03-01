from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app import crud, schemas
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/groups", tags=["Groups"])


@router.post("/", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.create_group(db, group, current_user.id)


@router.get("/", response_model=list[schemas.GroupOut])
def list_groups(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.get_groups(db)


@router.get("/{group_id}/balances")
def get_group_balances(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.get_group_balances(db, group_id)
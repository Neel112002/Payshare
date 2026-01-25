from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app import schemas, crud
from app.database import get_db

router = APIRouter(prefix="/groups", tags=["Groups"])

@router.post("/", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db)
):
    return crud.create_group(db, group)

@router.get("/", response_model=List[schemas.GroupOut])
def list_groups(db: Session = Depends(get_db)):
    return crud.get_groups(db)

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app import crud, schemas
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/settlements", tags=["Settlements"])


@router.post("/", response_model=schemas.SettlementOut)
def create_settlement(
    settlement: schemas.SettlementCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.create_settlement(db, settlement)
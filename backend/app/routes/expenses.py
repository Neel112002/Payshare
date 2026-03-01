from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from uuid import UUID

from app.database import get_db
from app import crud, schemas
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/expenses", tags=["Expenses"])


@router.post("/", response_model=schemas.ExpenseOut)
def create_expense(
    expense: schemas.ExpenseCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.create_expense(db, expense)


@router.put("/{expense_id}", response_model=schemas.ExpenseOut)
def update_expense(
    expense_id: UUID,
    update: schemas.ExpenseUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.update_expense(db, expense_id, update)


@router.get("/group/{group_id}")
def list_group_expenses(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return crud.get_expenses_by_group(db, group_id)
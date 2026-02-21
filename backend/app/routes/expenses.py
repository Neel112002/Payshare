from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.models import Expense
from sqlalchemy.orm import joinedload

from app.database import get_db
from app import schemas, crud
from app.models import Group, User
from app.auth.security import get_current_user

router = APIRouter(
    prefix="/expenses",
    tags=["Expenses"]
)

# -------------------------------------------------
# Add Expense (SECURED)
# -------------------------------------------------
@router.post("", response_model=schemas.ExpenseResponse)
def add_expense(
    expense: schemas.ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 🔒 Check group ownership
    group = (
        db.query(Group)
        .filter(
            Group.id == expense.group_id,
            Group.user_id == current_user.id
        )
        .first()
    )

    if not group:
        raise HTTPException(status_code=403, detail="Not authorized")

    return crud.create_expense(db, expense)


@router.get("/group/{group_id}", response_model=list[schemas.ExpenseOut])
def get_group_expenses(
    group_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 🔒 Verify group ownership
    group = (
        db.query(Group)
        .filter(
            Group.id == group_id,
            Group.user_id == current_user.id
        )
        .first()
    )

    if not group:
        raise HTTPException(status_code=403, detail="Not authorized")

    expenses = (
        db.query(Expense)
        .options(joinedload(Expense.splits))
        .filter(Expense.group_id == group_id)
        .order_by(Expense.created_at.desc())
        .all()
    )

    return expenses



from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

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
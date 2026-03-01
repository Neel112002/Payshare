from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from uuid import UUID

from app.database import get_db
from app import schemas
from app.models import Expense, ExpenseSplit, Group, GroupMember, User
from app.auth.security import get_current_user

router = APIRouter(
    prefix="/expenses",
    tags=["Expenses"]
)


# -------------------------------------------------
# Helper: Verify Membership
# -------------------------------------------------
def verify_membership(db: Session, group_id: UUID, user_id: UUID):
    membership = (
        db.query(GroupMember)
        .filter(
            GroupMember.group_id == group_id,
            GroupMember.user_id == user_id
        )
        .first()
    )

    if not membership:
        raise HTTPException(status_code=403, detail="Not authorized")


# -------------------------------------------------
# Add Expense (SECURED)
# -------------------------------------------------
@router.post("", response_model=schemas.ExpenseResponse)
def add_expense(
    expense: schemas.ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 🔒 Verify group membership
    verify_membership(db, expense.group_id, current_user.id)

    # 🔒 Verify payer is group member
    verify_membership(db, expense.group_id, expense.paid_by)

    # 🔒 Verify all split users are group members
    for split in expense.splits:
        verify_membership(db, expense.group_id, split.user_id)

    # Create Expense
    new_expense = Expense(
        group_id=expense.group_id,
        title=expense.title,
        total_amount=expense.total_amount,
        paid_by=expense.paid_by,
        created_by=current_user.id
    )

    db.add(new_expense)
    db.flush()  # get expense ID before adding splits

    # Create Splits
    for split in expense.splits:
        new_split = ExpenseSplit(
            expense_id=new_expense.id,
            user_id=split.user_id,
            amount=split.amount
        )
        db.add(new_split)

    db.commit()
    db.refresh(new_expense)

    return new_expense


# -------------------------------------------------
# Get Group Expenses
# -------------------------------------------------
@router.get("/group/{group_id}", response_model=list[schemas.ExpenseOut])
def get_group_expenses(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    verify_membership(db, group_id, current_user.id)

    expenses = (
        db.query(Expense)
        .options(joinedload(Expense.splits))
        .filter(Expense.group_id == group_id)
        .order_by(Expense.created_at.desc())
        .all()
    )

    return expenses
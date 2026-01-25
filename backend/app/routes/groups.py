from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.database import get_db
from app import schemas, crud
from app.models import Expense
from app.fairness.balances import calculate_balances, fairness_score
from app.fairness.settlements import calculate_settlements

router = APIRouter(
    prefix="/groups",
    tags=["Groups"]
)

# -------------------------------------------------
# Create Group
# -------------------------------------------------
@router.post("/", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db)
):
    return crud.create_group(db, group)


# -------------------------------------------------
# List Groups
# -------------------------------------------------
@router.get("/", response_model=List[schemas.GroupOut])
def list_groups(db: Session = Depends(get_db)):
    return crud.get_groups(db)


# -------------------------------------------------
# Get Expenses for a Group
# -------------------------------------------------
@router.get("/{group_id}/expenses", response_model=List[schemas.ExpenseOut])
def get_group_expenses(
    group_id: UUID,
    db: Session = Depends(get_db)
):
    return crud.get_expenses_by_group(db, group_id)


# -------------------------------------------------
# Fairness / Group Health
# -------------------------------------------------
@router.get("/{group_id}/fairness")
def get_group_fairness(
    group_id: UUID,
    db: Session = Depends(get_db)
):
    expenses = (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .all()
    )

    if not expenses:
        return {
            "score": 100,
            "balances": {}
        }

    expense_data = [
        {
            "paid_by": e.paid_by,
            "total_amount": e.total_amount,
            "splits": [
                {"name": s.name, "amount": s.amount}
                for s in e.splits
            ]
        }
        for e in expenses
    ]

    balances = calculate_balances(expense_data)
    score = fairness_score(balances)

    return {
        "score": score,
        "balances": balances
    }


# -------------------------------------------------
# Settlements / Settle Up
# -------------------------------------------------
@router.get("/{group_id}/settlements")
def get_group_settlements(
    group_id: UUID,
    db: Session = Depends(get_db)
):
    expenses = (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .all()
    )

    if not expenses:
        return []

    expense_data = [
        {
            "paid_by": e.paid_by,
            "total_amount": e.total_amount,
            "splits": [
                {"name": s.name, "amount": s.amount}
                for s in e.splits
            ]
        }
        for e in expenses
    ]

    balances = calculate_balances(expense_data)
    settlements = calculate_settlements(balances)

    # Persist settlements
    crud.save_settlements(db, group_id, settlements)

    return settlements

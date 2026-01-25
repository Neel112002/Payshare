from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
from app.models import Settlement
from app.models import Settlement

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
@router.post("", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db)
):
    return crud.create_group(db, group)


# -------------------------------------------------
# List Groups
# -------------------------------------------------
@router.get("", response_model=List[schemas.GroupOut])
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
    expenses = crud.get_expenses_by_group(db, group_id)
    return expenses


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

    # Convert DB objects → plain dicts for fairness logic
    expense_data = []
    for e in expenses:
        expense_data.append({
            "paid_by": e.paid_by,
            "total_amount": e.total_amount,
            "splits": [
                {
                    "name": s.name,
                    "amount": s.amount
                }
                for s in e.splits
            ]
        })

    balances = calculate_balances(expense_data)
    score = fairness_score(balances)

    return {
        "score": score,
        "balances": balances
    }

def save_settlements(db, group_id, settlements):
    db.query(Settlement).filter(
        Settlement.group_id == group_id
    ).delete()

    for s in settlements:
        db.add(
            Settlement(
                id=uuid.uuid4(),
                group_id=group_id,
                from_user=s["from"],
                to_user=s["to"],
                amount=s["amount"]
            )
        )

    db.commit()

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

    expense_data = []
    for e in expenses:
        expense_data.append({
            "paid_by": e.paid_by,
            "total_amount": e.total_amount,
            "splits": [
                {"name": s.name, "amount": s.amount}
                for s in e.splits
            ]
        })

    balances = calculate_balances(expense_data)
    settlements = calculate_settlements(balances)

    crud.save_settlements(db, group_id, settlements)

    return settlements

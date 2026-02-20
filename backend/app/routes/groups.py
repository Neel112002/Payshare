from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.database import get_db
from app import schemas, crud
from app.models import Expense, Group, User
from app.auth.security import get_current_user
from app.fairness.balances import calculate_balances, fairness_score
from app.fairness.settlements import calculate_settlements

router = APIRouter(
    prefix="/groups",
    tags=["Groups"]
)

# -------------------------------------------------
# Create Group (SECURED)
# -------------------------------------------------
@router.post("/", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_group = Group(
        name=group.name,
        user_id=current_user.id
    )

    db.add(new_group)
    db.commit()
    db.refresh(new_group)

    return new_group


# -------------------------------------------------
# List Groups (SECURED)
# -------------------------------------------------
@router.get("/", response_model=List[schemas.GroupListResponse])
def list_groups(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    groups = (
        db.query(Group)
        .filter(Group.user_id == current_user.id)
        .all()
    )

    response = []

    for group in groups:
        expenses = crud.get_group_expenses_with_splits(db, group.id)

        balances = calculate_balances(expenses)
        score = fairness_score(balances)
        net_balance = round(sum(balances.values()), 2)

        response.append(
            schemas.GroupListResponse(
                id=group.id,
                name=group.name,
                balance=net_balance,
                fairness_score=score
            )
        )

    return response


# -------------------------------------------------
# Get Expenses for Group (SECURED)
# -------------------------------------------------
@router.get("/{group_id}/expenses", response_model=List[schemas.ExpenseOut])
def get_group_expenses(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
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

    return crud.get_expenses_by_group(db, group_id)


# -------------------------------------------------
# Fairness (SECURED)
# -------------------------------------------------
@router.get("/{group_id}/fairness")
def get_group_fairness(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
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
        .filter(Expense.group_id == group_id)
        .all()
    )

    if not expenses:
        return {"score": 100, "balances": {}}

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
# Settlements (SECURED)
# -------------------------------------------------
@router.get("/{group_id}/settlements")
def get_group_settlements(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
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

    crud.save_settlements(db, group_id, settlements)

    return settlements
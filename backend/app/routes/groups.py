from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.database import get_db
from app import schemas, crud
from app.models import Expense, Group, User, GroupMember
from app.auth.security import get_current_user
from app.fairness.balances import calculate_balances, fairness_score
from app.fairness.settlements import calculate_settlements

router = APIRouter(
    prefix="/groups",
    tags=["Groups"]
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
# Create Group
# -------------------------------------------------
@router.post("/", response_model=schemas.GroupOut)
def create_group(
    group: schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_group = Group(
        name=group.name,
        owner_id=current_user.id
    )

    db.add(new_group)
    db.commit()
    db.refresh(new_group)

    # Add owner as member
    owner_membership = GroupMember(
        group_id=new_group.id,
        user_id=current_user.id
    )

    db.add(owner_membership)
    db.commit()

    return new_group


# -------------------------------------------------
# List Groups (User Membership Based)
# -------------------------------------------------
@router.get("/", response_model=List[schemas.GroupListResponse])
def list_groups(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    memberships = (
        db.query(GroupMember)
        .filter(GroupMember.user_id == current_user.id)
        .all()
    )

    response = []

    for membership in memberships:
        group = (
            db.query(Group)
            .filter(Group.id == membership.group_id)
            .first()
        )

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
# Get Expenses for Group
# -------------------------------------------------
@router.get("/{group_id}/expenses", response_model=List[schemas.ExpenseOut])
def get_group_expenses(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    verify_membership(db, group_id, current_user.id)

    return crud.get_expenses_by_group(db, group_id)


# -------------------------------------------------
# Fairness
# -------------------------------------------------
@router.get("/{group_id}/fairness")
def get_group_fairness(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    verify_membership(db, group_id, current_user.id)

    expenses = (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .all()
    )

    if not expenses:
        return {"score": 100, "balances": {}}

    expense_data = [
        {
            "paid_by": str(e.paid_by),
            "total_amount": e.total_amount,
            "splits": [
                {"user_id": str(s.user_id), "amount": s.amount}
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
# Settlements
# -------------------------------------------------
@router.get("/{group_id}/settlements")
def get_group_settlements(
    group_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    verify_membership(db, group_id, current_user.id)

    expenses = (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .all()
    )

    if not expenses:
        return []

    expense_data = [
        {
            "paid_by": str(e.paid_by),
            "total_amount": e.total_amount,
            "splits": [
                {"user_id": str(s.user_id), "amount": s.amount}
                for s in e.splits
            ]
        }
        for e in expenses
    ]

    balances = calculate_balances(expense_data)
    settlements = calculate_settlements(balances)

    crud.save_settlements(db, group_id, settlements)

    return settlements
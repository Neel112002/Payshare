from sqlalchemy.orm import Session
from uuid import UUID
import uuid

from app.models import Group, Expense, ExpenseSplit, Settlement
from app.schemas import GroupCreate, ExpenseCreate


# --------------------
# GROUPS
# --------------------

def create_group(db: Session, group: GroupCreate):
    db_group = Group(name=group.name)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return db_group


def get_groups(db: Session):
    return db.query(Group).order_by(Group.created_at.desc()).all()


def get_group_by_id(db: Session, group_id: UUID):
    return db.query(Group).filter(Group.id == group_id).first()


def get_group_expenses_with_splits(db: Session, group_id: UUID):
    """
    Returns expenses in UUID-based structure:
    [
        {
            "paid_by": UUID,
            "total_amount": float,
            "splits": [
                { "user_id": UUID, "amount": float }
            ]
        }
    ]
    """

    expenses = (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .all()
    )

    result = []

    for expense in expenses:
        splits = (
            db.query(ExpenseSplit)
            .filter(ExpenseSplit.expense_id == expense.id)
            .all()
        )

        result.append({
            "paid_by": expense.paid_by,
            "total_amount": expense.total_amount,
            "splits": [
                {
                    "user_id": split.user_id,
                    "amount": split.amount
                }
                for split in splits
            ]
        })

    return result


# --------------------
# EXPENSES
# --------------------

def create_expense(db: Session, expense: ExpenseCreate):
    db_expense = Expense(
        group_id=expense.group_id,
        title=expense.title,
        total_amount=expense.total_amount,
        paid_by=expense.paid_by
    )

    db.add(db_expense)
    db.flush()  # ensures db_expense.id exists

    for split in expense.splits:
        db.add(
            ExpenseSplit(
                expense_id=db_expense.id,
                user_id=split.user_id,
                amount=split.amount
            )
        )

    db.commit()
    db.refresh(db_expense)
    return db_expense


def get_expenses_by_group(db: Session, group_id: UUID):
    return (
        db.query(Expense)
        .filter(Expense.group_id == group_id)
        .order_by(Expense.created_at.desc())
        .all()
    )


# --------------------
# SETTLEMENTS
# --------------------

def save_settlements(db: Session, group_id: UUID, settlements: list):

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
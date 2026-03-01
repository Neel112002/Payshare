from sqlalchemy.orm import Session
from sqlalchemy import func
from uuid import UUID
from decimal import Decimal
import uuid

from app import models, schemas


# =====================================================
# GROUPS
# =====================================================

def create_group(db: Session, group: schemas.GroupCreate, creator_id: UUID):
    db_group = models.Group(
        name=group.name,
        base_currency=group.base_currency,
        created_by=creator_id
    )
    db.add(db_group)
    db.flush()

    # Add creator as owner
    db.add(models.GroupMember(
        group_id=db_group.id,
        user_id=creator_id,
        role=models.GroupRole.owner
    ))

    db.commit()
    db.refresh(db_group)
    return db_group


def get_groups(db: Session):
    return db.query(models.Group)\
        .filter(models.Group.is_active == True)\
        .order_by(models.Group.created_at.desc())\
        .all()


# =====================================================
# EXPENSES
# =====================================================

def create_expense(db: Session, expense: schemas.ExpenseCreate):

    # 1️⃣ Create expense
    db_expense = models.Expense(
        group_id=expense.group_id,
        title=expense.title,
        total_amount=expense.total_amount,
        paid_by=expense.paid_by,
        version=1
    )

    db.add(db_expense)
    db.flush()

    # 2️⃣ Create splits
    for split in expense.splits:
        db.add(models.ExpenseSplit(
            expense_id=db_expense.id,
            user_id=split.user_id,
            amount=split.amount
        ))

        # 3️⃣ Create ledger entry
        # Split user owes paid_by
        if split.user_id != expense.paid_by:
            db.add(models.LedgerEntry(
                group_id=expense.group_id,
                from_user=split.user_id,
                to_user=expense.paid_by,
                amount=split.amount,
                reference_type=models.LedgerReferenceType.expense,
                reference_id=db_expense.id
            ))

    db.commit()
    db.refresh(db_expense)
    return db_expense


def update_expense(db: Session, expense_id: UUID, update: schemas.ExpenseUpdate):

    old_expense = db.query(models.Expense)\
        .filter(models.Expense.id == expense_id,
                models.Expense.is_active == True)\
        .first()

    if not old_expense:
        return None

    # 1️⃣ Soft delete old expense
    old_expense.is_active = False

    # 2️⃣ Reverse old ledger entries
    old_ledgers = db.query(models.LedgerEntry)\
        .filter(models.LedgerEntry.reference_id == expense_id,
                models.LedgerEntry.is_active == True)\
        .all()

    for entry in old_ledgers:
        entry.is_active = False

        # Insert reversal entry
        db.add(models.LedgerEntry(
            group_id=entry.group_id,
            from_user=entry.to_user,
            to_user=entry.from_user,
            amount=entry.amount,
            reference_type=models.LedgerReferenceType.adjustment,
            reference_id=expense_id
        ))

    # 3️⃣ Create new version
    new_expense = models.Expense(
        group_id=old_expense.group_id,
        title=update.title or old_expense.title,
        total_amount=update.total_amount or old_expense.total_amount,
        paid_by=update.paid_by or old_expense.paid_by,
        version=old_expense.version + 1
    )

    db.add(new_expense)
    db.flush()

    splits = update.splits or []

    for split in splits:
        db.add(models.ExpenseSplit(
            expense_id=new_expense.id,
            user_id=split.user_id,
            amount=split.amount
        ))

        if split.user_id != new_expense.paid_by:
            db.add(models.LedgerEntry(
                group_id=new_expense.group_id,
                from_user=split.user_id,
                to_user=new_expense.paid_by,
                amount=split.amount,
                reference_type=models.LedgerReferenceType.expense,
                reference_id=new_expense.id
            ))

    db.commit()
    db.refresh(new_expense)
    return new_expense


# =====================================================
# SETTLEMENTS
# =====================================================

def create_settlement(db: Session, settlement: schemas.SettlementCreate):

    db_settlement = models.Settlement(
        group_id=settlement.group_id,
        from_user=settlement.from_user,
        to_user=settlement.to_user,
        amount=settlement.amount
    )

    db.add(db_settlement)
    db.flush()

    # Ledger entry
    db.add(models.LedgerEntry(
        group_id=settlement.group_id,
        from_user=settlement.from_user,
        to_user=settlement.to_user,
        amount=settlement.amount,
        reference_type=models.LedgerReferenceType.settlement,
        reference_id=db_settlement.id
    ))

    db.commit()
    db.refresh(db_settlement)
    return db_settlement


# =====================================================
# BALANCES (Ledger Based)
# =====================================================

def get_group_balances(db: Session, group_id: UUID):

    entries = db.query(models.LedgerEntry)\
        .filter(models.LedgerEntry.group_id == group_id,
                models.LedgerEntry.is_active == True)\
        .all()

    balances = {}

    for entry in entries:
        balances.setdefault(entry.from_user, Decimal("0"))
        balances.setdefault(entry.to_user, Decimal("0"))

        balances[entry.from_user] -= entry.amount
        balances[entry.to_user] += entry.amount

    return balances


# =====================================================
# EXPENSE LISTING
# =====================================================

def get_expenses_by_group(db: Session, group_id: UUID):

    expenses = db.query(models.Expense)\
        .filter(models.Expense.group_id == group_id,
                models.Expense.is_active == True)\
        .order_by(models.Expense.created_at.desc())\
        .all()

    result = []

    for expense in expenses:
        splits = db.query(models.ExpenseSplit)\
            .filter(models.ExpenseSplit.expense_id == expense.id,
                    models.ExpenseSplit.is_active == True)\
            .all()

        result.append({
            "id": expense.id,
            "group_id": expense.group_id,
            "title": expense.title,
            "total_amount": expense.total_amount,
            "paid_by": expense.paid_by,
            "version": expense.version,
            "created_at": expense.created_at,
            "updated_at": expense.updated_at,
            "splits": splits
        })

    return result
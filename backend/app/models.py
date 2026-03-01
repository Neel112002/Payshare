import uuid
from datetime import datetime

from sqlalchemy import (
    Column,
    String,
    DateTime,
    ForeignKey,
    Boolean,
    Integer,
    Numeric,
    Enum,
    UniqueConstraint
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base
import enum


# -----------------------------
# ENUMS
# -----------------------------

class GroupRole(str, enum.Enum):
    owner = "owner"
    admin = "admin"
    member = "member"


class LedgerReferenceType(str, enum.Enum):
    expense = "expense"
    settlement = "settlement"
    adjustment = "adjustment"


# -----------------------------
# USERS
# -----------------------------

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


# -----------------------------
# GROUPS
# -----------------------------

class Group(Base):
    __tablename__ = "groups"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    base_currency = Column(String, nullable=False)

    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# -----------------------------
# GROUP MEMBERS
# -----------------------------

class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    role = Column(Enum(GroupRole), default=GroupRole.member)

    joined_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

    __table_args__ = (
        UniqueConstraint("group_id", "user_id", name="uq_group_user"),
    )


# -----------------------------
# EXPENSES (VERSIONED)
# -----------------------------

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"))
    title = Column(String, nullable=False)

    total_amount = Column(Numeric(12, 2), nullable=False)
    paid_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    version = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)

    # ✅ THIS FIXES YOUR ERROR
    splits = relationship(
        "ExpenseSplit",
        back_populates="expense",
        cascade="all, delete-orphan"
    )


# -----------------------------
# EXPENSE SPLITS
# -----------------------------

class ExpenseSplit(Base):
    __tablename__ = "expense_splits"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    expense_id = Column(UUID(as_uuid=True), ForeignKey("expenses.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    amount = Column(Numeric(12, 2), nullable=False)
    is_active = Column(Boolean, default=True)

    # ✅ REQUIRED FOR ORM SERIALIZATION
    expense = relationship(
        "Expense",
        back_populates="splits"
    )


# -----------------------------
# LEDGER ENTRIES (CORE ENGINE)
# -----------------------------

class LedgerEntry(Base):
    __tablename__ = "ledger_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"))

    from_user = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    to_user = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    amount = Column(Numeric(12, 2), nullable=False)

    reference_type = Column(Enum(LedgerReferenceType), nullable=False)
    reference_id = Column(UUID(as_uuid=True))

    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# -----------------------------
# SETTLEMENTS
# -----------------------------

class Settlement(Base):
    __tablename__ = "settlements"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"))

    from_user = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    to_user = Column(UUID(as_uuid=True), ForeignKey("users.id"))

    amount = Column(Numeric(12, 2), nullable=False)

    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)
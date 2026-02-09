import uuid
from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from .database import Base


class Group(Base):
    __tablename__ = "groups"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class Expense(Base):
    __tablename__ = "expenses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    group_id = Column(UUID(as_uuid=True), ForeignKey("groups.id"))
    title = Column(String, nullable=False)
    total_amount = Column(Float, nullable=False)
    paid_by = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    # ✅ ADD THIS
    splits = relationship(
        "ExpenseSplit",
        back_populates="expense",
        cascade="all, delete-orphan"
    )


class ExpenseSplit(Base):
    __tablename__ = "expense_splits"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    expense_id = Column(UUID(as_uuid=True), ForeignKey("expenses.id"))
    name = Column(String, nullable=False)
    amount = Column(Float, nullable=False)

    # ✅ ADD THIS
    expense = relationship("Expense", back_populates="splits")


class Settlement(Base):
    __tablename__ = "settlements"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    group_id = Column(UUID(as_uuid=True))
    from_user = Column(String, nullable=False)
    to_user = Column(String, nullable=False)
    amount = Column(Float, nullable=False)
    created_at = Column(DateTime, server_default=func.now())

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
from pydantic import BaseModel, EmailStr, Field
from uuid import UUID
from datetime import datetime
from typing import List, Optional
from decimal import Decimal
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
# USER SCHEMAS
# -----------------------------

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: UUID
    name: str
    email: EmailStr
    created_at: datetime

    class Config:
        from_attributes = True


# -----------------------------
# GROUP SCHEMAS
# -----------------------------

class GroupCreate(BaseModel):
    name: str
    base_currency: str


class GroupOut(BaseModel):
    id: UUID
    name: str
    base_currency: str
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# -----------------------------
# GROUP MEMBER SCHEMAS
# -----------------------------

class GroupMemberOut(BaseModel):
    id: UUID
    group_id: UUID
    user_id: UUID
    role: GroupRole
    joined_at: datetime

    class Config:
        from_attributes = True


# -----------------------------
# EXPENSE SPLITS
# -----------------------------

class ExpenseSplitCreate(BaseModel):
    user_id: UUID
    amount: Decimal = Field(..., gt=0)


class ExpenseSplitOut(BaseModel):
    user_id: UUID
    amount: Decimal

    class Config:
        from_attributes = True


# -----------------------------
# EXPENSE SCHEMAS
# -----------------------------

class ExpenseCreate(BaseModel):
    group_id: UUID
    title: str
    total_amount: Decimal = Field(..., gt=0)
    paid_by: UUID
    splits: List[ExpenseSplitCreate]


class ExpenseUpdate(BaseModel):
    title: Optional[str]
    total_amount: Optional[Decimal]
    paid_by: Optional[UUID]
    splits: Optional[List[ExpenseSplitCreate]]


class ExpenseOut(BaseModel):
    id: UUID
    group_id: UUID
    title: str
    total_amount: Decimal
    paid_by: UUID
    version: int
    created_at: datetime
    updated_at: datetime
    splits: List[ExpenseSplitOut]

    class Config:
        from_attributes = True


# -----------------------------
# SETTLEMENT SCHEMAS
# -----------------------------

class SettlementCreate(BaseModel):
    group_id: UUID
    from_user: UUID
    to_user: UUID
    amount: Decimal = Field(..., gt=0)


class SettlementOut(BaseModel):
    id: UUID
    group_id: UUID
    from_user: UUID
    to_user: UUID
    amount: Decimal
    created_at: datetime

    class Config:
        from_attributes = True


# -----------------------------
# BALANCE RESPONSE
# -----------------------------

class BalanceOut(BaseModel):
    user_id: UUID
    balance: Decimal


# -----------------------------
# AUTH SCHEMAS
# -----------------------------

class TokenResponse(BaseModel):
    access_token: str
    token_type: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


# -----------------------------
# USER UPDATE / PROFILE
# -----------------------------

class UserUpdate(BaseModel):
    name: str
    email: EmailStr


class UpdateProfileRequest(BaseModel):
    name: str
    email: EmailStr


class DeleteAccountRequest(BaseModel):
    password: str
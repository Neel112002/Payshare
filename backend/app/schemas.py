from pydantic import BaseModel, EmailStr
from typing import List
from uuid import UUID
from datetime import datetime


# =========================
# AUTH SCHEMAS
# =========================

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


class UserOut(BaseModel):
    id: UUID
    name: str
    email: str

    class Config:
        from_attributes = True


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class UserUpdate(BaseModel):
    name: str
    email: EmailStr


# =========================
# GROUP SCHEMAS
# =========================

class GroupCreate(BaseModel):
    name: str


class GroupOut(BaseModel):
    id: UUID
    name: str
    created_at: datetime

    class Config:
        from_attributes = True


class GroupListResponse(BaseModel):
    id: UUID
    name: str
    balance: float
    fairness_score: int


# =========================
# EXPENSE SCHEMAS (UUID BASED)
# =========================

class ExpenseSplitCreate(BaseModel):
    user_id: UUID
    amount: float


class ExpenseCreate(BaseModel):
    group_id: UUID
    title: str
    total_amount: float
    paid_by: UUID
    splits: List[ExpenseSplitCreate]


class ExpenseSplitOut(BaseModel):
    user_id: UUID
    amount: float

    class Config:
        from_attributes = True


class ExpenseOut(BaseModel):
    id: UUID
    title: str
    total_amount: float
    paid_by: UUID
    created_at: datetime
    splits: List[ExpenseSplitOut]

    class Config:
        from_attributes = True


class ExpenseResponse(BaseModel):
    id: UUID
    title: str
    total_amount: float
    paid_by: UUID

    class Config:
        from_attributes = True
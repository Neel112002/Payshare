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


class Token(BaseModel):
    access_token: str
    token_type: str


class UserOut(BaseModel):
    id: UUID
    name: str
    email: str

    model_config = {
        "from_attributes": True,
        "json_encoders": {
            UUID: lambda v: str(v)
        }
    }


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
# EXPENSE SCHEMAS
# =========================

class SplitCreate(BaseModel):
    name: str
    amount: float


class ExpenseCreate(BaseModel):
    group_id: UUID
    title: str
    total_amount: float
    paid_by: str
    splits: List[SplitCreate]


class ExpenseSplitOut(BaseModel):
    name: str
    amount: float

    class Config:
        from_attributes = True


class ExpenseOut(BaseModel):
    id: UUID
    title: str
    total_amount: float
    paid_by: str
    created_at: datetime
    splits: List[ExpenseSplitOut]

    class Config:
        from_attributes = True


class ExpenseResponse(BaseModel):
    id: UUID
    title: str
    total_amount: float
    paid_by: str

    class Config:
        from_attributes = True

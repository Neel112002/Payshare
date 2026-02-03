from pydantic import BaseModel
from typing import List
from uuid import UUID
from datetime import datetime


class SplitCreate(BaseModel):
    name: str
    amount: float


class ExpenseCreate(BaseModel):
    group_id: UUID
    title: str
    total_amount: float
    paid_by: str
    splits: List[SplitCreate]


class ExpenseResponse(BaseModel):
    id: UUID
    title: str
    total_amount: float
    paid_by: str

    class Config:
        orm_mode = True

class GroupCreate(BaseModel):
    name: str

class GroupOut(BaseModel):
    id: UUID
    name: str
    created_at: datetime

    class Config:
        from_attributes = True  # pydantic v2

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

class GroupListResponse(BaseModel):
    id: UUID
    name: str
    balance: float
    fairness_score: int
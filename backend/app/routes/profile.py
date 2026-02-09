from fastapi import APIRouter
from app.schemas import UserOut
from uuid import uuid4

router = APIRouter()

@router.get("/me", response_model=UserOut)
def get_me():
    return UserOut(
        id=uuid4(),
        name="Neel",
        email="neel@example.com"
    )

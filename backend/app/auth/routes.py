from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(data: LoginRequest):
    # Temporary fake login
    if data.email == "neel@example.com" and data.password == "123456":
        return {
            "access_token": "fake-super-secret-token",
            "token_type": "bearer"
        }

    return {"error": "Invalid credentials"}

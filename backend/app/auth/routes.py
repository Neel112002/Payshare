from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas
from app.auth.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_reset_token,
    validate_password_strength   # ✅ fixed import
)
from jose import jwt, JWTError
from app.auth.security import SECRET_KEY, ALGORITHM

router = APIRouter(prefix="/auth", tags=["Auth"])


# -----------------------
# Register
# -----------------------

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):

    # 🔐 Strong password validation
    errors = validate_password_strength(user.password)
    if errors:
        raise HTTPException(
            status_code=400,
            detail=errors
        )

    existing = db.query(models.User).filter(
        models.User.email == user.email
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = models.User(
        name=user.name,
        email=user.email,
        hashed_password=hash_password(user.password)
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


# -----------------------
# Login
# -----------------------

@router.post("/login", response_model=schemas.TokenResponse)
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):

    db_user = db.query(models.User).filter(
        models.User.email == user.email
    ).first()

    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": str(db_user.id)})

    return {
        "access_token": token,
        "token_type": "bearer"
    }


# -----------------------
# Forgot Password
# -----------------------

@router.post("/forgot-password")
def forgot_password(
    request: schemas.ForgotPasswordRequest,
    db: Session = Depends(get_db)
):

    user = db.query(models.User).filter(
        models.User.email == request.email
    ).first()

    # 🔒 Do not reveal whether email exists
    if not user:
        return {"message": "If email exists, reset link sent."}

    reset_token = create_reset_token(user.email)

    return {
        "message": "Reset token generated (dev mode)",
        "reset_token": reset_token
    }


# -----------------------
# Reset Password
# -----------------------

@router.post("/reset-password")
def reset_password(
    request: schemas.ResetPasswordRequest,
    db: Session = Depends(get_db)
):

    try:
        payload = jwt.decode(
            request.token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )
        email = payload.get("sub")

    except JWTError:
        raise HTTPException(
            status_code=400,
            detail="Invalid or expired token"
        )

    user = db.query(models.User).filter(
        models.User.email == email
    ).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 🔐 Strong password validation
    errors = validate_password_strength(request.new_password)
    if errors:
        raise HTTPException(
            status_code=400,
            detail=errors
        )

    user.hashed_password = hash_password(request.new_password)
    db.commit()

    return {"message": "Password reset successful"}
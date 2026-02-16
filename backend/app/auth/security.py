import os
from datetime import datetime, timedelta

from passlib.context import CryptContext
from jose import jwt, JWTError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# 🔐 Environment-based config
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

# Password hashing setup
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

# ==============================
# 🔑 Password Hashing
# ==============================

def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


# ==============================
# 🎟️ JWT Token Creation
# ==============================

def create_access_token(data: dict) -> str:
    to_encode = data.copy()

    expire = datetime.utcnow() + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES
    )

    to_encode.update({"exp": expire})

    encoded_jwt = jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    return encoded_jwt

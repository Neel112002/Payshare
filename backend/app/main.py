from fastapi import FastAPI

from .database import Base, engine
from .routes import groups, expenses

# -------------------------------------------------
# Create DB tables (DEV ONLY – later move to Alembic)
# -------------------------------------------------
Base.metadata.create_all(bind=engine)

# -------------------------------------------------
# App
# -------------------------------------------------
app = FastAPI(
    title="PayShare Backend",
    version="0.1.0"
)

# -------------------------------------------------
# Routers
# -------------------------------------------------
# ❗ FIX: do NOT add prefix here because it's already in groups.py
app.include_router(groups.router)
app.include_router(expenses.router)

# -------------------------------------------------
# Health Check
# -------------------------------------------------
@app.get("/")
def root():
    return {
        "status": "ok",
        "service": "PayShare backend",
        "message": "Backend running 🚀"
    }

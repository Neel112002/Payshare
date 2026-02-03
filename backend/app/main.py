from fastapi import FastAPI

from .database import Base, engine
from .routes import groups, expenses

# -------------------------------------------------
# DEV ONLY: Reset DB on startup
# ⚠️ This deletes ALL data every restart
# -------------------------------------------------
Base.metadata.drop_all(bind=engine)
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

from fastapi import FastAPI

from .database import Base, engine
from .routes import groups, expenses
from app.routes import profile
from app.auth import routes as auth


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="PayShare Backend",
    version="0.1.0"
)

# Routers
app.include_router(groups.router)
app.include_router(expenses.router)
app.include_router(profile.router)
app.include_router(auth.router, prefix="/auth", tags=["Auth"])

# Health Check

@app.get("/")
def root():
    return {
        "status": "ok",
        "service": "PayShare backend",
        "message": "Backend running 🚀"
    }

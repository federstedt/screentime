# se __init__ för deklaration av app (den är av FastAPI klassen)
import threading, time
from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session
from fasttime import app

from .functions.tracker_loop import GameMonitor
from . import models
from .db import SessionLocal, engine
from .auth import get_user
from .routers import public, secure

# Skapa tabeller
models.Base.metadata.create_all(bind=engine)


# Dependency: varje req får en db-session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


app.include_router(public.router, prefix="/v1/public")

app.include_router(secure.router, prefix="/v1/secure", dependencies=[Depends(get_user)])


# --- Background monitor ---
monitor = GameMonitor(interval=5)
monitor.start()

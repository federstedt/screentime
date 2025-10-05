# se __init__ för deklaration av app (den är av FastAPI klassen)
import threading, time
from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session
from fasttime import app

from .functions.proc_functions import get_running_games_dict
from . import models, schemas, crud
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
def monitor_games(interval=5):
    while True:
        games = get_running_games_dict()
        print(games)  # byt ut mot loggning till DB
        time.sleep(interval)

threading.Thread(target=monitor_games, daemon=True).start()

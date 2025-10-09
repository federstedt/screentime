# se __init__ för deklaration av app (den är av FastAPI klassen)
from fastapi import Depends, FastAPI
from contextlib import asynccontextmanager

from .functions.tracker_loop import GameMonitor
from . import models
from .db import SessionLocal, engine
from .auth import get_user
from .routers import public, secure

# Skapa tabeller
models.Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Starta GameMonitor alltid
    if not hasattr(app.state, "monitor"):
        print("🧩 GameMonitor started.")
        monitor = GameMonitor(interval=5)
        monitor.cleanup_unfinished()
        monitor.start()
        app.state.monitor = monitor
    yield
    # Stoppa monitorn vid shutdown
    if hasattr(app.state, "monitor"):
        app.state.monitor.stop()
    print("🛑 FastAPI shutting down.")

app = FastAPI(title="Screentime API", lifespan=lifespan)



app.include_router(public.router, prefix="/v1/public")

app.include_router(secure.router, prefix="/v1/secure", dependencies=[Depends(get_user)])

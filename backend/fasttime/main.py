# se __init__ för deklaration av app (den är av FastAPI klassen)
from fastapi import Depends, FastAPI

from fasttime import app

from .auth import get_user
from .routers import public, secure

app.include_router(public.router, prefix="/v1/public")

app.include_router(secure.router, prefix="/v1/secure", dependencies=[Depends(get_user)])

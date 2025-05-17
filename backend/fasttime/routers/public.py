from fastapi import APIRouter
from fastapi.responses import JSONResponse
import psutil

router = APIRouter()


@router.get("/")
async def get_testroute():
    return "OK"


@router.get("/processes")
async def get_processes():
    procs = []
    for proc in psutil.process_iter(["pid", "name", "username"]):
        print(proc.info)
        procs.append(
            {"pid": proc.pid, "name": proc.name(), "username": proc.username()}
        )

    return JSONResponse(content=procs)

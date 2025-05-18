from fastapi import APIRouter
from fastapi.responses import JSONResponse
import psutil
import time

router = APIRouter()


@router.get("/")
async def get_testroute():
    return "OK"


@router.get("/procs/")
async def get_processes():
    """
    Get all running processes
    """
    procs = []
    for proc in psutil.process_iter(["pid", "name", "username", "create_time"]):
        print(proc.info)
        procs.append(
            {
                "pid": proc.pid,
                "name": proc.name(),
                "username": proc.username(),
                "create_time": time.strftime(
                    "%Y-%m-%d %H:%M:%S", time.localtime(proc.create_time())
                ),
            }
        )

    return JSONResponse(content=procs)

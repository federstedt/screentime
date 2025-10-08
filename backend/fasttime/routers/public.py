from psutil import NoSuchProcess
from fastapi import APIRouter
from fastapi.exceptions import HTTPException
from fastapi.responses import JSONResponse
from ..functions.proc_functions import (
    get_all_procs_dict,
    get_proc_by_name,
    get_running_games,
    get_running_games_dict,
    kill_all_games,
    proc_to_dict,
    kill_proc_by_pid,
)

router = APIRouter()


#### ROUTES


@router.get("/")
def get_testroute():
    return "OK"


@router.get("/live/procs/")
def get_processes_route():
    """
    Get all running processes
    """
    procs = get_all_procs_dict()

    return JSONResponse(content=procs)


@router.get("/live/games/")
def get_running_games_route():
    """
    Get all running games from processes.
    Definition of a game is a internal db.
    """
    games = get_running_games_dict()
    return JSONResponse(content=games)


@router.get("/live/procs/{poc_name}")
def get_proc_by_name_route(proc_name: str):
    """
    Get proc by name. As costly as getting all and filtering though as of now.
    Since in backend we do get all first.
    """
    proc = get_proc_by_name(proc_name)
    if proc is None:
        raise HTTPException(
            status_code=404, detail=f"No such process found: {proc_name}"
        )

    proc_dict = proc_to_dict(proc)

    return JSONResponse(content=proc_dict)


@router.post("/live/kill/{pid}")
def kill_proc_by_pid_route(pid: int):
    """
    Kill process by using pid.
    """
    try:
        result = kill_proc_by_pid(pid)
    except NoSuchProcess as exc:
        raise HTTPException(
            status_code=404, detail=f"No such process found: {pid}"
        ) from exc

    if result:
        return {"message": "success"}
    else:
        raise HTTPException(status_code=404, detail=f"No such process found: {pid}")


@router.post("/live/games/kill-all")
def kill_all_game_procs_route():
    """
    Kill all processes that are defined as games.
    """
    if kill_all_games():
        return {"message": "success"}
    else:
        raise HTTPException(status_code=500, detail="Unhandled internal error")


@router.get("/stats/apps")
def get_all_sessions():
    """
    Get all sessions from db.
    """
    pass

# Monitoring and handling processes.
import psutil
import time

MONIT_PROCS = {"steam"}


def get_all_processes():
    """
    Get all running processes.
    """
    all_procs = psutil.process_iter(["pid", "name", "username", "create_time"])
    return all_procs


def get_proc_by_name(proc_name: str):
    """
    Get proc by name. Costly for now since we first get all.
    """
    all_procs = get_all_processes()
    for proc in all_procs:
        if proc_name in proc.info["name"]:
            return proc


def kill_proc_by_pid(pid: int):
    """
    Get proc by pid and kill it.
    """
    all_procs = get_all_processes()
    for proc in all_procs:
        print(proc.info)
        if proc.info["pid"] == pid:
            proc.kill()
            return True


def proc_to_dict(proc) -> dict:
    """
    Convert psutil.Process to dict
    """
    proc_dict = {
        "pid": proc.pid,
        "name": proc.name(),
        "username": proc.username(),
        "path": proc.exe(),
        "create_time": time.strftime(
            "%Y-%m-%d %H:%M:%S", time.localtime(proc.create_time())
        ),
        "run_time": calc_run_time(proc.create_time()),
    }
    return proc_dict


def calc_run_time(e_time: float) -> float:
    """
    From proc epochtime, calculate how long a proc has been
    running for.
    """
    print(e_time)
    print(time.time())
    return e_time


def get_all_procs_dict() -> list[dict]:
    """
    Get all running processes.
    Return an list of dict with processes
    """
    procs = []
    for proc in get_all_processes():
        print(proc.info)
        procs.append(proc_to_dict(proc))
    return procs


def get_running_games():
    """
    Get games running on the system from procs.
    """
    games = []
    for proc in get_all_processes():
        if proc.info["name"] in MONIT_PROCS:
            games.append(proc)

    return games


def get_running_games_dict():
    """
    Get all games running and return as dict.
    """
    games = get_running_games()
    games_dict = {}
    for game in games:
        games_dict[game.info["name"]] = proc_to_dict(game)

    return games_dict


def kill_all_games():
    """
    Kill are processes that are games.
    """
    all_games = get_running_games()
    for game in all_games:
        game.kill()

    return True

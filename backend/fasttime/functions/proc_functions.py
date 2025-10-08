# Monitoring and handling processes.
import psutil
import time
import getpass

MONIT_PROCS = {"steam", "godot"}
CURRENT_USER = getpass.getuser()


def get_all_processes():
    """
    Return only processes that belong to the current user.
    Skips system processes to avoid AccessDenied errors.
    """
    for proc in psutil.process_iter(["pid", "name", "username", "create_time", "exe"]):
        try:
            if proc.info.get("username") == CURRENT_USER:
                yield proc
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            continue


def get_proc_by_name(proc_name: str):
    """
    Return the first process that matches the given name.
    """
    for proc in get_all_processes():
        name = proc.info.get("name", "").lower()
        if proc_name.lower() in name:
            return proc


def kill_proc_by_pid(pid: int):
    """
    Kill a process by PID if it belongs to current user.
    """
    for proc in get_all_processes():
        if proc.info.get("pid") == pid:
            try:
                proc.kill()
                return True
            except psutil.AccessDenied:
                print(f"No permission to kill PID {pid}")
                return False
    return False


def calc_run_time(e_time: float) -> float:
    """Return how long (in seconds) a process has been running."""
    return time.time() - e_time


def proc_to_dict(proc) -> dict:
    """
    Convert psutil.Process to dict safely.
    """
    try:
        return {
            "pid": proc.pid,
            "name": proc.info.get("name", ""),
            "username": proc.info.get("username", ""),
            "path": proc.info.get("exe", ""),
            "create_time": time.strftime(
                "%Y-%m-%d %H:%M:%S", time.localtime(proc.create_time())
            ),
            "run_time": calc_run_time(proc.create_time()),
        }
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        return {}


def get_all_procs_dict() -> list[dict]:
    """
    Return all running processes as a list of dicts.
    """
    return [proc_to_dict(proc) for proc in get_all_processes()]


def get_running_games():
    """
    Get monitored processes currently running.
    """
    games = []
    for proc in get_all_processes():
        name = proc.info.get("name", "").lower()
        if name in MONIT_PROCS:
            games.append(proc)
    return games


def get_running_games_dict():
    """
    Return all monitored processes as dict.
    """
    games_dict = {}
    for game in get_running_games():
        games_dict[game.info.get("name", "unknown")] = proc_to_dict(game)
    return games_dict


def kill_all_games():
    """
    Kill all monitored processes.
    """
    for game in get_running_games():
        try:
            game.kill()
        except psutil.AccessDenied:
            print(f"No permission to kill {game.info.get('name')}")
    return True

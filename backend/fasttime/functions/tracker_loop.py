import threading
import time
from .proc_functions import get_running_games_dict
from ..db import SessionLocal
from .. import crud, models


class GameMonitor:
    def __init__(self, interval=5):
        self.interval = interval
        self.running_sessions = {}  # app_name -> session_obj

    def run(self):
        db = SessionLocal()
        while True:
            games = get_running_games_dict()

            # Kolla aktiva spel
            for name, info in games.items():
                if name not in self.running_sessions:
                    # Ny session start
                    session = crud.start_session(
                        db, info["name"], info["path"], window_title=info["name"]
                    )
                    self.running_sessions[name] = session

            # Kolla om något spel stängts
            for name in list(self.running_sessions.keys()):
                if name not in games:
                    # Avsluta session
                    crud.end_session(db, self.running_sessions[name])
                    del self.running_sessions[name]

            time.sleep(self.interval)

    def start(self):
        """
        Start a thread of the run function.
        """
        threading.Thread(target=self.run, daemon=True).start()

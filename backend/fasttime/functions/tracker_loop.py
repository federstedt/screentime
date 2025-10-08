import threading
import time
from datetime import datetime, timezone, timedelta
from .proc_functions import get_running_games_dict
from ..db import SessionLocal
from .. import crud, models

MIN_RUN_SECONDS = 1 * 60  # 5 minuter


class GameMonitor:
    def __init__(self, interval=5):
        self.interval = interval
        # app_name -> {"start_seen": datetime, "session": models.Session or None}
        self.running_sessions = {}

    def run(self):
        db = SessionLocal()
        while True:
            games = get_running_games_dict()
            now = datetime.now(timezone.utc)

            # Kolla aktiva spel
            for name, info in games.items():
                if name not in self.running_sessions:
                    # Första gången vi ser processen, spara starttid i minnet
                    self.running_sessions[name] = {"start_seen": now, "session": None}
                else:
                    entry = self.running_sessions[name]
                    # Om session inte redan är skapad och tiden >= MIN_RUN_SECONDS
                    if entry["session"] is None:
                        elapsed = (now - entry["start_seen"]).total_seconds()
                        if elapsed >= MIN_RUN_SECONDS:
                            # Skapa session i DB
                            session = crud.start_session(
                                db,
                                name=info["name"],
                                path=info["path"],
                                window_title=info["name"],
                            )
                            entry["session"] = session
                            print(
                                f"▶️ Startade session för {name} efter {elapsed / 60:.1f} min"
                            )

            # Kolla om något spel stängts
            for name in list(self.running_sessions.keys()):
                if name not in games:
                    entry = self.running_sessions[name]
                    if entry["session"] is not None:
                        crud.end_session(db, entry["session"])
                        print(f"⏹️ Avslutade session för {name}")
                    # Ta bort från minnet oavsett om session skapades eller ej
                    del self.running_sessions[name]

            time.sleep(self.interval)

    def start(self):
        threading.Thread(target=self.run, daemon=True).start()

import threading
import time
from datetime import datetime, timezone
from .proc_functions import get_running_games_dict
from ..db import SessionLocal, get_db
from .. import crud

MIN_RUN_SECONDS = 1 * 60  # 1 minut för test (ändra till 5 * 60 sen)

class GameMonitor:
    def __init__(self, interval=5):
        self.interval = interval
        self.running_sessions = {}
        self._stop_event = threading.Event()  # 👈 nytt: för att stoppa tråden
        self.thread = None

    def run(self):
        db = SessionLocal()
        while not self._stop_event.is_set():  # 👈 loopar tills stop_event triggas
            games = get_running_games_dict()
            now = datetime.now(timezone.utc)

            # Kolla aktiva spel
            for name, info in games.items():
                if name not in self.running_sessions:
                    self.running_sessions[name] = {"start_seen": now, "session": None}
                else:
                    entry = self.running_sessions[name]
                    if entry["session"] is None:
                        elapsed = (now - entry["start_seen"]).total_seconds()
                        if elapsed >= MIN_RUN_SECONDS:
                            session = crud.start_session(
                                db,
                                name=info["name"],
                                path=info["path"],
                                window_title=info["name"],
                            )
                            entry["session"] = session
                            print(f"▶️ Startade session för {name} efter {elapsed/60:.1f} min")

            # Kolla avslutade spel
            for name in list(self.running_sessions.keys()):
                if name not in games:
                    entry = self.running_sessions[name]
                    if entry["session"] is not None:
                        crud.end_session(db, entry["session"])
                        print(f"⏹️ Avslutade session för {name}")
                    del self.running_sessions[name]

            time.sleep(self.interval)

        db.close()
        print("🧹 GameMonitor thread stopped cleanly.")

    def start(self):
        """Start a background thread."""
        if self.thread and self.thread.is_alive():
            print("⚠️ GameMonitor already running.")
            return
        self._stop_event.clear()
        self.thread = threading.Thread(target=self.run, daemon=True)
        self.thread.start()

    def stop(self):
        """Signal the monitor to stop."""
        print("🛑 Stopping GameMonitor thread...")
        self._stop_event.set()
        if self.thread:
            self.thread.join(timeout=5)  # vänta upp till 5 sek på att loopen avslutas

    def cleanup_unfinished(self):
            """
            Clean up unfinished sessions in db at startup.
            """
            db = SessionLocal()  # skapar en ny DB-session
            try:
                crud.cleanup_unfinished_sessions(db, MIN_RUN_SECONDS)
                print("🧹 Cleanup of unfinished sessions done.")
            finally:
                db.close()

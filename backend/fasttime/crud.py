from sqlalchemy.orm import Session
from sqlalchemy import func
from . import models
from datetime import datetime, timezone, timedelta, date


def get_apps(db: Session):
    """
    Get all apps
    """
    return db.query(models.App).all()


def get_app(db: Session, name: str):
    """
    Get app by name from db
    """
    return db.query(models.App).filter(models.App.name == name).first()

def get_sessions(db: Session):
    """
    Get all sessions.
    """
    return db.query(models.Session).all()

def get_sessions_by_app(db: Session, app_name: str):
    """
    Get all sessions for a specific app.
    """
    return db.query(models.Session).filter(models.Session.window_title == app_name).all()

def get_sessions_by_date(db: Session, target_date: date):
    """
    Get all sessions for given date(based on start_time).
    """
    start = date(target_date.year, target_date.month, target_date.day)
    end = start.replace(day=start.day + 1) if start.day < 28 else None
    q = db.query(models.Session).filter(func.date(models.Session.start_time) == target_date)

    return q.all()

def cleanup_unfinished_sessions(db: Session, asumed_time: int):
    """
    Assume a closetime for unfinshed sessions
    """
    unfinished = db.query(models.Session).filter(models.Session.end_time.is_(None)).all()

    for session in unfinished:
        assumed_end = session.start_time + timedelta(seconds=asumed_time)
        session.end_time = assumed_end
        session.duration_seconds = (session.end_time - session.start_time).total_seconds()
        print(f"[Cleanup] Closed unfinished session id:{session.id} app_id:({session.app_id}) at {assumed_end} asumed-duration: {session.duration_seconds}")

    db.commit()


def get_or_create_app(db: Session, name: str, path: str):
    app = db.query(models.App).filter_by(name=name).first()
    if not app:
        app = models.App(name=name, path=path)
        db.add(app)
        db.commit()
        db.refresh(app)
    return app


def start_session(db: Session, name: str, path: str, window_title: str):
    app = get_or_create_app(db, name, path)
    session = models.Session(app_id=app.id, window_title=window_title)
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def end_session(db: Session, session: models.Session):
    session.end_time = datetime.now(timezone.utc)

    if session.start_time.tzinfo is None:
        session.start_time = session.start_time.replace(tzinfo=timezone.utc)

    session.duration_seconds = (session.end_time - session.start_time).total_seconds()
    db.commit()

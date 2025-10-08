from sqlalchemy.orm import Session
from . import models
from datetime import datetime, timezone


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


def end_session(db: Session, session):
    if session.end_time is None:
        session.end_time = datetime.now(timezone.utc)
        session.duration_seconds = int(
            (session.end_time - session.start_time).total_seconds()
        )
        db.commit()

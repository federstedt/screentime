from sqlalchemy.orm import Session
from . import models, schemas

# --- App ---
def get_apps(db: Session):
    return db.query(models.App).all()

def create_app(db: Session, app: schemas.AppCreate):
    db_app = models.App(**app.model_dump())
    db.add(db_app)
    db.commit()
    db.refresh(db_app)
    return db_app

def delete_app(db: Session, app_id: int):
    db.query(models.App).filter(models.App.id == app_id).delete()
    db.commit()


# --- Session ---
def get_sessions(db: Session):
    return db.query(models.Session).all()

def create_session(db: Session, session: schemas.SessionCreate):
    db_session = models.Session(**session.model_dump())
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    return db_session

def delete_session(db: Session, session_id: int):
    db.query(models.Session).filter(models.Session.id == session_id).delete()
    db.commit()


from sqlalchemy.orm import Session
from sqlalchemy import func
from .. import models

def get_daily_summary(db: Session, target_date):
    """
    Summerar körtid per app för en given dag.
    Returnerar t.ex. [{ "app_name": "steam", "total_seconds": 5400 }, ...]
    """
    rows = (
        db.query(
            models.Session.window_title,
            func.sum(models.Session.duration_seconds).label("total_seconds")
        )
        .filter(func.date(models.Session.start_time) == target_date)
        .group_by(models.Session.window_title)
        .all()
    )

    return [{"name": r.window_title, "total_seconds": r.total_seconds} for r in rows]

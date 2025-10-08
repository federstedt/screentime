from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from .db import Base
from datetime import datetime, timezone


class App(Base):
    __tablename__ = "apps"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    path = Column(String, nullable=True)

    sessions = relationship("Session", back_populates="app")


class Session(Base):
    __tablename__ = "sessions"
    id = Column(Integer, primary_key=True, index=True)
    app_id = Column(Integer, ForeignKey("apps.id"))
    window_title = Column(String, nullable=True)
    start_time = Column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    end_time = Column(DateTime(timezone=True), nullable=True)
    duration_seconds = Column(Integer, nullable=True)

    app = relationship("App", back_populates="sessions")

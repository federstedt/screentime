from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class SessionBase(BaseModel):
    window_title: Optional[str] = None
    start_time: datetime
    end_time: datetime
    duration_seconds: int

class SessionCreate(SessionBase):
    app_id: int

class Session(SessionBase):
    id: int
    app_id: int

    class Config:
        orm_mode = True


class AppBase(BaseModel):
    name: str
    category: Optional[str] = None

class AppCreate(AppBase):
    pass

class App(AppBase):
    id: int

    class Config:
        orm_mode = True

# Database boot stuff
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLlite-fil
DB_URL = "sqlite:///./screentime.db"

engine = create_engine(
        DB_URL,
        connect_args={"check_same_thread": False},
)

SessionLocal = sessionmaker(autocommit=False,
             autoflush=False, bind=engine)

Base = declarative_base()

# Placeholder for actual db where you store auth
# TODO: hur skapar man säkra nyklar och spar dem

api_keys = {
    "e54d4431-5dab-474e-b71a-0db1fcb9e659": "7oDYjo3d9r58EJKYi5x4E8",
    "5f0c7127-3be9-4488-b801-c7b6415b45e9": "mUP7PpTHmFAkxcQLWKMY8t",
}

users = {
    "7oDYjo3d9r58EJKYi5x4E8": {"name": "Bob"},
    "mUP7PpTHmFAkxcQLWKMY8t": {"name": "Alice"},
}


def check_api_key(api_key: str):
    return api_key in api_keys


def get_user_from_api_key(api_key: str):
    return users[api_keys[api_key]]



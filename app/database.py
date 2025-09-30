# app/database.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base
from dotenv import load_dotenv

load_dotenv()

# Use your actual MySQL root credentials
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "mysql+pymysql://root:maulitsaustaar@localhost:3306/kiri_ng"
)

# SQLAlchemy engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)

# Session factory
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

# Automap reflection
Base = automap_base()
Base.prepare(engine, reflect=True)  # reflect tables

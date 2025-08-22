import os
import psycopg

conn = None

def get_db():
    global conn
    if conn is None:
        conn = psycopg.connect(
            dbname=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
            host="db",
            port=os.getenv("POSTGRES_PORT", "5432"),
            autocommit=True,
        )
    return conn

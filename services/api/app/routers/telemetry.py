from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import Optional
from ..deps import get_db

router = APIRouter(prefix="/api/telemetry", tags=["telemetry"]) 

class TelemetryIn(BaseModel):
    payload: dict

@router.post("/{device_id}")
def ingest(device_id: str, t: TelemetryIn):
    db = get_db()
    with db.cursor() as cur:
        cur.execute("INSERT INTO telemetry(device_id, payload) VALUES (%s, %s)", (device_id, t.payload))
    return {"ok": True}

@router.get("/latest")
def get_latest_telemetry(device_id: Optional[str] = Query(None)):
    db = get_db()
    with db.cursor() as cur:
        if device_id:
            cur.execute(
                "SELECT device_id, ts, payload FROM telemetry WHERE device_id = %s ORDER BY ts DESC LIMIT 1", 
                (device_id,)
            )
        else:
            cur.execute(
                "SELECT device_id, ts, payload FROM telemetry ORDER BY ts DESC LIMIT 10"
            )
        rows = cur.fetchall()
        
        result = []
        for row in rows:
            result.append({
                "device_id": row[0],
                "timestamp": row[1].isoformat(),
                "payload": row[2]
            })
        return result

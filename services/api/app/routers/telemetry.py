from fastapi import APIRouter
from pydantic import BaseModel
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

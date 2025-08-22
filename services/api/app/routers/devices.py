from fastapi import APIRouter, HTTPException
from ..models import DeviceIn
from ..deps import get_db

router = APIRouter(prefix="/api/devices", tags=["devices"]) 

@router.post("/register")
def register_device(dev: DeviceIn):
    db = get_db()
    with db.cursor() as cur:
        cur.execute("INSERT INTO devices(id, name) VALUES (%s, %s) ON CONFLICT (id) DO NOTHING", (dev.id, dev.name))
    return {"ok": True, "device": dev}

@router.get("")
def list_devices():
    db = get_db()
    with db.cursor() as cur:
        cur.execute("SELECT id, name, created_at FROM devices ORDER BY created_at DESC LIMIT 200")
        rows = cur.fetchall()
    return [{"id": r[0], "name": r[1], "created_at": r[2]} for r in rows]

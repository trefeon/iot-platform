from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Any, Dict
from ..models import DeviceIn
from ..deps import get_db
from ..mqtt_bus import publish_cmd

router = APIRouter(prefix="/api/devices", tags=["devices"]) 

class CommandRequest(BaseModel):
    action: str
    value: Any = None
    temperature: float = None

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

@router.post("/{device_id}/command")
def send_device_command(device_id: str, command: CommandRequest):
    """Send a command to a device via MQTT"""
    try:
        # Convert command to dict for MQTT publishing
        cmd_dict = command.dict(exclude_none=True)
        
        # Publish command to device's command topic
        publish_cmd(device_id, cmd_dict)
        
        return {
            "ok": True, 
            "device_id": device_id,
            "command": cmd_dict,
            "message": f"Command sent to {device_id}"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send command: {str(e)}")

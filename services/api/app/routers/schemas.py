from pydantic import BaseModel, Field
from typing import Any, Dict

class DeviceIn(BaseModel):
    id: str = Field(..., pattern=r"^[a-zA-Z0-9_-]{3,64}$")
    name: str

class Device(DeviceIn):
    pass

class TelemetryIn(BaseModel):
    payload: Dict[str, Any]

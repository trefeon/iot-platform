from fastapi import FastAPI
from .routers import devices, telemetry
from .mqtt_bus import publish_cmd

app = FastAPI(title="IoT Platform API")

@app.get("/")
def root():
    return {"service": "iot-platform-api", "ok": True}

app.include_router(devices.router)
app.include_router(telemetry.router)

@app.post("/api/commands/{device_id}")
def send_command(device_id: str, cmd: dict):
    publish_cmd(device_id, cmd)
    return {"ok": True}

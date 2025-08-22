from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os, jwt, requests, logging
from .routers import devices, telemetry
from .mqtt_bus import publish_cmd

# Cloudflare Access configuration
CF_CERTS_URL = os.getenv("CF_ACCESS_CERTS", "")
CF_AUD = os.getenv("CF_ACCESS_AUD", "")

app = FastAPI(title="IoT Platform API")

# Mount static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Enable CORS for browser clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cache for Cloudflare public keys
_cf_pubkeys = None

def get_cf_pubkeys():
    global _cf_pubkeys
    if _cf_pubkeys is None and CF_CERTS_URL:
        try:
            response = requests.get(CF_CERTS_URL, timeout=5)
            _cf_pubkeys = response.json()["keys"]
        except Exception as e:
            logging.warning(f"Failed to fetch CF certs: {e}")
            _cf_pubkeys = []
    return _cf_pubkeys or []

def verify_cf_access(jwt_token: str):
    """Verify Cloudflare Access JWT"""
    if not CF_AUD or not CF_CERTS_URL:
        return True  # Skip verification if not configured
    
    pubkeys = get_cf_pubkeys()
    for k in pubkeys:
        try:
            return jwt.decode(
                jwt_token, 
                key=jwt.algorithms.RSAAlgorithm.from_jwk(k),
                audience=CF_AUD, 
                algorithms=["RS256"]
            )
        except Exception:
            continue
    raise HTTPException(status_code=401, detail="Invalid CF Access token")

@app.middleware("http")
async def cf_access_guard(request: Request, call_next):
    """Protect control.* subdomains with Cloudflare Access"""
    host = request.headers.get("host", "")
    
    # Protect only control.* and admin.* (public demo stays open/read-only)
    if host.startswith("control.") or host.startswith("admin."):
        token = request.headers.get("Cf-Access-Jwt-Assertion")
        if not token:
            raise HTTPException(status_code=401, detail="Missing CF Access JWT")
        verify_cf_access(token)
    
    response = await call_next(request)
    return response

@app.get("/control")
def control_panel():
    """Serve the control panel interface"""
    return FileResponse("app/static/control.html")

@app.get("/admin")
def admin_panel():
    """Serve the admin panel interface"""
    return FileResponse("app/static/admin.html")

@app.get("/mqtt-test")
def mqtt_test():
    """Serve the MQTT WebSocket test interface"""
    return FileResponse("app/static/mqtt-test.html")

@app.get("/")
def root():
    """Serve the demo dashboard"""
    return FileResponse("app/static/index.html")

@app.get("/health")
def health():
    return {"status": "healthy", "service": "iot-platform-api"}

app.include_router(devices.router)
app.include_router(telemetry.router)

@app.post("/api/commands/{device_id}")
def send_command(device_id: str, cmd: dict):
    publish_cmd(device_id, cmd)
    return {"ok": True}

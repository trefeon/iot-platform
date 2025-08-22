"""
Simplified IoT Platform API - Portfolio Version
A clean, focused FastAPI application for showcasing IoT skills
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import logging
import sqlite3
from datetime import datetime, timedelta
import os

# Simple MQTT client
import paho.mqtt.client as mqtt
import json

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Simple IoT Platform",
    description="Portfolio project showcasing IoT sensor data visualization",
    version="1.0.0"
)

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for your domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for frontend
app.mount("/static", StaticFiles(directory="static"), name="static")

# Simple in-memory storage for real-time data (replace with SQLite for persistence)
current_data = {}
sensor_history = []

# MQTT Configuration
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC = "sensors/+/data"  # Listen to all sensor devices

def init_database():
    """Initialize SQLite database for sensor data"""
    conn = sqlite3.connect("data/iot_data.db")  # Store in data directory
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS sensor_readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            temperature REAL,
            humidity REAL,
            light REAL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()
    logger.info("Database initialized")

def on_mqtt_connect(client, userdata, flags, rc):
    """Callback for MQTT connection"""
    if rc == 0:
        logger.info("Connected to MQTT broker")
        client.subscribe(MQTT_TOPIC)
    else:
        logger.error(f"Failed to connect to MQTT broker: {rc}")

def on_mqtt_message(client, userdata, msg):
    """Handle incoming MQTT messages"""
    try:
        topic_parts = msg.topic.split('/')
        device_id = topic_parts[1]  # Extract device ID from topic
        
        data = json.loads(msg.payload.decode())
        data['device_id'] = device_id
        data['timestamp'] = datetime.now().isoformat()
        
        # Store current data for real-time display
        current_data[device_id] = data
        
        # Keep limited history in memory for charts
        sensor_history.append(data)
        if len(sensor_history) > 1000:  # Keep last 1000 readings
            sensor_history.pop(0)
        
        # Save to database
        save_to_database(data)
        
        logger.info(f"Received data from {device_id}: {data}")
        
    except Exception as e:
        logger.error(f"Error processing MQTT message: {e}")

def save_to_database(data):
    """Save sensor data to SQLite database"""
    try:
        conn = sqlite3.connect("data/iot_data.db")  # Store in data directory
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO sensor_readings (device_id, temperature, humidity, light)
            VALUES (?, ?, ?, ?)
        """, (
            data.get('device_id'),
            data.get('temperature'),
            data.get('humidity'),
            data.get('light')
        ))
        
        conn.commit()
        conn.close()
        
    except Exception as e:
        logger.error(f"Error saving to database: {e}")

# Initialize MQTT client
mqtt_client = mqtt.Client()
mqtt_client.on_connect = on_mqtt_connect
mqtt_client.on_message = on_mqtt_message

@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    init_database()
    
    # Connect to MQTT broker
    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        logger.info("MQTT client started")
    except Exception as e:
        logger.error(f"Failed to connect to MQTT broker: {e}")

@app.on_event("shutdown")
async def shutdown_event():
    """Clean up on shutdown"""
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
    logger.info("MQTT client stopped")

# API Routes

@app.get("/")
async def read_root():
    """Serve the main dashboard"""
    return FileResponse("static/index.html")

@app.get("/api/current")
async def get_current_data():
    """Get current sensor readings from all devices"""
    return {"devices": current_data, "timestamp": datetime.now().isoformat()}

@app.get("/api/history")
async def get_sensor_history(hours: int = 24):
    """Get historical sensor data"""
    # Simple in-memory filtering (replace with proper DB query in production)
    cutoff_time = datetime.now() - timedelta(hours=hours)
    
    # For now, return recent history from memory
    # In production, query SQLite database here
    recent_history = sensor_history[-100:]  # Last 100 readings
    
    return {
        "data": recent_history,
        "period_hours": hours,
        "count": len(recent_history)
    }

@app.get("/api/devices")
async def get_devices():
    """Get list of active devices"""
    devices = []
    for device_id, data in current_data.items():
        last_seen = data.get('timestamp', '')
        devices.append({
            "id": device_id,
            "name": f"ESP32 Sensor {device_id}",
            "last_seen": last_seen,
            "status": "online" if last_seen else "offline"
        })
    
    return {"devices": devices}

@app.get("/api/stats")
async def get_statistics():
    """Get basic statistics about the platform"""
    conn = sqlite3.connect("data/iot_data.db")  # Store in data directory
    cursor = conn.cursor()
    
    # Get total readings count
    cursor.execute("SELECT COUNT(*) FROM sensor_readings")
    total_readings = cursor.fetchone()[0]
    
    # Get readings in last 24 hours
    cursor.execute("""
        SELECT COUNT(*) FROM sensor_readings 
        WHERE created_at > datetime('now', '-24 hours')
    """)
    readings_24h = cursor.fetchone()[0]
    
    conn.close()
    
    return {
        "total_readings": total_readings,
        "readings_24h": readings_24h,
        "active_devices": len(current_data),
        "uptime": "Portfolio Demo"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

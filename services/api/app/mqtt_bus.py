import os, json, logging
import paho.mqtt.client as mqtt
from .deps import get_db

MQTT_HOST = os.getenv("MQTT_HOST", "broker")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD")

_client = None
_subscriber_client = None

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def on_connect(client, userdata, flags, rc, properties):
    if rc == 0:
        logger.info("MQTT subscriber connected successfully")
        # Subscribe to all device telemetry topics
        client.subscribe("devices/+/environmental", qos=1)
        client.subscribe("devices/+/motion", qos=1) 
        client.subscribe("devices/+/power", qos=1)
        client.subscribe("devices/+/telemetry", qos=1)
        client.subscribe("devices/+/status", qos=1)
    else:
        logger.error(f"MQTT subscriber connection failed with code {rc}")

def on_message(client, userdata, msg):
    try:
        # Parse topic to extract device_id and topic type
        topic_parts = msg.topic.split('/')
        if len(topic_parts) >= 3 and topic_parts[0] == "devices":
            device_id = topic_parts[1]
            topic_type = topic_parts[2]
            
            # Parse payload
            payload = json.loads(msg.payload.decode())
            
            # Add topic info to payload
            payload['topic_type'] = topic_type
            payload['mqtt_topic'] = msg.topic
            
            # Store in database
            db = get_db()
            with db.cursor() as cur:
                # Ensure device exists
                cur.execute(
                    "INSERT INTO devices (id) VALUES (%s) ON CONFLICT (id) DO NOTHING", 
                    (device_id,)
                )
                # Insert telemetry data
                cur.execute(
                    "INSERT INTO telemetry(device_id, payload) VALUES (%s, %s)", 
                    (device_id, payload)
                )
            
            logger.info(f"Stored telemetry: {device_id}/{topic_type}")
    except Exception as e:
        logger.error(f"Error processing MQTT message: {e}")

def start_mqtt_subscriber():
    """Start MQTT subscriber for telemetry data"""
    global _subscriber_client
    if _subscriber_client is None:
        _subscriber_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="api-subscriber")
        _subscriber_client.on_connect = on_connect
        _subscriber_client.on_message = on_message
        
        if MQTT_USER:
            _subscriber_client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
        
        try:
            _subscriber_client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
            _subscriber_client.loop_start()
            logger.info("MQTT subscriber started")
        except Exception as e:
            logger.error(f"Failed to start MQTT subscriber: {e}")
    
    return _subscriber_client

def get_mqtt():
    global _client
    if _client is None:
        _client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
        if MQTT_USER:
            _client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
        _client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
        _client.loop_start()
    return _client

def publish_cmd(device_id: str, cmd: dict):
    topic = f"devices/{device_id}/cmd"
    payload = json.dumps(cmd)
    get_mqtt().publish(topic, payload, qos=1, retain=False)

import os, json
import paho.mqtt.client as mqtt

MQTT_HOST = os.getenv("MQTT_HOST", "broker")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD")

_client = None

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

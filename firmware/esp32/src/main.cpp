#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// ====== CONFIG ======
const char* WIFI_SSID = "YOUR_WIFI";
const char* WIFI_PASS = "YOUR_PASS";
const char* MQTT_HOST = "192.168.1.10"; // set to your server IP (or broker hostname)
const int   MQTT_PORT = 1883;            // change to 8883 for TLS later
const char* MQTT_USER = "devuser";
const char* MQTT_PASS = "devpass";
const char* DEVICE_ID = "esp32-01";     // unique per device

WiFiClient espClient;
PubSubClient mqtt(espClient);
unsigned long lastPub = 0;

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  // Simple command handler
  StaticJsonDocument<256> doc;
  DeserializationError err = deserializeJson(doc, payload, length);
  if (!err) {
    const char* action = doc["action"] | "";
    if (strcmp(action, "led") == 0) {
      int val = doc["value"] | 0;
      digitalWrite(2, val ? HIGH : LOW);
    }
  }
}

void mqttConnect() {
  while (!mqtt.connected()) {
    if (mqtt.connect(DEVICE_ID, MQTT_USER, MQTT_PASS)) {
      String cmdTopic = String("devices/") + DEVICE_ID + "/cmd";
      mqtt.subscribe(cmdTopic.c_str(), 1);
    } else {
      delay(1000);
    }
  }
}

void setup() {
  pinMode(2, OUTPUT);
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print('.') ; }
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(onMqttMessage);
}

void loop() {
  if (!mqtt.connected()) mqttConnect();
  mqtt.loop();

  unsigned long now = millis();
  if (now - lastPub > 5000) {
    lastPub = now;
    // Publish telemetry
    StaticJsonDocument<256> doc;
    doc["uptime_ms"] = now;
    doc["heap_free"] = ESP.getFreeHeap();
    doc["rssi"] = WiFi.RSSI();
    char buf[256];
    size_t n = serializeJson(doc, buf);
    String topic = String("devices/") + DEVICE_ID + "/telemetry";
    mqtt.publish(topic.c_str(), buf, n, false);
  }
}

#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// ====== CONFIG ======
// TODO: Update these with your actual WiFi credentials
const char* WIFI_SSID = "YOUR_WIFI_NETWORK_NAME";     // Replace with your WiFi network name
const char* WIFI_PASS = "YOUR_WIFI_PASSWORD";         // Replace with your WiFi password
const char* MQTT_HOST = "192.168.123.7"; // Your server's IP address
const int   MQTT_PORT = 1883;
const char* MQTT_USER = "devuser";
const char* MQTT_PASS = "abi12345";      // Updated to match your .env
const char* DEVICE_ID = "esp32-01";     // unique per device

// Sensor simulation variables
float baseTemperature = 22.5;  // Base temperature in Celsius
float baseHumidity = 55.0;     // Base humidity percentage
float basePressure = 1013.25;  // Base pressure in hPa
float baseLight = 500.0;       // Base light level in lux
float baseSoilMoisture = 45.0; // Base soil moisture percentage
float baseGasResistance = 50000.0; // Base gas resistance in ohms
float baseAccelX = 0.0, baseAccelY = 0.0, baseAccelZ = 9.8; // Base acceleration (m/s²)
float baseBattery = 85.0;      // Base battery percentage

// Timing variables
unsigned long lastTelemetry = 0;
unsigned long lastEnvironmental = 0;
unsigned long lastMotion = 0;
unsigned long lastPower = 0;

const unsigned long TELEMETRY_INTERVAL = 5000;    // 5 seconds
const unsigned long ENVIRONMENTAL_INTERVAL = 10000; // 10 seconds  
const unsigned long MOTION_INTERVAL = 2000;       // 2 seconds
const unsigned long POWER_INTERVAL = 30000;       // 30 seconds

// LED activity indication
bool ledState = false;
unsigned long lastLedActivity = 0;
const unsigned long LED_FLASH_DURATION = 100;     // 100ms flash duration

WiFiClient espClient;
PubSubClient mqtt(espClient);

// Helper function to generate realistic sensor variations
float addNoise(float baseValue, float variation) {
  float noise = (random(0, 1000) / 1000.0 - 0.5) * 2.0 * variation;
  return baseValue + noise;
}

// Helper function to add daily pattern (temperature rises during day)
float addDailyPattern(float baseValue, float amplitude) {
  unsigned long timeOfDay = (millis() / 1000) % 86400; // Seconds in day
  float pattern = sin(2 * PI * timeOfDay / 86400.0) * amplitude;
  return baseValue + pattern;
}

// Flash LED to indicate activity
void flashActivityLED() {
  digitalWrite(2, HIGH);
  ledState = true;
  lastLedActivity = millis();
}

// Simulate realistic environmental sensor data
void publishEnvironmentalData() {
  JsonDocument doc;
  
  // Temperature with daily pattern and noise (18-30°C range)
  float temp = addDailyPattern(baseTemperature, 4.0);
  temp = addNoise(temp, 1.0);
  doc["temperature"] = round(temp * 100) / 100.0;
  
  // Humidity inversely related to temperature (30-80% range)
  float humidity = baseHumidity + (baseTemperature - temp) * 2.0;
  humidity = addNoise(humidity, 3.0);
  humidity = constrain(humidity, 30.0, 80.0);
  doc["humidity"] = round(humidity * 100) / 100.0;
  
  // Atmospheric pressure (980-1040 hPa range)
  float pressure = addNoise(basePressure, 5.0);
  doc["pressure"] = round(pressure * 100) / 100.0;
  
  // Light level with day/night cycle (0-1000 lux)
  unsigned long timeOfDay = (millis() / 1000) % 86400;
  float lightPattern = max(0.0f, (float)sin(PI * timeOfDay / 43200.0)); // Day cycle
  float light = baseLight * lightPattern;
  light = addNoise(light, 50.0);
  light = max(0.0f, light);
  doc["light"] = round(light);
  
  // Soil moisture (20-70% range)
  float soilMoisture = addNoise(baseSoilMoisture, 2.0);
  soilMoisture = constrain(soilMoisture, 20.0, 70.0);
  doc["soil_moisture"] = round(soilMoisture * 100) / 100.0;
  
  // Air quality (gas resistance - higher is better)
  float gasResistance = addNoise(baseGasResistance, 5000.0);
  gasResistance = max(10000.0f, gasResistance);
  doc["air_quality"] = round(gasResistance);
  
  char buffer[512];
  size_t len = serializeJson(doc, buffer);
  String topic = String("devices/") + DEVICE_ID + "/environmental";
  mqtt.publish(topic.c_str(), (uint8_t*)buffer, len, false);
  
  // Flash LED to indicate activity
  flashActivityLED();
}

// Simulate motion/accelerometer data
void publishMotionData() {
  JsonDocument doc;
  
  // Simulate slight vibrations/movements
  float accelX = addNoise(baseAccelX, 0.1);
  float accelY = addNoise(baseAccelY, 0.1);
  float accelZ = addNoise(baseAccelZ, 0.1);
  
  doc["accel_x"] = round(accelX * 1000) / 1000.0;
  doc["accel_y"] = round(accelY * 1000) / 1000.0;
  doc["accel_z"] = round(accelZ * 1000) / 1000.0;
  
  // Calculate magnitude for vibration detection
  float magnitude = sqrt(accelX*accelX + accelY*accelY + accelZ*accelZ);
  doc["vibration"] = round(magnitude * 1000) / 1000.0;
  
  // Simulated gyroscope data (degrees/second)
  doc["gyro_x"] = addNoise(0.0, 2.0);
  doc["gyro_y"] = addNoise(0.0, 2.0);
  doc["gyro_z"] = addNoise(0.0, 2.0);
  
  char buffer[256];
  size_t len = serializeJson(doc, buffer);
  String topic = String("devices/") + DEVICE_ID + "/motion";
  mqtt.publish(topic.c_str(), (uint8_t*)buffer, len, false);
  
  // Flash LED to indicate activity
  flashActivityLED();
}

// Simulate power and system data
void publishPowerData() {
  JsonDocument doc;
  
  // Battery level slowly decreasing with usage spikes
  static float batteryDrain = 0.0;
  batteryDrain += 0.01; // Slow drain
  float battery = baseBattery - batteryDrain + addNoise(0.0, 1.0);
  battery = constrain(battery, 10.0, 100.0);
  doc["battery"] = round(battery * 100) / 100.0;
  
  // Charging status (random charging events)
  bool charging = (random(0, 100) < 5); // 5% chance of charging
  doc["charging"] = charging;
  
  // Power consumption (watts)
  float power = charging ? addNoise(2.5, 0.5) : addNoise(1.2, 0.3);
  doc["power_consumption"] = round(power * 100) / 100.0;
  
  // Voltage levels
  doc["voltage"] = addNoise(3.3, 0.1);
  
  char buffer[256];
  size_t len = serializeJson(doc, buffer);
  String topic = String("devices/") + DEVICE_ID + "/power";
  mqtt.publish(topic.c_str(), (uint8_t*)buffer, len, false);
  
  // Flash LED to indicate activity
  flashActivityLED();
}

// Publish basic telemetry data
void publishTelemetryData() {
  JsonDocument doc;
  
  doc["device_id"] = DEVICE_ID;
  doc["uptime_ms"] = millis();
  doc["heap_free"] = ESP.getFreeHeap();
  doc["rssi"] = WiFi.RSSI();
  doc["wifi_quality"] = map(constrain(WiFi.RSSI(), -100, -50), -100, -50, 0, 100);
  doc["ip_address"] = WiFi.localIP().toString();
  doc["mac_address"] = WiFi.macAddress();
  
  // CPU temperature (internal sensor simulation)
  doc["cpu_temp"] = addNoise(45.0, 5.0);
  
  char buffer[256];
  size_t len = serializeJson(doc, buffer);
  String topic = String("devices/") + DEVICE_ID + "/telemetry";
  mqtt.publish(topic.c_str(), (uint8_t*)buffer, len, false);
  
  // Flash LED to indicate activity
  flashActivityLED();
}

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  // Flash LED to indicate incoming command
  flashActivityLED();
  
  // Enhanced command handler
  JsonDocument doc;
  DeserializationError err = deserializeJson(doc, payload, length);
  if (!err) {
    const char* action = doc["action"] | "";
    
    if (strcmp(action, "led") == 0) {
      int val = doc["value"] | 0;
      // Only control LED state when not flashing for activity
      if (millis() - lastLedActivity > LED_FLASH_DURATION) {
        digitalWrite(2, val ? HIGH : LOW);
        ledState = val;
      }
      
      // Send acknowledgment
      JsonDocument ack;
      ack["status"] = "ok";
      ack["action"] = "led";
      ack["value"] = val;
      char ackBuffer[128];
      size_t ackLen = serializeJson(ack, ackBuffer);
      String ackTopic = String("devices/") + DEVICE_ID + "/status";
      mqtt.publish(ackTopic.c_str(), (uint8_t*)ackBuffer, ackLen, false);
    }
    else if (strcmp(action, "reset") == 0) {
      // Reset sensor baselines
      baseTemperature = 22.5;
      baseHumidity = 55.0;
      basePressure = 1013.25;
      
      JsonDocument ack;
      ack["status"] = "reset_complete";
      char ackBuffer[128];
      size_t ackLen = serializeJson(ack, ackBuffer);
      String ackTopic = String("devices/") + DEVICE_ID + "/status";
      mqtt.publish(ackTopic.c_str(), (uint8_t*)ackBuffer, ackLen, false);
    }
    else if (strcmp(action, "config") == 0) {
      // Update sensor baselines
      if (doc["temperature"]) baseTemperature = doc["temperature"];
      if (doc["humidity"]) baseHumidity = doc["humidity"];
      if (doc["pressure"]) basePressure = doc["pressure"];
      
      JsonDocument ack;
      ack["status"] = "config_updated";
      char ackBuffer[128];
      size_t ackLen = serializeJson(ack, ackBuffer);
      String ackTopic = String("devices/") + DEVICE_ID + "/status";
      mqtt.publish(ackTopic.c_str(), (uint8_t*)ackBuffer, ackLen, false);
    }
  }
}

void mqttConnect() {
  while (!mqtt.connected()) {
    Serial.print("Connecting to MQTT...");
    if (mqtt.connect(DEVICE_ID, MQTT_USER, MQTT_PASS)) {
      Serial.println(" connected!");
      
      // Subscribe to command topic
      String cmdTopic = String("devices/") + DEVICE_ID + "/cmd";
      mqtt.subscribe(cmdTopic.c_str(), 1);
      
      // Publish device online status
      JsonDocument onlineMsg;
      onlineMsg["device_id"] = DEVICE_ID;
      onlineMsg["status"] = "online";
      onlineMsg["timestamp"] = millis();
      char buffer[128];
      size_t len = serializeJson(onlineMsg, buffer);
      String statusTopic = String("devices/") + DEVICE_ID + "/status";
      mqtt.publish(statusTopic.c_str(), (uint8_t*)buffer, len, true); // Retained message
      
      // Flash LED to indicate connection
      flashActivityLED();
      
    } else {
      Serial.print(" failed, rc=");
      Serial.print(mqtt.state());
      Serial.println(" retrying in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  pinMode(2, OUTPUT);
  digitalWrite(2, LOW); // Start with LED off
  Serial.begin(115200);
  Serial.println("\n=== ESP32 IoT Sensor Node ===");
  Serial.println("Device ID: " + String(DEVICE_ID));
  
  // Connect to WiFi
  Serial.print("Connecting to WiFi");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  
  // Blink LED while connecting to WiFi
  while (WiFi.status() != WL_CONNECTED) { 
    digitalWrite(2, HIGH);
    delay(250);
    digitalWrite(2, LOW);
    delay(250); 
    Serial.print(".");
  }
  digitalWrite(2, LOW); // Ensure LED is off after connection
  
  Serial.println("\nWiFi connected!");
  Serial.println("IP address: " + WiFi.localIP().toString());
  
  // Setup MQTT
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(onMqttMessage);
  mqtt.setBufferSize(1024); // Increase buffer for larger messages
  
  Serial.println("Setup complete!");
}

void loop() {
  if (!mqtt.connected()) {
    mqttConnect();
  }
  mqtt.loop();

  // Handle LED activity flash duration
  if (ledState && (millis() - lastLedActivity > LED_FLASH_DURATION)) {
    digitalWrite(2, LOW);
    ledState = false;
  }

  unsigned long now = millis();
  
  // Publish different data types at different intervals
  if (now - lastTelemetry > TELEMETRY_INTERVAL) {
    lastTelemetry = now;
    publishTelemetryData();
    Serial.println("Published telemetry data");
  }
  
  if (now - lastEnvironmental > ENVIRONMENTAL_INTERVAL) {
    lastEnvironmental = now;
    publishEnvironmentalData();
    Serial.println("Published environmental data");
  }
  
  if (now - lastMotion > MOTION_INTERVAL) {
    lastMotion = now;
    publishMotionData();
    Serial.println("Published motion data");
  }
  
  if (now - lastPower > POWER_INTERVAL) {
    lastPower = now;
    publishPowerData();
    Serial.println("Published power data");
  }
}

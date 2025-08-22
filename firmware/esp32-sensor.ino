#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ====== CONFIGURATION ======
// TODO: Update these with your actual credentials
const char* WIFI_SSID = "YOUR_WIFI_NETWORK_NAME";     
const char* WIFI_PASS = "YOUR_WIFI_PASSWORD";         
const char* MQTT_HOST = "192.168.1.100";  // Your Ubuntu server IP
const int   MQTT_PORT = 1883;
const char* DEVICE_ID = "esp32-portfolio-demo";

// Pin Configuration
#define DHT_PIN 4
#define DHT_TYPE DHT22
#define LED_PIN 2
#define LIGHT_SENSOR_PIN 34  // Analog pin for LDR

// Initialize sensors
DHT dht(DHT_PIN, DHT_TYPE);
WiFiClient espClient;
PubSubClient mqtt(espClient);

// Timing variables
unsigned long lastSensorRead = 0;
unsigned long lastMqttReconnect = 0;
const unsigned long SENSOR_INTERVAL = 10000;  // Read sensors every 10 seconds
const unsigned long MQTT_RECONNECT_INTERVAL = 5000;

void setup() {
  Serial.begin(115200);
  Serial.println("\n🌟 Simple IoT Platform - ESP32 Demo");
  
  // Initialize pins
  pinMode(LED_PIN, OUTPUT);
  pinMode(LIGHT_SENSOR_PIN, INPUT);
  
  // Initialize DHT sensor
  dht.begin();
  
  // Connect to WiFi
  connectWiFi();
  
  // Setup MQTT
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(onMqttMessage);
  
  Serial.println("✅ Setup complete!");
  Serial.printf("📡 Device ID: %s\n", DEVICE_ID);
  
  // Initial LED blink to show it's working
  for(int i = 0; i < 3; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(200);
    digitalWrite(LED_PIN, LOW);
    delay(200);
  }
}

void loop() {
  // Maintain WiFi connection
  if(WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
  
  // Maintain MQTT connection
  if(!mqtt.connected() && millis() - lastMqttReconnect > MQTT_RECONNECT_INTERVAL) {
    connectMqtt();
    lastMqttReconnect = millis();
  }
  
  mqtt.loop();
  
  // Read and send sensor data
  if(millis() - lastSensorRead > SENSOR_INTERVAL) {
    readAndSendSensorData();
    lastSensorRead = millis();
  }
  
  delay(100);
}

void connectWiFi() {
  Serial.printf("🔌 Connecting to WiFi: %s", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  
  int attempts = 0;
  while(WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if(WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi connected!");
    Serial.printf("📍 IP address: %s\n", WiFi.localIP().toString().c_str());
    
    // Blink LED to indicate WiFi connection
    for(int i = 0; i < 5; i++) {
      digitalWrite(LED_PIN, HIGH);
      delay(100);
      digitalWrite(LED_PIN, LOW);
      delay(100);
    }
  } else {
    Serial.println("\n❌ WiFi connection failed!");
  }
}

void connectMqtt() {
  if(WiFi.status() != WL_CONNECTED) return;
  
  Serial.printf("🔗 Connecting to MQTT broker: %s:%d", MQTT_HOST, MQTT_PORT);
  
  if(mqtt.connect(DEVICE_ID)) {
    Serial.println("\n✅ MQTT connected!");
    
    // Subscribe to device-specific commands
    String commandTopic = "sensors/" + String(DEVICE_ID) + "/commands";
    mqtt.subscribe(commandTopic.c_str());
    Serial.printf("📬 Subscribed to: %s\n", commandTopic.c_str());
    
    // Send online status
    sendDeviceStatus(true);
    
    // LED indicator for MQTT connection
    digitalWrite(LED_PIN, HIGH);
    delay(1000);
    digitalWrite(LED_PIN, LOW);
    
  } else {
    Serial.printf("\n❌ MQTT connection failed! Error code: %d\n", mqtt.state());
  }
}

void readAndSendSensorData() {
  if(!mqtt.connected()) return;
  
  Serial.println("📊 Reading sensors...");
  
  // Read DHT22 sensor
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  
  // Read light sensor (LDR)
  int lightRaw = analogRead(LIGHT_SENSOR_PIN);
  float lightLevel = map(lightRaw, 0, 4095, 0, 1000); // Convert to lux approximation
  
  // Check if readings are valid
  if(isnan(temperature) || isnan(humidity)) {
    Serial.println("❌ Failed to read from DHT sensor!");
    return;
  }
  
  // Create JSON payload
  StaticJsonDocument<200> doc;
  doc["device_id"] = DEVICE_ID;
  doc["temperature"] = round(temperature * 10) / 10.0;  // Round to 1 decimal
  doc["humidity"] = round(humidity * 10) / 10.0;
  doc["light"] = round(lightLevel);
  doc["timestamp"] = millis();
  doc["wifi_rssi"] = WiFi.RSSI();
  
  String payload;
  serializeJson(doc, payload);
  
  // Publish to MQTT
  String topic = "sensors/" + String(DEVICE_ID) + "/data";
  if(mqtt.publish(topic.c_str(), payload.c_str())) {
    Serial.printf("📤 Data sent: %s\n", payload.c_str());
    
    // Quick LED flash to indicate data sent
    digitalWrite(LED_PIN, HIGH);
    delay(50);
    digitalWrite(LED_PIN, LOW);
    
  } else {
    Serial.println("❌ Failed to send data!");
  }
}

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  String message;
  for(int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  Serial.printf("📨 Received command: %s\n", message.c_str());
  
  // Parse JSON command
  StaticJsonDocument<100> doc;
  deserializeJson(doc, message);
  
  String command = doc["command"];
  
  if(command == "led_on") {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("💡 LED turned ON");
  }
  else if(command == "led_off") {
    digitalWrite(LED_PIN, LOW);
    Serial.println("💡 LED turned OFF");
  }
  else if(command == "status") {
    sendDeviceStatus(true);
  }
  else if(command == "restart") {
    Serial.println("🔄 Restarting device...");
    ESP.restart();
  }
  else {
    Serial.printf("❓ Unknown command: %s\n", command.c_str());
  }
}

void sendDeviceStatus(bool online) {
  if(!mqtt.connected()) return;
  
  StaticJsonDocument<150> doc;
  doc["device_id"] = DEVICE_ID;
  doc["status"] = online ? "online" : "offline";
  doc["uptime"] = millis();
  doc["free_heap"] = ESP.getFreeHeap();
  doc["wifi_rssi"] = WiFi.RSSI();
  
  String payload;
  serializeJson(doc, payload);
  
  String topic = "sensors/" + String(DEVICE_ID) + "/status";
  mqtt.publish(topic.c_str(), payload.c_str(), true); // Retained message
  
  Serial.printf("📡 Status sent: %s\n", online ? "online" : "offline");
}

// Send offline status before restart/shutdown
void __attribute__((destructor)) cleanup() {
  sendDeviceStatus(false);
}

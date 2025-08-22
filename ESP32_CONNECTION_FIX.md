# 🔧 ESP32 Setup to Fix Demo Website

## Current Issue
Your demo website was showing simulated data instead of real data from your ESP32 device.

## ✅ What I Fixed

### 1. **Demo Website (Fixed)**
- Replaced simulated data with real API calls
- Now connects to your actual MQTT broker and device API
- Updated device controls to send real commands to ESP32
- Removed old simulation functions

### 2. **ESP32 Code (Needs Your Action)**
Your ESP32 code needs WiFi credentials updated in `/firmware/esp32/src/main.cpp`:

**Current (lines 6-7):**
```cpp
const char* WIFI_SSID = "YOUR_WIFI_NETWORK_NAME";     // Replace with your WiFi network name
const char* WIFI_PASS = "YOUR_WIFI_PASSWORD";         // Replace with your WiFi password
```

**You need to change to:**
```cpp
const char* WIFI_SSID = "YourActualWiFiName";         // Your real WiFi network name
const char* WIFI_PASS = "YourActualWiFiPassword";     // Your real WiFi password
```

## 🚀 Steps to Get ESP32 Working

### Step 1: Update WiFi Credentials
1. Open `firmware/esp32/src/main.cpp`
2. Replace `"YOUR_WIFI_NETWORK_NAME"` with your actual WiFi network name
3. Replace `"YOUR_WIFI_PASSWORD"` with your actual WiFi password

### Step 2: Flash ESP32
1. Connect your ESP32 to your computer via USB
2. Use PlatformIO or Arduino IDE to upload the code
3. Open Serial Monitor to see connection status

### Step 3: Verify Connection
Your ESP32 should:
1. Connect to your WiFi network
2. Connect to MQTT broker at `192.168.123.7:1883`
3. Start sending sensor data every few seconds

## 📊 Expected Behavior

### **ESP32 Serial Output Should Show:**
```
=== ESP32 IoT Sensor Node ===
Device ID: esp32-01
Connecting to WiFi.......
WiFi connected!
IP address: 192.168.x.x
Connecting to MQTT... connected!
Published telemetry data
Published environmental data
Published motion data
```

### **Demo Website Should Show:**
- Real device "esp32-01" in device list
- Live sensor data updating every 3 seconds
- Working LED control buttons
- Real MQTT console messages

## 🔍 Troubleshooting

### ESP32 Not Connecting to WiFi
- Check WiFi network name and password
- Ensure ESP32 is in range of WiFi router
- Check if network uses 2.4GHz (ESP32 doesn't support 5GHz)

### ESP32 Not Connecting to MQTT
- Verify server IP `192.168.123.7` is reachable from ESP32
- Check MQTT credentials: `devuser` / `abi12345`
- Ensure port 1883 is open on server

### Demo Website Shows "No devices found"
- ESP32 must be connected and sending data first
- Check API endpoint: `http://192.168.123.7:8080/api/devices`
- Verify MQTT broker is receiving messages

## 🎯 Quick Test Commands

### Test Server API
```bash
# On your server
curl http://localhost:8080/api/devices
curl http://localhost:8080/api/telemetry/latest?limit=10
```

### Test MQTT Connection
```bash
# On your server
mosquitto_sub -h localhost -p 1883 -u devuser -P abi12345 -t "devices/+/+"
```

## 📱 Demo URLs

After ESP32 is connected, visit:
- **Demo**: http://192.168.123.7:8080/ (or your domain)
- **Control Panel**: http://192.168.123.7:8080/control
- **Admin Panel**: http://192.168.123.7:8080/admin

---

**Next Step:** Update your ESP32 WiFi credentials and flash the device!

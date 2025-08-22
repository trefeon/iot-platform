# ESP32 IoT Sensor Node Setup Guide

## Overview
This guide will help you configure your ESP32 to work with the IoT Platform, sending realistic sensor data and responding to remote commands.

## 🔧 Hardware Requirements

### Required Components:
- **ESP32 Development Board** (ESP32-WROOM-32 or similar)
- **USB Cable** (for programming and power)
- **LED** (built-in LED on pin 2 is used)

### Optional Sensors (for real implementation):
- **DHT22** - Temperature & Humidity
- **BMP280** - Temperature, Humidity & Pressure
- **BH1750** - Light sensor
- **MQ-135** - Air quality sensor
- **Soil moisture sensor**
- **MPU6050** - Accelerometer & Gyroscope
- **18650 Battery + charging module**

## 📦 Software Setup

### 1. Install PlatformIO
```bash
# Install VS Code extension: PlatformIO IDE
# Or install CLI version:
pip install platformio
```

### 2. Configure WiFi and MQTT Settings
Edit the configuration in `firmware/esp32/src/main.cpp`:

```cpp
// ====== CHANGE THESE VALUES ======
const char* WIFI_SSID = "Your_WiFi_Network";     // Your WiFi network name
const char* WIFI_PASS = "Your_WiFi_Password";    // Your WiFi password
const char* MQTT_HOST = "mqtt.trefeon.site";     // Your MQTT broker (use your domain)
const char* MQTT_USER = "devuser";               // MQTT username (set in broker config)
const char* MQTT_PASS = "devpass";               // MQTT password (set in broker config)
const char* DEVICE_ID = "esp32-01";              // Unique device identifier
```

### 3. Upload Firmware
```bash
cd firmware/esp32
pio run --target upload
pio device monitor  # To see serial output
```

## 📡 MQTT Topics and Data Structure

### Published Topics:
The ESP32 publishes data to different topics based on sensor categories:

#### 1. Environmental Data (`devices/{device_id}/environmental`)
Published every 10 seconds:
```json
{
  "temperature": 24.5,      // °C
  "humidity": 62.0,         // %
  "pressure": 1013.25,      // hPa
  "light": 850,             // lux
  "soil_moisture": 45.0,    // %
  "air_quality": 50000      // ohms (gas resistance)
}
```

#### 2. Motion Data (`devices/{device_id}/motion`)
Published every 2 seconds:
```json
{
  "accel_x": 0.02,          // m/s²
  "accel_y": -0.01,         // m/s²
  "accel_z": 9.78,          // m/s²
  "vibration": 9.78,        // magnitude
  "gyro_x": 0.5,            // degrees/second
  "gyro_y": -0.3,           // degrees/second
  "gyro_z": 0.1             // degrees/second
}
```

#### 3. Power Data (`devices/{device_id}/power`)
Published every 30 seconds:
```json
{
  "battery": 85.5,          // %
  "charging": false,        // boolean
  "power_consumption": 1.2, // watts
  "voltage": 3.28           // volts
}
```

#### 4. Telemetry Data (`devices/{device_id}/telemetry`)
Published every 5 seconds:
```json
{
  "device_id": "esp32-01",
  "uptime_ms": 123456,
  "heap_free": 280000,      // bytes
  "rssi": -45,              // dBm
  "wifi_quality": 85,       // %
  "ip_address": "192.168.1.100",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "cpu_temp": 45.2          // °C
}
```

#### 5. Status Messages (`devices/{device_id}/status`)
Published on events:
```json
{
  "device_id": "esp32-01",
  "status": "online",       // online/offline/error
  "timestamp": 123456
}
```

### Subscribed Topics:

#### Command Topic (`devices/{device_id}/cmd`)
Send commands to the device:

**LED Control:**
```json
{
  "action": "led",
  "value": 1                // 1 = ON, 0 = OFF
}
```

**Sensor Reset:**
```json
{
  "action": "reset"
}
```

**Configuration Update:**
```json
{
  "action": "config",
  "temperature": 25.0,      // New base temperature
  "humidity": 60.0,         // New base humidity
  "pressure": 1020.0        // New base pressure
}
```

## 🎯 Realistic Sensor Simulation

The firmware simulates realistic sensor behavior:

### Temperature
- **Base**: 22.5°C
- **Daily Pattern**: ±4°C sine wave (peak at 3 PM)
- **Noise**: ±1°C random variation
- **Range**: 18-30°C

### Humidity
- **Base**: 55%
- **Inverse relationship** with temperature
- **Noise**: ±3% random variation
- **Range**: 30-80%

### Light Level
- **Day/Night Cycle**: 0-1000 lux based on time
- **Weather Simulation**: Random cloud patterns
- **Indoor/Outdoor**: Configurable base levels

### Air Quality
- **Gas Resistance**: 10k-100k ohms
- **Quality Levels**: Good (>40k), Fair (20-40k), Poor (<20k)

### Battery & Power
- **Slow Drain**: Gradual decrease with usage spikes
- **Charging Events**: Random charging simulation
- **Power Consumption**: 0.8-2.5W based on activity

### Motion
- **Baseline**: Earth gravity (9.8 m/s²)
- **Vibrations**: Small variations for movement detection
- **Gyroscope**: Minimal rotation around all axes

## 🖥️ Dashboard Integration

### Real-time Updates
The demo dashboard displays all sensor data in real-time:

- **8 Stat Cards**: Key metrics overview
- **Environmental Chart**: Temperature, humidity, pressure, light
- **Power Chart**: Battery, power consumption, vibration
- **Sensor Details Panel**: All current readings
- **Device Controls**: Remote command sending

### Viewing Your Data
1. Open `https://demo.trefeon.site` 
2. Watch real-time sensor updates
3. Use control buttons to send commands
4. Monitor MQTT console for device communication

## 🔧 Advanced Configuration

### Custom Device ID
Change the device identifier for multiple ESP32s:
```cpp
const char* DEVICE_ID = "esp32-kitchen";    // Kitchen sensor
const char* DEVICE_ID = "esp32-living";     // Living room sensor  
const char* DEVICE_ID = "esp32-garage";     // Garage sensor
```

### Sensor Base Values
Adjust baseline values for different environments:
```cpp
float baseTemperature = 20.0;  // Cooler climate
float baseHumidity = 70.0;     // More humid environment
float baseLight = 200.0;       // Indoor lighting
```

### Sampling Intervals
Modify data publishing frequencies:
```cpp
const unsigned long TELEMETRY_INTERVAL = 10000;     // 10 seconds
const unsigned long ENVIRONMENTAL_INTERVAL = 15000; // 15 seconds
const unsigned long MOTION_INTERVAL = 1000;         // 1 second (more responsive)
```

## 🚀 Real Sensor Integration

To connect real sensors instead of simulation:

### DHT22 Temperature/Humidity
```cpp
#include <DHT.h>
#define DHT_PIN 4
#define DHT_TYPE DHT22
DHT dht(DHT_PIN, DHT_TYPE);

// In publishEnvironmentalData():
float temp = dht.readTemperature();
float humidity = dht.readHumidity();
```

### BMP280 Pressure Sensor
```cpp
#include <Adafruit_BMP280.h>
Adafruit_BMP280 bmp;

// In publishEnvironmentalData():
float pressure = bmp.readPressure() / 100.0; // Convert to hPa
```

### BH1750 Light Sensor
```cpp
#include <BH1750.h>
BH1750 lightMeter;

// In publishEnvironmentalData():
float light = lightMeter.readLightLevel();
```

## 📊 Monitoring and Debugging

### Serial Monitor
Watch device status and MQTT communication:
```bash
pio device monitor
```

### MQTT Debug
Use MQTT client to monitor all topics:
```bash
# Subscribe to all device topics
mosquitto_sub -h mqtt.trefeon.site -t "devices/+/+"

# Send test command
mosquitto_pub -h mqtt.trefeon.site -t "devices/esp32-01/cmd" -m '{"action":"led","value":1}'
```

### Web Dashboard
- Monitor real-time data at `https://demo.trefeon.site`
- Use MQTT test interface at `https://mqtt.trefeon.site`
- Check device controls and console logs

## 🔐 Security Considerations

### Production Setup
- Change default MQTT credentials
- Use TLS/SSL for MQTT (port 8883)
- Implement device certificates
- Add OTA (Over-The-Air) update capability

### Network Security
- Use WPA3 WiFi encryption
- Implement VPN for remote access
- Regular firmware updates
- Monitor device behavior for anomalies

## 🎉 Success Indicators

Your ESP32 is working correctly when you see:

1. **Serial Output**: WiFi connection and MQTT messages
2. **Dashboard Updates**: Real-time data on demo website
3. **Command Response**: LED control and sensor resets work
4. **Data Patterns**: Realistic daily/hourly variations
5. **Status Messages**: Online status and heartbeat signals

## 📞 Troubleshooting

### Common Issues:

**WiFi Connection Fails:**
- Check SSID and password
- Verify WiFi network is 2.4GHz (ESP32 doesn't support 5GHz)
- Move closer to router

**MQTT Connection Fails:**
- Verify broker URL and credentials
- Check firewall settings
- Test with MQTT client tools

**No Data on Dashboard:**
- Check MQTT topic names match exactly
- Verify JSON format is correct
- Monitor serial output for errors

**Commands Not Working:**
- Ensure subscribed to correct topic
- Check command JSON format
- Verify MQTT broker is relaying messages

## 🎯 Next Steps

1. **Deploy Multiple Devices**: Create sensor network
2. **Add Real Sensors**: Replace simulation with hardware
3. **Implement Alerts**: Set up threshold notifications
4. **Data Logging**: Store historical data for analysis
5. **Mobile App**: Create companion mobile interface

Happy building! 🚀

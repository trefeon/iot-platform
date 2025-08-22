# ESP32 Quick Configuration Summary

## 🚀 Quick Start

### 1. Update Firmware Configuration
Edit `firmware/esp32/src/main.cpp`:

```cpp
const char* WIFI_SSID = "Your_WiFi_Network";    // Change this
const char* WIFI_PASS = "Your_WiFi_Password";   // Change this  
const char* MQTT_HOST = "mqtt.trefeon.site";    // Use your domain
const char* DEVICE_ID = "esp32-01";             // Unique device ID
```

### 2. Flash ESP32
```bash
cd firmware/esp32
pio run --target upload
pio device monitor
```

### 3. View Data
- **Live Dashboard**: https://demo.trefeon.site
- **MQTT Test Interface**: https://mqtt.trefeon.site
- **Device Control**: https://control.trefeon.site (protected)
- **Admin Panel**: https://admin.trefeon.site (protected)

## 📊 Sensor Data Generated

The ESP32 simulates **8 types of realistic sensor data**:

1. **🌡️ Temperature**: 18-30°C with daily patterns
2. **💧 Humidity**: 30-80% (inversely related to temperature)
3. **🔵 Pressure**: 980-1040 hPa atmospheric pressure
4. **☀️ Light**: 0-1000 lux with day/night cycles
5. **🌱 Soil Moisture**: 20-70% for agriculture monitoring
6. **💨 Air Quality**: Gas resistance for air quality assessment
7. **🔋 Battery**: 10-100% with charging simulation
8. **📱 Motion**: Accelerometer/gyroscope with vibration detection

## 🎮 Device Controls

Send commands via dashboard or MQTT:

- **LED Control**: Turn on/off built-in LED
- **Sensor Reset**: Reset all sensors to baseline values
- **Temperature Config**: Update temperature baseline
- **Device Restart**: Simulate device reboot

## 📡 MQTT Topics

### Published by ESP32:
- `devices/esp32-01/environmental` - Temperature, humidity, pressure, light, soil, air quality
- `devices/esp32-01/motion` - Accelerometer, gyroscope, vibration data
- `devices/esp32-01/power` - Battery, charging status, power consumption
- `devices/esp32-01/telemetry` - Device status, WiFi, memory, uptime
- `devices/esp32-01/status` - Online/offline status, events

### Subscribe for Commands:
- `devices/esp32-01/cmd` - Receive control commands

## ✅ Success Indicators

Your ESP32 is working when you see:

1. **Serial Output**: WiFi connected, MQTT messages flowing
2. **Dashboard Updates**: Real-time data on demo website (8 sensor cards)
3. **Command Response**: LED control and sensor resets work
4. **Realistic Patterns**: Temperature rises during day, humidity varies
5. **Multiple Charts**: Environmental + Power/Motion visualizations

## 🛠️ Troubleshooting

### Common Issues:
- **No WiFi**: Check 2.4GHz network, move closer to router
- **MQTT Fails**: Verify broker URL `mqtt.trefeon.site:1883`
- **No Dashboard Data**: Check device ID matches `esp32-01`
- **Commands Don't Work**: Verify MQTT topic subscription

### Debug Tools:
```bash
# Monitor ESP32 serial output
pio device monitor

# Test MQTT connectivity
mosquitto_sub -h mqtt.trefeon.site -t "devices/+/+"

# Send test command  
mosquitto_pub -h mqtt.trefeon.site -t "devices/esp32-01/cmd" -m '{"action":"led","value":1}'
```

## 🎯 Next Steps

1. **Add More Devices**: Change `DEVICE_ID` for multiple ESP32s
2. **Real Sensors**: Replace simulation with actual hardware
3. **Data Analysis**: View historical trends and patterns
4. **Alerts**: Set up threshold notifications
5. **Mobile Access**: Dashboard works on phones/tablets

**Live Demo**: https://demo.trefeon.site 🌟

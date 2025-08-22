# 🔧 ESP32 Setup for Arduino IDE

## 📱 Required Libraries

Install these libraries through Arduino IDE Library Manager:

1. **DHT sensor library** by Adafruit
   - Library Manager → Search "DHT sensor library" → Install
   - Also installs "Adafruit Unified Sensor" automatically

2. **PubSubClient** by Nick O'Leary
   - Library Manager → Search "PubSubClient" → Install

3. **ArduinoJson** by Benoit Blanchon
   - Library Manager → Search "ArduinoJson" → Install

## ⚙️ Arduino IDE Setup

### 1. Install ESP32 Board Support
1. Open Arduino IDE
2. Go to **File** → **Preferences**
3. Add this URL to "Additional Boards Manager URLs":
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Go to **Tools** → **Board** → **Boards Manager**
5. Search for "ESP32" and install "ESP32 by Espressif Systems"

### 2. Configure Board Settings
- **Board**: "ESP32 Dev Module"
- **Upload Speed**: "921600"
- **CPU Frequency**: "240MHz (WiFi/BT)"
- **Flash Frequency**: "80MHz"
- **Flash Mode**: "QIO"
- **Flash Size**: "4MB (32Mb)"
- **Partition Scheme**: "Default 4MB with spiffs"
- **Core Debug Level**: "None"
- **PSRAM**: "Disabled"

### 3. Wiring Diagram

```
ESP32 Pin    →    Component
GPIO 4       →    DHT22 Data Pin
GPIO 34      →    LDR (Light Sensor)
GPIO 2       →    Built-in LED
3.3V         →    DHT22 VCC, LDR VCC
GND          →    DHT22 GND, LDR GND (through 10kΩ resistor)
```

### 4. Upload Process
1. Open `esp32-sensor.ino` in Arduino IDE
2. Update WiFi credentials and server IP in the code
3. Connect ESP32 via USB
4. Select correct COM port in **Tools** → **Port**
5. Click **Upload** button

## 🔍 Troubleshooting

**Upload Failed:**
- Press and hold BOOT button while uploading
- Try lower upload speed (115200)
- Check USB cable and drivers

**WiFi Connection Issues:**
- Verify SSID and password
- Check ESP32 is in range
- Monitor Serial output (115200 baud)

**Sensor Reading Issues:**
- Check wiring connections
- Verify 3.3V power supply
- DHT22 needs 10kΩ pull-up resistor on data line

## 📊 Monitoring
- Open **Tools** → **Serial Monitor**
- Set baud rate to **115200**
- Watch for connection status and sensor readings

---
**💡 Tip**: Keep Serial Monitor open to debug any issues!

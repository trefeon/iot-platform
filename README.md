# 🌟 IoT Sensor Platform

> Complete IoT monitoring system: ESP32 → MQTT → FastAPI → Real-time Dashboard

## 🎯 **Skills Demonstrated**
✅ **Hardware** - ESP32 + Sensors  
✅ **Backend** - FastAPI + MQTT + SQLite  
✅ **Frontend** - Real-time Dashboard  
✅ **DevOps** - Docker Deployment  

## 🚀 **Quick Start**
```bash
git clone https://github.com/trefeon/iot-platform.git
cd iot-platform
docker-compose up -d
# → http://localhost:8000
```

## 🔧 **ESP32 Setup**
1. **Libraries**: `DHT sensor library`, `PubSubClient`, `ArduinoJson`
2. **Code**: Update WiFi/IP in `firmware/esp32-sensor.ino`
3. **Flash**: Upload to ESP32 via Arduino IDE

## 🏗️ **Architecture**
```
ESP32 Sensors → WiFi → MQTT → FastAPI → SQLite → Dashboard
```

## 📦 **Hardware**
- ESP32 + DHT22 + LDR + Breadboard
- **Wiring**: GPIO4→DHT22, GPIO34→LDR, 3.3V→VCC, GND→GND

## 📊 **Features**
- 📡 Real-time sensor monitoring
- 📈 Historical data & charts  
- 📱 Responsive web interface
- 🔧 Device management & control

## 🛠️ **Tech Stack**
| Layer | Technology |
|-------|------------|
| Hardware | ESP32, DHT22, LDR |
| Communication | MQTT |
| Backend | Python FastAPI |
| Database | SQLite |
| Frontend | HTML/JS + Chart.js |
| Deployment | Docker Compose |

## 📁 **Project Structure**
```
iot-platform/
├── main.py              # FastAPI application
├── docker-compose.yml   # Container setup
├── firmware/esp32-sensor.ino  # Arduino code
├── static/index.html    # Dashboard UI
└── config/mosquitto.conf # MQTT config
```

## 🔍 **Why This Project?**
🎯 **Demonstrates full-stack IoT expertise**  
🎯 **Modern, production-ready technologies**  
🎯 **Clean, maintainable codebase**  
🎯 **Real hardware integration**  
🎯 **Professional deployment practices**

---
**Portfolio Project** | [Live Demo](http://portfolio.yourdomain.com) | [Source](https://github.com/trefeon/iot-platform)

# 🌟 IoT Sensor Platform - Portfolio Project

> A complete IoT monitoring system built with ESP32, FastAPI, and real-time dashboard. Perfect for demonstrating full-stack development skills.

![Dashboard Preview](https://via.placeholder.com/600x300/667eea/ffffff?text=Real-time+IoT+Dashboard)

## 🎯 **What This Demonstrates**

✅ **Hardware Integration** - ESP32 with real sensors  
✅ **Backend Development** - FastAPI + MQTT + SQLite  
✅ **Frontend Skills** - Responsive dashboard with live charts  
✅ **DevOps** - Docker containerization  
✅ **IoT Protocols** - MQTT messaging  

## 🚀 **Quick Start**

### 1. **Deploy Platform**
```bash
git clone https://github.com/trefeon/iot-platform.git
cd iot-platform
docker-compose up -d
```

### 2. **Setup ESP32**
1. Install Arduino IDE libraries: `DHT sensor library`, `PubSubClient`, `ArduinoJson`
2. Open `firmware/esp32-sensor.ino` 
3. Update WiFi credentials and server IP
4. Flash to ESP32

### 3. **View Dashboard**
- **Local**: http://localhost:8000
- **Live Demo**: [portfolio.yourdomain.com](http://portfolio.yourdomain.com)

## 🔧 **Hardware Setup**

**Components:**
- ESP32 development board
- DHT22 (temperature/humidity sensor)
- LDR (light sensor)
- Breadboard + jumper wires

**Wiring:**
```
ESP32 GPIO 4  → DHT22 Data
ESP32 GPIO 34 → LDR Signal
ESP32 3.3V    → Sensors VCC
ESP32 GND     → Sensors GND
```

## 🏗️ **Architecture**

```
ESP32 Sensors → WiFi → MQTT → FastAPI → SQLite → Dashboard
```

**Tech Stack:**
- **Hardware**: ESP32 + Sensors
- **Communication**: MQTT
- **Backend**: Python FastAPI
- **Database**: SQLite
- **Frontend**: HTML/JS + Chart.js
- **Deployment**: Docker Compose

## 📊 **Features**

- 📡 **Real-time monitoring** - Live sensor data every 10 seconds
- 📈 **Historical charts** - Temperature, humidity, light trends  
- 📱 **Responsive design** - Works on mobile and desktop
- 🔧 **Device management** - Online/offline status tracking
- 🎛️ **Remote control** - LED control, device restart
- 📊 **Statistics** - Total readings, 24h activity

## 🎨 **ESP32 Arduino IDE Setup**

**Required Libraries:**
1. **DHT sensor library** (Adafruit)
2. **PubSubClient** (Nick O'Leary)  
3. **ArduinoJson** (Benoit Blanchon)

**Board Configuration:**
- Board: "ESP32 Dev Module"
- Upload Speed: "921600"
- CPU Frequency: "240MHz (WiFi/BT)"

**Upload Process:**
1. Connect ESP32 via USB
2. Select correct COM port
3. Update WiFi credentials in code
4. Click Upload

## 📁 **Project Structure**

```
iot-platform/
├── main.py                 # FastAPI application
├── docker-compose.yml      # Container orchestration
├── requirements.txt        # Python dependencies
├── static/index.html       # Dashboard frontend
├── firmware/
│   └── esp32-sensor.ino   # Arduino code
└── config/
    └── mosquitto.conf     # MQTT broker config
```

## 🛠️ **Development**

**Local Development:**
```bash
# Install dependencies
pip install -r requirements.txt

# Run API server
python main.py

# Run MQTT broker (separate terminal)
docker run -it -p 1883:1883 eclipse-mosquitto:2
```

**Production Deployment:**
```bash
# Ubuntu server setup
chmod +x setup.sh && ./setup.sh

# Deploy with Docker
docker-compose up -d

# Check status
docker-compose ps
```

## 🔍 **Troubleshooting**

**ESP32 Issues:**
- ❌ Upload failed → Hold BOOT button while uploading
- ❌ WiFi not connecting → Check credentials and signal strength
- ❌ No sensor data → Verify wiring and power supply

**Platform Issues:**
- ❌ No dashboard → Check `docker-compose ps`, ensure port 8000 is open
- ❌ No MQTT data → Check broker logs: `docker-compose logs mqtt`
- ❌ Database errors → Check data directory permissions

## 📄 **Why This Project?**

This IoT platform perfectly demonstrates:

🎯 **Technical Breadth** - Hardware to cloud integration  
🎯 **Modern Stack** - Current technologies employers want  
🎯 **Real Functionality** - Not just a demo, actually works  
🎯 **Professional Quality** - Clean code, documentation, deployment  
🎯 **Scalable Design** - Easy to extend and maintain  

---

**Built for portfolio demonstration** | [Live Demo](http://portfolio.yourdomain.com) | [Source Code](https://github.com/trefeon/iot-platform)

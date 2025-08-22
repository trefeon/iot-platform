# 🌟 Simple IoT Platform - Portfolio Project

A clean, focused IoT monitoring platform designed to showcase full-stack development skills for portfolio presentations.

## 🎯 What This Project Demonstrates

- **Hardware Integration**: ESP32 with real sensors (DHT22, LDR)
- **Backend Development**: FastAPI with MQTT and SQLite
- **Frontend Skills**: Responsive web dashboard with real-time charts
- **DevOps**: Docker containerization and deployment
- **Cloud Security**: Cloudflare Zero Trust integration
- **IoT Protocols**: MQTT for reliable device communication

## 🚀 Quick Start

### 1. Server Setup (Ubuntu)
```bash
# Download and run setup script
wget https://raw.githubusercontent.com/yourusername/simple-iot-platform/main/setup.sh
chmod +x setup.sh
./setup.sh
```

### 2. Deploy the Platform
```bash
# Clone project
git clone https://github.com/yourusername/simple-iot-platform.git
cd simple-iot-platform

# Start services
docker-compose -f simple-docker-compose.yml up -d

# Check status
docker-compose -f simple-docker-compose.yml ps
```

### 3. Configure ESP32
1. Install Arduino IDE and required libraries:
   - DHT sensor library (Adafruit)
   - PubSubClient (Nick O'Leary)
   - ArduinoJson (Benoit Blanchon)

2. Open `firmware/esp32-sensor.ino` in Arduino IDE

3. Update WiFi credentials and server IP in the code

4. Flash to your ESP32 (see `firmware/ESP32_ARDUINO_SETUP.md` for detailed instructions)

### 4. Set up Cloudflare Tunnel (Optional)
1. Create a Cloudflare account and add your domain
2. Install cloudflared on your server
3. Create a tunnel: `cloudflared tunnel create iot-platform`
4. Configure DNS: `cloudflared tunnel route dns iot-platform portfolio.yourdomain.com`
5. Update `CLOUDFLARE_TUNNEL_TOKEN` in `.env`

## 📊 Architecture

```
ESP32 Sensors → WiFi → MQTT Broker → FastAPI → SQLite
                                        ↓
                                 Web Dashboard
                                        ↓
                             Cloudflare Tunnel
                                        ↓
                          portfolio.yourdomain.com
```

## 🔧 Hardware Requirements

**Minimum Setup:**
- ESP32 development board
- DHT22 temperature/humidity sensor
- LDR (Light Dependent Resistor)
- Breadboard and jumper wires

**Wiring:**
- DHT22 data pin → GPIO 4
- LDR → GPIO 34 (with pull-down resistor)
- LED → GPIO 2 (built-in LED)

## 📱 Features

- **Real-time Monitoring**: Live sensor data updates every 10 seconds
- **Historical Data**: SQLite database with automatic retention
- **Device Management**: Online/offline status tracking
- **Responsive Design**: Works on desktop and mobile
- **Remote Control**: Send commands to ESP32 (LED control, restart)
- **Statistics**: Total readings, 24-hour activity, device count

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Hardware | ESP32 + Sensors | Data collection |
| Communication | MQTT | Reliable messaging |
| Backend | FastAPI | REST API and real-time data |
| Database | SQLite | Simple, embedded storage |
| Frontend | HTML/JS/Chart.js | Data visualization |
| Deployment | Docker Compose | Easy deployment |
| Security | Cloudflare Zero Trust | Secure public access |

## 📈 Why This is Perfect for a Portfolio

1. **Demonstrates Range**: Shows hardware, software, and cloud skills
2. **Real-world Application**: Actual IoT use case, not just a demo
3. **Professional Deployment**: Production-ready with Docker and security
4. **Scalable Design**: Easy to extend with more sensors/features
5. **Clean Code**: Well-structured, documented, maintainable
6. **Modern Stack**: Current technologies employers want to see

## 🔐 Security Features

- **Cloudflare Zero Trust**: Secure public access without exposing server
- **MQTT Authentication**: Can be enabled for production use
- **Docker Isolation**: Services run in isolated containers
- **Environment Variables**: Sensitive data not hardcoded

## 📊 API Endpoints

- `GET /` - Dashboard homepage
- `GET /api/current` - Current sensor readings
- `GET /api/history` - Historical data (last 24 hours)
- `GET /api/devices` - Connected device list
- `GET /api/stats` - Platform statistics

## 🎨 Customization Ideas

- Add more sensor types (pressure, CO2, etc.)
- Implement alerts/notifications
- Add data export functionality
- Create mobile app with same API
- Add machine learning predictions
- Implement device grouping/locations

## 📝 Environment Variables

```bash
# MQTT Configuration
MQTT_BROKER=mqtt
MQTT_PORT=1883

# Cloudflare Tunnel
CLOUDFLARE_TUNNEL_TOKEN=your_token_here

# Timezone
TZ=UTC
```

## 🐛 Troubleshooting

**ESP32 not connecting to WiFi:**
- Double-check WiFi credentials
- Verify ESP32 is in range
- Check serial monitor for error messages

**No data in dashboard:**
- Verify MQTT broker is running: `docker-compose logs mqtt`
- Check ESP32 serial output
- Ensure firewall allows port 1883

**Can't access dashboard:**
- Check if services are running: `docker-compose ps`
- Verify port 8000 is open
- Check application logs: `docker-compose logs api`

## 📄 License

MIT License - feel free to use this for your own portfolio!

## 🤝 Contributing

This is a portfolio project, but suggestions and improvements are welcome!

---

**Built with ❤️ for portfolio demonstration**
*Showcasing full-stack IoT development skills*

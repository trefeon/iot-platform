# IoT Platform

A complete IoT monitoring platform with ESP32 devices, real-time dashboard, and MQTT communication.

## Features
- Real-time device monitoring and control
- ESP32 multi-sensor data collection
- Web dashboard with live charts
- MQTT bidirectional communication
- Docker containerized deployment

## Quick Start

1. **Clone and start the platform:**
```bash
git clone https://github.com/trefeon/iot-platform.git
cd iot-platform
cp .env.example .env
docker compose up -d
```

2. **Setup ESP32:**
   - Update WiFi credentials in `firmware/esp32/src/main.cpp`
   - Upload firmware to ESP32

3. **Access dashboard:** http://YOUR_SERVER_IP:8080

## Documentation
- [Complete Setup Guide](SETUP-GUIDE.md) - Detailed installation and configuration
- [ESP32 Setup Guide](ESP32_SETUP_GUIDE.md) - ESP32 specific instructions
- [Ubuntu Server Setup](UBUNTU_SERVER_SETUP.md) - Server preparation guide

## Architecture
- **API**: FastAPI backend with MQTT integration
- **Database**: PostgreSQL with TimescaleDB
- **MQTT**: Eclipse Mosquitto broker
- **Frontend**: Real-time web dashboard
- **Monitoring**: Prometheus + Grafana

## Support
See [SETUP-GUIDE.md](SETUP-GUIDE.md) for troubleshooting and detailed documentation.

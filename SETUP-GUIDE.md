# 🚀 IoT Platform - Complete Setup Guide

## Overview
A complete IoT monitoring platform with ESP32 devices, MQTT messaging, real-time dashboard, and Docker deployment.

## Features
- **Real-time device monitoring** with live telemetry data
- **MQTT communication** for bidirectional device control
- **Web dashboard** with charts and device management
- **Docker containerization** for easy deployment
- **Automatic device status detection** (online/offline)
- **ESP32 firmware** with multi-sensor simulation

## Quick Start

### 1. Server Setup (Ubuntu)
```bash
# Clone the repository
git clone https://github.com/trefeon/iot-platform.git
cd iot-platform

# Copy environment configuration
cp .env.example .env

# Start the platform
docker compose up -d
```

### 2. ESP32 Setup
1. Update WiFi credentials in `firmware/esp32/src/main.cpp`:
```cpp
const char* WIFI_SSID = "YOUR_WIFI_NETWORK";
const char* WIFI_PASS = "YOUR_WIFI_PASSWORD";
```

2. Update server IP if needed:
```cpp
const char* MQTT_HOST = "192.168.123.7"; // Your server IP
```

3. Upload the firmware to your ESP32

### 3. Access the Platform
- **Dashboard**: http://YOUR_SERVER_IP:8080
- **API**: http://YOUR_SERVER_IP:8080/api
- **Grafana**: http://YOUR_SERVER_IP:3000

## Architecture

### Services
- **API**: FastAPI backend with MQTT integration
- **Database**: PostgreSQL with TimescaleDB for telemetry
- **MQTT Broker**: Eclipse Mosquitto for device communication
- **Dashboard**: Real-time web interface
- **Monitoring**: Prometheus + Grafana for metrics

### Data Flow
```
ESP32 → MQTT → API Server → Database → Web Dashboard
                ↓
        Device Commands ← MQTT ← API Endpoints
```

## ESP32 Commands

Send commands via the web dashboard or API:

- **LED Control**: Enable/disable activity blinking
- **Sensor Reset**: Reset baseline values
- **Temperature Base**: Set temperature baseline
- **Device Restart**: Reboot the ESP32

## Deployment Options

### Development (Local)
```bash
docker compose up -d
```

### Production (with SSL/monitoring)
```bash
docker compose -f docker-compose.prod.yml up -d
```

## Auto-Startup Setup

The platform includes automatic startup configuration:

1. **Crontab entry** for boot-time startup
2. **Systemd service** for system-level management
3. **Retry logic** with logging

If auto-startup fails, manually start with:
```bash
cd /path/to/iot-platform
docker compose up -d
```

## Troubleshooting

### ESP32 Not Showing Online
1. Check WiFi credentials
2. Verify server IP address
3. Check MQTT broker connectivity
4. Review ESP32 serial output

### Docker Issues
```bash
# Restart Docker daemon
sudo systemctl restart docker

# Check container status
docker compose ps

# View logs
docker compose logs api
```

### Device Status Issues
- Devices show as offline after 30 seconds without data
- Check MQTT connectivity and timestamps
- Verify database connectivity

## File Structure
```
iot-platform/
├── services/
│   ├── api/          # FastAPI backend
│   ├── broker/       # MQTT configuration
│   └── db/           # Database initialization
├── firmware/
│   └── esp32/        # ESP32 Arduino code
├── deploy/
│   └── nginx/        # Reverse proxy config
└── docker-compose.yml
```

## Development

### API Development
```bash
cd services/api
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### ESP32 Development
- Use Arduino IDE or PlatformIO
- Install required libraries: WiFi, PubSubClient, ArduinoJson
- Monitor serial output for debugging

## Security Features

- Environment-based configuration
- MQTT authentication
- Network isolation via Docker
- Cloudflare Zero Trust integration available

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## Support

For issues and questions:
- Check the troubleshooting section
- Review container logs
- Verify network connectivity
- Check ESP32 serial output

# 🚀 IoT Platform - Complete Zero Trust Solution

A production-ready IoT monitoring platform with ESP32 devices, real-time dashboard, MQTT communication, and enterprise security features.

## 🌟 Features

### Core Platform
- **Real-time device monitoring** with live telemetry data
- **ESP32 multi-sensor simulation** (temperature, humidity, pressure, light, motion, power)
- **MQTT bidirectional communication** for device control and data collection
- **Web dashboard** with interactive charts and device management
- **Docker containerized deployment** for easy scaling
- **Automatic device status detection** (online/offline tracking)

### Security & Operations
- **Cloudflare Zero Trust** integration with Access control
- **Multi-domain routing** (demo, control, admin, mqtt subdomains)
- **Production deployment** scripts and automation
- **Monitoring stack** with Prometheus + Grafana
- **Auto-startup** with systemd service integration

### Device Management
- **Remote device control** (LED, configuration, restart)
- **Real sensor integration** support (DHT22, BMP280, BH1750, etc.)
- **Realistic data simulation** with daily patterns and noise
- **Multiple ESP32 support** with unique device IDs

## 🏗️ Architecture

```
ESP32 Devices → WiFi → MQTT Broker → FastAPI → PostgreSQL
                         ↓              ↓
                   Device Commands  Web Dashboard
                                        ↓
                             Cloudflare Zero Trust
                                        ↓
                          demo.domain.com (Public)
                         control.domain.com (Protected)
                          admin.domain.com (Protected)
```

### Services
- **API**: FastAPI backend with MQTT integration and Cloudflare Access
- **Database**: PostgreSQL with TimescaleDB for time-series data
- **MQTT Broker**: Eclipse Mosquitto with authentication
- **Frontend**: Real-time web interface with Chart.js
- **Monitoring**: Prometheus + Grafana for metrics and visualization
- **Security**: Cloudflare Tunnel + Zero Trust Access

## ⚡ Quick Start

### Option 1: Using Convenience Script (Recommended)

```bash
# Linux/macOS
./iot.sh setup     # Initial setup
./iot.sh dev       # Start development environment

# Windows PowerShell
.\iot.ps1 setup    # Initial setup
.\iot.ps1 dev      # Start development environment
```

### Option 2: Manual Setup

### 1. Server Setup (Ubuntu)
```bash
# Clone the repository
git clone https://github.com/your-org/iot-platform.git
cd iot-platform

# Copy environment configuration
cp config/.env.example .env

# Edit environment with your settings
nano .env

# Start the platform
docker compose -f docker/docker-compose.yml up -d
```

### 2. ESP32 Setup
Update configuration in `firmware/esp32/src/main.cpp`:
```cpp
// ====== CHANGE THESE VALUES ======
const char* WIFI_SSID = "Your_WiFi_Network";
const char* WIFI_PASS = "Your_WiFi_Password";
const char* MQTT_HOST = "192.168.1.100"; // Your server IP
const char* DEVICE_ID = "esp32-01";      // Unique device identifier
```

Upload firmware:
```bash
cd firmware/esp32
pio run --target upload
pio device monitor  # View serial output
```

### 3. Access the Platform
- **Dashboard**: http://YOUR_SERVER_IP:8080
- **API**: http://YOUR_SERVER_IP:8080/api
- **Grafana**: http://YOUR_SERVER_IP:3000
- **Health Check**: http://YOUR_SERVER_IP:8080/health

## 📋 Complete Setup Guide

### Prerequisites
- Ubuntu Server 20.04 LTS or 22.04 LTS
- Domain name (for Cloudflare Zero Trust setup)
- ESP32 development board
- Internet connection

### Step 1: Ubuntu Server Preparation

#### Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim nano htop unzip software-properties-common
```

#### Install Docker
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
```

#### Configure Firewall
```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw status
```

### Step 2: Project Setup

#### Create Project Directory
```bash
sudo mkdir -p /opt/iot-platform
sudo chown -R $USER:$USER /opt/iot-platform
cd /opt/iot-platform
```

#### Clone and Configure
```bash
git clone https://github.com/your-org/iot-platform.git .
chmod +x scripts/deploy.sh scripts/startup-iot-platform.sh scripts/maintenance.sh

# Setup environment
cp config/.env.example .env
nano .env
```

#### Environment Configuration
Update `.env` with your settings:
```bash
# Database
POSTGRES_PASSWORD=your-secure-db-password
POSTGRES_USER=iotuser
POSTGRES_DB=iot_platform

# MQTT
MQTT_USER=devuser
MQTT_PASSWORD=your-secure-mqtt-password

# Grafana
GRAFANA_ADMIN_PASSWORD=your-secure-grafana-password

# API
API_JWT_SECRET=your-very-long-random-secret-key

# Domain (for Cloudflare setup)
DOMAIN=your-domain.com

# Cloudflare Access (configured later)
CF_ACCESS_CERTS=
CF_ACCESS_AUD=
```

### Step 3: Cloudflare Zero Trust Setup

#### Install Cloudflare Tunnel
```bash
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
cloudflared --version
```

#### Configure Zero Trust
```bash
# Run automated setup
./scripts/setup-cloudflare.sh your-domain.com

# Configure access policies
./scripts/setup-access-policies.sh your-domain.com
```

#### Manual Cloudflare Dashboard Setup
1. Go to **Cloudflare Dashboard** → **Zero Trust**
2. **Access** → **Applications** → **Add application**
3. Create applications for:
   - `control.your-domain.com` (Protected)
   - `admin.your-domain.com` (Protected)
   - `mqtt.your-domain.com` (Protected)
4. Set access policies to allow only your email
5. Copy Application Audience (AUD) tag to `.env`

### Step 4: Deploy Platform

#### Production Deployment
```bash
# Deploy with production configuration
./scripts/deploy.sh prod

# Check service status
docker compose -f docker/docker-compose.prod.yml ps
docker compose -f docker/docker-compose.prod.yml logs -f
```

#### Setup Auto-Startup
```bash
# Copy systemd service
sudo cp config/iot-platform.service /etc/systemd/system/

# Edit service file paths
sudo nano /etc/systemd/system/iot-platform.service

# Enable and start service
sudo systemctl enable iot-platform.service
sudo systemctl start iot-platform.service
sudo systemctl status iot-platform.service
```

## 🔧 ESP32 Configuration Guide

### Hardware Requirements
- **ESP32 Development Board** (ESP32-WROOM-32 or similar)
- **USB Cable** (for programming and power)
- **LED** (built-in LED on pin 2 is used)

### Optional Real Sensors
- **DHT22** - Temperature & Humidity
- **BMP280** - Temperature, Humidity & Pressure
- **BH1750** - Light sensor
- **MQ-135** - Air quality sensor
- **Soil moisture sensor**
- **MPU6050** - Accelerometer & Gyroscope

### Software Setup

#### Install PlatformIO
```bash
# Install VS Code extension: PlatformIO IDE
# Or install CLI version:
pip install platformio
```

#### Configure and Upload
```bash
cd firmware/esp32

# Edit configuration in src/main.cpp
nano src/main.cpp

# Upload firmware
pio run --target upload
pio device monitor
```

### MQTT Topics and Data Structure

#### Published Topics

**Environmental Data** (`devices/{device_id}/environmental`) - Every 10 seconds:
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

**Motion Data** (`devices/{device_id}/motion`) - Every 2 seconds:
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

**Power Data** (`devices/{device_id}/power`) - Every 30 seconds:
```json
{
  "battery": 85.5,          // %
  "charging": false,        // boolean
  "power_consumption": 1.2, // watts
  "voltage": 3.28           // volts
}
```

**Telemetry Data** (`devices/{device_id}/telemetry`) - Every 5 seconds:
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

#### Device Commands

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

**Device Restart:**
```json
{
  "action": "restart"
}
```

### Real Sensor Integration

#### DHT22 Temperature/Humidity
```cpp
#include <DHT.h>
#define DHT_PIN 4
#define DHT_TYPE DHT22
DHT dht(DHT_PIN, DHT_TYPE);

// In publishEnvironmentalData():
float temp = dht.readTemperature();
float humidity = dht.readHumidity();
```

#### BMP280 Pressure Sensor
```cpp
#include <Adafruit_BMP280.h>
Adafruit_BMP280 bmp;

// In publishEnvironmentalData():
float pressure = bmp.readPressure() / 100.0; // Convert to hPa
```

#### BH1750 Light Sensor
```cpp
#include <BH1750.h>
BH1750 lightMeter;

// In publishEnvironmentalData():
float light = lightMeter.readLightLevel();
```

## 🔐 Security Features

### Cloudflare Zero Trust Protection

#### Access Control Matrix
| Domain | Access Level | Authentication |
|--------|-------------|----------------|
| `demo.your-domain.com` | **Public** | None required |
| `control.your-domain.com` | **Restricted** | Email-based access |
| `admin.your-domain.com` | **Restricted** | Email-based access |
| `mqtt.your-domain.com` | **Restricted** | Email-based access |

#### Security Policies
- **Identity Providers**: Google, GitHub, or Email OTP
- **Access Rules**: Email-based restrictions
- **Session Management**: Configurable timeout
- **Device Certificates**: Optional for admin panel

### Production Security
```bash
# Change default credentials
MQTT_PASSWORD=secure-random-password
POSTGRES_PASSWORD=secure-random-password
GRAFANA_ADMIN_PASSWORD=secure-random-password

# Use TLS/SSL for MQTT (port 8883)
# Implement device certificates
# Add OTA (Over-The-Air) update capability
# Use WPA3 WiFi encryption
```

## 📊 Monitoring and Observability

### Prometheus Metrics
- Device connectivity status
- Message throughput
- System resource usage
- API response times

### Grafana Dashboards
- Real-time device telemetry
- Environmental trends
- Power consumption analytics
- Device health monitoring

### Logging
```bash
# View service logs
docker compose logs -f

# Specific service logs
docker compose logs api
docker compose logs broker
docker compose logs db

# ESP32 serial output
pio device monitor
```

## 🚨 Troubleshooting

### Common Issues

#### ESP32 Connection Problems
```bash
# Check WiFi credentials
# Verify MQTT broker connectivity
# Monitor serial output for errors
pio device monitor

# Test MQTT connection
mosquitto_pub -h YOUR_SERVER_IP -t "test/topic" -m "hello"
```

#### Docker Issues
```bash
# Restart Docker daemon
sudo systemctl restart docker

# Check container status
docker compose -f docker/docker-compose.yml ps

# View detailed logs
docker compose -f docker/docker-compose.yml logs

# Rebuild services
docker compose -f docker/docker-compose.yml build --no-cache
docker compose -f docker/docker-compose.yml up -d
```

#### Database Connection Issues
```bash
# Check PostgreSQL container
docker compose logs db

# Test database connection
docker compose exec db psql -U iotuser -d iot_platform -c "\dt"
```

#### MQTT Connection Issues
```bash
# Check Mosquitto broker
docker compose logs broker

# Test MQTT connectivity
mosquitto_sub -h localhost -p 1883 -t "devices/+/+" -u devuser -P devpass
```

### Performance Optimization

#### Database Tuning
```sql
-- Create indexes for time-series queries
CREATE INDEX IF NOT EXISTS telemetry_device_ts_idx ON telemetry(device_id, ts DESC);
CREATE INDEX IF NOT EXISTS telemetry_payload_idx ON telemetry USING GIN(payload);
```

#### MQTT Optimization
```bash
# Increase message buffer sizes
# Configure QoS levels appropriately
# Use retained messages for device status
```

## 📁 File Structure
```
iot-platform/
├── config/                     # Configuration files
│   ├── .env.example           # Environment template
│   ├── cloudflare-access.env.example
│   └── iot-platform.service   # Systemd service
├── docker/                     # Docker configurations
│   ├── docker-compose.yml     # Development setup
│   └── docker-compose.prod.yml # Production setup
├── scripts/                    # Deployment & maintenance
│   ├── deploy.sh              # Deployment automation
│   ├── startup-iot-platform.sh # Auto-startup script
│   └── maintenance.sh         # Maintenance utilities
├── services/
│   ├── api/                    # FastAPI backend
│   │   ├── app/
│   │   │   ├── main.py        # Application entry point
│   │   │   ├── models.py      # Data models
│   │   │   ├── mqtt_bus.py    # MQTT integration
│   │   │   ├── routers/       # API endpoints
│   │   │   └── static/        # Web dashboard
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── broker/                 # MQTT configuration
│   │   ├── mosquitto.conf
│   │   ├── passwd
│   │   └── aclfile
│   ├── db/                     # Database initialization
│   │   ├── Dockerfile
│   │   └── init/00_init.sql
│   └── observability/          # Monitoring stack
│       ├── prometheus.yml
│       └── grafana/
├── firmware/
│   └── esp32/                  # ESP32 Arduino code
│       ├── platformio.ini
│       └── src/main.cpp
├── deploy/
│   ├── nginx/                  # Reverse proxy config
│   └── cloudflare/            # Zero Trust config
└── README.md                   # Complete documentation
```

## 🎯 Production Deployment Checklist

### Pre-Deployment
- [ ] Domain registered and pointed to server
- [ ] SSL certificates configured (via Cloudflare)
- [ ] Environment variables set securely
- [ ] Database passwords changed from defaults
- [ ] MQTT credentials configured
- [ ] Grafana admin password set

### Security
- [ ] Cloudflare Zero Trust configured
- [ ] Access policies created for protected subdomains
- [ ] SSH keys configured (disable password auth)
- [ ] Firewall rules configured
- [ ] Regular security updates scheduled

### Monitoring
- [ ] Prometheus targets configured
- [ ] Grafana dashboards imported
- [ ] Alert rules configured
- [ ] Log aggregation setup
- [ ] Backup procedures established

### Operations
- [ ] Auto-startup service enabled
- [ ] Health checks configured
- [ ] Maintenance scripts tested
- [ ] Documentation updated
- [ ] Team access configured

## 🔄 Development Workflow

### Local Development
```bash
cd services/api
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### ESP32 Development
```bash
cd firmware/esp32
pio run
pio run --target upload
pio device monitor
```

### Testing
```bash
# API tests
pytest services/api/tests/

# MQTT connectivity test
python scripts/test_mqtt.py

# End-to-end test
python scripts/test_e2e.py
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues and questions:
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check troubleshooting sections above
- **Logs**: Review container and device logs
- **Community**: Join discussions in GitHub Discussions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **FastAPI** for the excellent web framework
- **Eclipse Mosquitto** for reliable MQTT messaging
- **Cloudflare** for Zero Trust security
- **ESP32** community for hardware support
- **Docker** for containerization platform

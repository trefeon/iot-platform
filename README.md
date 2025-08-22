# IoT Platform - Production Ready

A comprehensive IoT platform built with FastAPI, MQTT, PostgreSQL, and modern web interfaces. Features real-time monitoring, device management, and secure access control through Cloudflare Zero Trust.

## ✨ Features

- **Real-time Dashboard**: Interactive web interface with live sensor data visualization
- **Device Management**: Control panel for managing ESP32/IoT devices via MQTT
- **Admin Interface**: System monitoring and configuration management
- **Secure Access**: Cloudflare Zero Trust integration with email-based restrictions
- **Modern Architecture**: Docker containerized with FastAPI, PostgreSQL, TimescaleDB
- **Monitoring**: Integrated Grafana and Prometheus for system metrics
- **Responsive Design**: Mobile-friendly interfaces with Chart.js visualizations

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   ESP32/IoT     │    │   Cloudflare     │    │   Web Clients   │
│   Devices       │◄──►│   Zero Trust     │◄──►│   (Browser)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ MQTT Broker     │    │   Nginx Proxy    │    │   FastAPI       │
│ (Mosquitto)     │◄──►│   Load Balancer  │◄──►│   Backend       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ PostgreSQL      │    │   Grafana        │    │   Prometheus    │
│ + TimescaleDB   │    │   Dashboards     │    │   Metrics       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Ubuntu 24.04 LTS (recommended)
- Docker and Docker Compose
- Domain name with Cloudflare DNS

### 1. Clone and Setup
```bash
git clone https://github.com/[username]/iot-platform.git
cd iot-platform
./setup-cloudflare.sh yourdomain.com
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Deploy
```bash
docker compose up -d
```

### 4. Access Your Platform
- **Demo**: `https://demo.yourdomain.com` (Public access)
- **Control**: `https://control.yourdomain.com` (Protected)
- **Admin**: `https://admin.yourdomain.com` (Protected)

## 📖 Documentation

- [**Cloudflare Access Setup**](CLOUDFLARE-ACCESS-SETUP.md) - Security configuration
- [**Ubuntu Server Setup**](UBUNTU_SERVER_SETUP.md) - Complete server installation guide
- [**Git Workflow**](GIT_WORKFLOW.md) - Development and deployment workflow

## 🔐 Security Features

- **Zero Trust Access**: Cloudflare Access with email-based restrictions
- **MQTT Authentication**: Username/password protection for device communication
- **JWT Verification**: Server-side token validation for protected endpoints
- **SSL/TLS**: End-to-end encryption via Cloudflare
- **Network Isolation**: Docker container networking

## 🎯 Use Cases

- **Smart Home**: Monitor temperature, humidity, and control devices
- **Industrial IoT**: Production line monitoring and equipment management
- **Environmental Monitoring**: Weather stations and sensor networks
- **Prototype Development**: Rapid IoT application development platform

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | FastAPI + Python | REST API and business logic |
| **Database** | PostgreSQL + TimescaleDB | Time-series data storage |
| **Message Queue** | Eclipse Mosquitto (MQTT) | Device communication |
| **Frontend** | HTML5 + Chart.js | Real-time dashboards |
| **Proxy** | Nginx | Load balancing and routing |
| **Monitoring** | Grafana + Prometheus | System metrics and alerts |
| **Security** | Cloudflare Zero Trust | Access control and SSL |
| **Infrastructure** | Docker + Docker Compose | Container orchestration |

## 📊 Dashboard Features

### Demo Dashboard
- Real-time sensor data visualization
- Device status monitoring
- Interactive Chart.js graphs
- MQTT message console
- Mobile-responsive design

### Control Panel
- Device command interface
- MQTT WebSocket connections
- Real-time device status
- Command history and logging

### Admin Interface
- Service status monitoring
- System metrics (CPU, Memory, Disk)
- Configuration management
- Log viewer and backup tools
- Cloudflare tunnel status

## 🔧 Development

### Local Development
```bash
# Clone repository
git clone https://github.com/[username]/iot-platform.git
cd iot-platform

# Start development environment
docker compose -f docker-compose.yml up -d

# View logs
docker compose logs -f api
```

## 📝 API Endpoints

### Device Management
- `POST /api/devices/register` — Register new device
- `GET /api/devices` — List all devices
- `POST /api/commands/{device_id}` — Send command to device

### Telemetry
- `POST /api/telemetry/{device_id}` — Ingest telemetry data
- `GET /api/telemetry/{device_id}` — Retrieve device telemetry

### System
- `GET /api/health` — System health check
- `GET /metrics` — Prometheus metrics endpoint

## 🔍 Monitoring and Maintenance

### Health Checks
```bash
# Platform validation
./validate-deployment.sh

# Service status
docker compose ps

# View metrics
curl http://localhost:2000/metrics
```

### ESP32 Integration
1. Flash firmware from `firmware/esp32` directory using PlatformIO
2. Configure device credentials in web interface
3. Monitor real-time telemetry in dashboard
4. Send commands via control panel

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Eclipse Mosquitto](https://mosquitto.org/) - MQTT message broker
- [TimescaleDB](https://www.timescale.com/) - Time-series database
- [Chart.js](https://www.chartjs.org/) - Data visualization
- [Cloudflare](https://www.cloudflare.com/) - Security and performance

## 📞 Support

- **Documentation**: Check the documentation files for detailed guides
- **Issues**: Open an issue on GitHub for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and community support

---

**🚀 Ready to build your IoT platform?** Follow the quick start guide above!

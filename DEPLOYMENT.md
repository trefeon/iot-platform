# Secure IoT + CPS Platform

## Development Setup (Windows)

### Prerequisites
- Docker Desktop
- Git
- VS Code (recommended)
- PlatformIO (for ESP32 development)

### Quick Start
1. Clone the repository
2. Copy `.env.example` to `.env` and configure your settings
3. Run `docker compose up -d`
4. Access services:
   - API Documentation: http://localhost:8080/docs
   - Grafana Dashboard: http://localhost:3000
   - Prometheus: http://localhost:9090

## Production Deployment (Linux Server)

### Prerequisites
- Docker & Docker Compose
- Git
- Domain name (for SSL/TLS)
- Firewall configuration

### Deployment Steps
1. Clone repository on server
2. Configure production environment variables
3. Set up SSL certificates
4. Configure firewall rules
5. Deploy with `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

### Security Considerations
- Change default passwords in `.env`
- Use strong MQTT credentials
- Enable TLS for MQTT (port 8883)
- Set up proper firewall rules
- Use SSL certificates for web interface
- Regular security updates

## Git Workflow

### Development Branch Strategy
- `main` - Production-ready code
- `dev` - Development branch
- `feature/*` - Feature branches

### Deployment
```bash
# Development
git push origin dev

# Production
git push origin main
```

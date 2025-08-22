# IoT Platform - Git Workflow Guide

## Windows Development Setup

### 1. Initial Setup
```powershell
# Configure Git (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Navigate to project directory
cd "e:\Coding\Signature Portfolio Project\iot-platform"
```

### 2. Connect to GitHub
```powershell
# Add your GitHub repository as remote origin
git remote add origin https://github.com/YOUR_USERNAME/iot-platform.git

# Push initial code to main branch
git push -u origin main

# Push development branch
git push -u origin dev
```

### 3. Daily Development Workflow
```powershell
# Switch to dev branch
git checkout dev

# Make your changes, then stage and commit
git add .
git commit -m "Add feature: your description"

# Push to dev branch
git push origin dev
```

### 4. Release to Production
```powershell
# Switch to main branch
git checkout main

# Merge dev into main
git merge dev

# Push to production
git push origin main
```

## Linux Server Deployment

### 1. Server Prerequisites
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install Git
sudo apt install git -y

# Logout and login again to apply docker group changes
```

### 2. Deploy from GitHub
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/iot-platform.git
cd iot-platform

# Make deploy script executable
chmod +x deploy.sh

# Deploy development version
./deploy.sh dev

# OR deploy production version
./deploy.sh prod
```

### 3. Update Deployment
```bash
# Pull latest changes and redeploy
./deploy.sh dev   # for development
./deploy.sh prod  # for production
```

## GitHub Repository Setup

### 1. Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `iot-platform`
3. Description: "Secure IoT + CPS Platform with ESP32, MQTT, FastAPI, PostgreSQL"
4. Choose Public or Private
5. Do NOT initialize with README (we already have files)
6. Click "Create repository"

### 2. GitHub Secrets (for CI/CD - Optional)
Add these secrets in your GitHub repository settings:
- `SERVER_HOST`: Your Linux server IP/hostname
- `SERVER_USER`: SSH username for your server
- `SERVER_SSH_KEY`: Private SSH key for server access
- `DOCKER_USERNAME`: Docker Hub username (if using private images)
- `DOCKER_PASSWORD`: Docker Hub password

## Firewall Configuration (Linux Server)

### Ubuntu/Debian UFW
```bash
# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Allow MQTT (if exposing externally)
sudo ufw allow 1883  # Development
sudo ufw allow 8883  # Production (TLS)

# Allow monitoring (internal only)
sudo ufw allow from 10.0.0.0/8 to any port 3000  # Grafana
sudo ufw allow from 10.0.0.0/8 to any port 9090  # Prometheus
```

### CentOS/RHEL Firewalld
```bash
# Start firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Allow services
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Allow MQTT ports
sudo firewall-cmd --permanent --add-port=1883/tcp
sudo firewall-cmd --permanent --add-port=8883/tcp

# Reload firewall
sudo firewall-cmd --reload
```

## SSL/TLS Setup (Production)

### Using Let's Encrypt (Recommended)
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificates (replace yourdomain.com)
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com

# Certificates will be automatically placed in /etc/letsencrypt/live/yourdomain.com/
# Link them to your project
sudo ln -s /etc/letsencrypt/live/yourdomain.com/fullchain.pem deploy/certs/
sudo ln -s /etc/letsencrypt/live/yourdomain.com/privkey.pem deploy/certs/
```

## Monitoring Setup

### 1. Access Grafana
- URL: http://your-server:3000
- Default login: admin/admin (change immediately)

### 2. Add Data Sources
- Prometheus: http://prometheus:9090
- PostgreSQL: host=db, port=5432, database=iot

### 3. Import Dashboards
- MQTT Broker monitoring
- System metrics
- Application metrics

## Troubleshooting

### Common Issues
```bash
# Check service status
docker compose ps

# View logs
docker compose logs [service-name]

# Restart services
docker compose restart [service-name]

# Full restart
docker compose down && docker compose up -d
```

### MQTT Connection Issues
```bash
# Test MQTT connection
mosquitto_pub -h localhost -p 1883 -u devuser -P devpass -t test -m "hello"
mosquitto_sub -h localhost -p 1883 -u devuser -P devpass -t test
```

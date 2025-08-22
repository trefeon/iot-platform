# 🚀 Ubuntu Server Setup - Quick Start Cheat Sheet

**For brand new Ubuntu server → IoT Platform deployment**

## ⚡ Super Quick Setup (Copy-Paste Ready)

### 1. Initial System Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essentials
sudo apt install -y curl wget git vim nano htop unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Setup firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
```

### 2. Install Docker (One Command)
```bash
# Complete Docker installation
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $USER && rm get-docker.sh
```

**⚠️ Important: Logout and login again after Docker install!**

### 3. Install Cloudflare Tunnel
```bash
# Install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm cloudflared-linux-amd64.deb
```

### 4. Setup IoT Platform
```bash
# Create project directory
sudo mkdir -p /opt/iot-platform
sudo chown -R $USER:$USER /opt/iot-platform
cd /opt/iot-platform

# Clone repository
git clone https://github.com/trefeon/iot-platform.git .
chmod +x *.sh

# Configure environment
cp .env.example .env
nano .env  # Edit passwords and domain
```

### 5. Setup Cloudflare (Replace with your domain)
```bash
# Setup tunnel (replace with your domain)
./setup-cloudflare.sh your-domain.com
```

### 6. Deploy Platform
```bash
# Deploy and test
./deploy.sh dev
docker compose ps  # Check all services are up
```

## 🔍 Essential Commands

### Check Everything is Working
```bash
# System status
docker compose ps
sudo systemctl status cloudflared

# Test local access
curl http://localhost:8080/health
curl http://localhost:8080/grafana/api/health

# Check logs if issues
docker compose logs api
docker compose logs broker
```

### Troubleshooting
```bash
# Restart services
docker compose restart

# Check system resources
htop
df -h
free -h

# View logs
docker compose logs -f [service-name]
sudo journalctl -u cloudflared -f
```

## 🎯 Your URLs After Setup

- **Public Demo**: `https://demo.your-domain.com/grafana/`
- **Control Panel**: `https://control.your-domain.com/control` 
- **MQTT Test**: `https://mqtt.your-domain.com/mqtt-test`

## ⚙️ Important .env Settings

```bash
# Change these passwords!
POSTGRES_PASSWORD=your-secure-password
GRAFANA_ADMIN_PASSWORD=your-grafana-password  
MQTT_PASSWORD=your-mqtt-password
API_JWT_SECRET=very-long-random-string

# Your domain
DOMAIN=your-domain.com

# Cloudflare (get from CF dashboard)
CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs
CF_ACCESS_AUD=your-audience-id
```

## 📱 ESP32 Configuration

```cpp
const char* WIFI_SSID = "your-wifi";
const char* WIFI_PASS = "your-password";
const char* MQTT_HOST = "your-domain.com";  // Your domain
const char* MQTT_USER = "devuser";
const char* MQTT_PASS = "your-mqtt-password";  // From .env
```

## 🆘 Emergency Commands

```bash
# Stop everything
docker compose down

# Start everything
docker compose up -d

# Restart Cloudflare tunnel
sudo systemctl restart cloudflared

# Reset and redeploy
docker compose down -v
./deploy.sh dev
```

---

**Total setup time: ~15-20 minutes** ⏱️

**Need help?** Check the full guide: `UBUNTU_SERVER_SETUP.md`

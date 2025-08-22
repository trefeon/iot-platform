# 🚀 Fresh Ubuntu Server Setup for IoT Platform

Complete guide to set up a brand new Ubuntu server for your Zero Trust IoT Platform deployment.

## 📋 Prerequisites

- Fresh Ubuntu Server 20.04 LTS or 22.04 LTS
- Root or sudo access
- Internet connection
- Domain name pointed to your server IP (for Cloudflare setup)

---

## 🔧 Step 1: Initial Server Setup

### Update System
```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim nano htop unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

### Create Non-Root User (if needed)
```bash
# Create new user (replace 'iotuser' with your preferred username)
sudo adduser iotuser

# Add user to sudo group
sudo usermod -aG sudo iotuser

# Switch to new user
su - iotuser
```

### Configure SSH (Security)
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended changes:
# PermitRootLogin no
# PasswordAuthentication no  # Only if you have SSH keys set up
# Port 2222  # Change default port (optional)

# Restart SSH service
sudo systemctl restart sshd
```

### Setup Firewall
```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH (adjust port if you changed it)
sudo ufw allow ssh
# OR if you changed port: sudo ufw allow 2222

# Allow HTTP/HTTPS for web services
sudo ufw allow 80
sudo ufw allow 443

# Check firewall status
sudo ufw status
```

---

## 🐳 Step 2: Install Docker & Docker Compose

### Install Docker
```bash
# Remove old versions (if any)
sudo apt remove docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Test Docker Installation
```bash
# Logout and login again to apply group changes
exit
# Login again via SSH

# Test Docker
docker --version
docker compose version

# Test with hello-world
docker run hello-world
```

---

## 🌐 Step 3: Install Cloudflare Tunnel

### Install cloudflared
```bash
# Download latest cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Install the package
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify installation
cloudflared --version

# Clean up
rm cloudflared-linux-amd64.deb
```

---

## 📁 Step 4: Setup Project Directory

### Create Project Structure
```bash
# Create project directory
sudo mkdir -p /opt/iot-platform

# Change ownership to current user
sudo chown -R $USER:$USER /opt/iot-platform

# Navigate to project directory
cd /opt/iot-platform
```

---

## 📦 Step 5: Clone and Setup IoT Platform

### Clone Repository
```bash
# Clone your IoT platform repository
git clone https://github.com/trefeon/iot-platform.git .

# Make scripts executable
chmod +x deploy.sh
chmod +x setup-cloudflare.sh

# List files to verify
ls -la
```

### Setup Environment
```bash
# Copy environment template
cp .env.example .env

# Edit environment file
nano .env
```

**Important `.env` settings to configure:**
```bash
# Change these default passwords!
POSTGRES_PASSWORD=your-secure-db-password
GRAFANA_ADMIN_PASSWORD=your-secure-grafana-password
MQTT_PASSWORD=your-secure-mqtt-password
API_JWT_SECRET=your-very-long-random-secret-key

# Your domain (will be set during Cloudflare setup)
DOMAIN=your-domain.com

# Cloudflare settings (will be configured later)
CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs
CF_ACCESS_AUD=your-app-audience-id
```

---

## 🔒 Step 6: Configure Cloudflare Zero Trust

### Prerequisites
- Domain managed by Cloudflare
- Cloudflare account with Zero Trust enabled

### Setup Cloudflare Tunnel
```bash
# Run the automated setup script
./setup-cloudflare.sh your-domain.com
```

This script will:
1. Login to Cloudflare (opens browser)
2. Create tunnel named "iot-demo"
3. Setup DNS records for subdomains
4. Configure systemd service
5. Start the tunnel

### Manual Cloudflare Access Setup

**In Cloudflare Dashboard:**

1. **Go to Zero Trust → Access → Applications**

2. **Create Application: IoT Control Panel**
   - Type: Self-hosted
   - Application Domain: `control.your-domain.com`
   - Session Duration: 24 hours
   
3. **Add Policy: Allow Specific Users**
   - Rule name: "Authorized Users"
   - Action: Allow
   - Include: Emails → Add your email addresses

4. **Create Application: IoT MQTT Interface**
   - Type: Self-hosted  
   - Application Domain: `mqtt.your-domain.com`
   - Same policies as Control Panel

5. **Get Application Audience ID**
   - Copy the AUD value from application settings
   - Update your `.env` file:
   ```bash
   CF_ACCESS_AUD=your-copied-audience-id
   CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs
   ```

---

## 🚀 Step 7: Deploy IoT Platform

### Initial Deployment
```bash
# Navigate to project directory
cd /opt/iot-platform

# Deploy development version first (for testing)
./deploy.sh dev
```

### Check Deployment
```bash
# Check all services are running
docker compose ps

# Should show 5 services: db, broker, api, nginx, prometheus, grafana
# All should be "Up" or "Up (healthy)"

# Check logs if any issues
docker compose logs api
docker compose logs broker
```

---

## 🔍 Step 8: Verify Everything Works

### Test Local Access
```bash
# Test API health
curl http://localhost:8080/health

# Should return: {"status":"healthy","service":"iot-platform-api"}

# Test Grafana
curl http://localhost:8080/grafana/api/health

# Test MQTT broker
mosquitto_pub -h localhost -p 1883 -u devuser -P your-mqtt-password -t test -m "hello"
```

### Test External Access (via Cloudflare)
Open browser and test:
- `https://demo.your-domain.com/grafana/` (public access)
- `https://control.your-domain.com/control` (requires login)
- `https://mqtt.your-domain.com/mqtt-test` (requires login)

---

## 🛡️ Step 9: Security Hardening

### Configure Automatic Updates
```bash
# Install unattended upgrades
sudo apt install -y unattended-upgrades

# Configure automatic security updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Setup Log Monitoring
```bash
# Install fail2ban for intrusion prevention
sudo apt install -y fail2ban

# Create custom jail for SSH
sudo nano /etc/fail2ban/jail.local
```

Add to `/etc/fail2ban/jail.local`:
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
```

```bash
# Start and enable fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

### Firewall Final Configuration
```bash
# Only allow necessary ports
sudo ufw --force reset

# SSH (adjust if you changed port)
sudo ufw allow ssh

# HTTP/HTTPS (for Cloudflare)
sudo ufw allow 80
sudo ufw allow 443

# MQTT for local devices only (optional, if you have local devices)
# sudo ufw allow from 192.168.0.0/16 to any port 1883

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status numbered
```

---

## 📊 Step 10: Monitoring Setup

### Setup System Monitoring
```bash
# Create monitoring script
nano ~/system-monitor.sh
```

Add to `system-monitor.sh`:
```bash
#!/bin/bash
echo "=== System Status $(date) ==="
echo "Uptime: $(uptime)"
echo "Disk Usage:"
df -h /
echo "Memory Usage:"
free -h
echo "Docker Services:"
cd /opt/iot-platform && docker compose ps
echo "Cloudflare Tunnel:"
sudo systemctl status cloudflared --no-pager -l
```

```bash
# Make executable
chmod +x ~/system-monitor.sh

# Add to crontab for daily reports
(crontab -l 2>/dev/null; echo "0 8 * * * /home/$USER/system-monitor.sh") | crontab -
```

---

## 🎯 Step 11: Production Deployment

### Switch to Production Mode
```bash
cd /opt/iot-platform

# Deploy production stack
./deploy.sh prod
```

### Backup Strategy
```bash
# Create backup script
nano ~/backup-iot.sh
```

Add to `backup-iot.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/iot-platform"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
cd /opt/iot-platform
docker compose exec -T db pg_dump -U iotuser iot > $BACKUP_DIR/db_$DATE.sql

# Backup configuration
tar -czf $BACKUP_DIR/config_$DATE.tar.gz .env docker-compose.yml services/

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

```bash
# Make executable and schedule
chmod +x ~/backup-iot.sh
(crontab -l 2>/dev/null; echo "0 2 * * * /home/$USER/backup-iot.sh") | crontab -
```

---

## 🎉 Step 12: Final Verification

### Complete System Check
```bash
# Run your monitoring script
~/system-monitor.sh

# Check all services
cd /opt/iot-platform
docker compose ps

# Test all endpoints
echo "Testing API..."
curl -s https://demo.your-domain.com/health | jq

echo "Testing Grafana..."
curl -s https://demo.your-domain.com/grafana/api/health | jq

echo "Testing tunnel..."
sudo systemctl status cloudflared
```

---

## 📱 Next Steps: ESP32 Configuration

Update your ESP32 firmware with your server details:

```cpp
const char* WIFI_SSID = "your-wifi-name";
const char* WIFI_PASS = "your-wifi-password";
const char* MQTT_HOST = "your-domain.com";  // Your actual domain
const int   MQTT_PORT = 1883;
const char* MQTT_USER = "devuser";
const char* MQTT_PASS = "your-mqtt-password";  // From your .env file
const char* DEVICE_ID = "esp32-01";
```

---

## 🔧 Troubleshooting Commands

```bash
# Check service logs
docker compose logs [service-name]

# Restart services
docker compose restart

# Check tunnel status
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f

# Check firewall
sudo ufw status verbose

# Check system resources
htop
df -h
free -h

# Test MQTT
mosquitto_sub -h localhost -p 1883 -u devuser -P your-password -t devices/+/telemetry
```

---

## 🎊 Congratulations!

Your Ubuntu server is now ready with:
- ✅ Secure SSH and firewall configuration
- ✅ Docker and Docker Compose installed
- ✅ Cloudflare Zero Trust tunnel configured
- ✅ IoT Platform deployed and running
- ✅ Monitoring and backup systems in place
- ✅ Production-ready security hardening

Your IoT platform is now accessible at:
- **Public Demo**: `https://demo.your-domain.com/grafana/`
- **Control Panel**: `https://control.your-domain.com/control`
- **MQTT Test**: `https://mqtt.your-domain.com/mqtt-test`

Welcome to the world of secure IoT! 🌍

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

### Check Deployment Status

**Step 1: Verify All Services Are Running**
```bash
# Check all services are running
docker compose ps

# Expected output - all services should show "Up" status:
# NAME                        STATUS
# iot-platform-api-1          Up
# iot-platform-broker-1       Up  
# iot-platform-db-1           Up (healthy)
# iot-platform-grafana-1      Up
# iot-platform-nginx-1        Up
# iot-platform-prometheus-1   Up
```

**Step 2: Identify and Fix Missing Services**

If any service is missing from the list, diagnose:

```bash
# Check recent container activity
docker ps -a | grep iot-platform

# Look for services with "Exited" status and check their logs
docker logs iot-platform-[service-name]-1

# Common issues and quick fixes:
# - broker missing: See "MQTT Broker Container Keeps Crashing" in troubleshooting
# - nginx missing: Check if it started after broker was ready
# - api missing: Check database connection and environment variables
```

**Step 3: Validate Service Health**
```bash
# Check logs for errors (no errors should appear)
docker compose logs api --tail 10
docker compose logs broker --tail 10
docker compose logs nginx --tail 10

# If you see errors:
# - "host not found in upstream": Restart nginx after other services are up
# - "Connection refused": Check if dependent services are running
# - "Permission denied": Check file permissions (see troubleshooting)
```

**Step 4: Test Critical Functionality**
```bash
# Test API health endpoint
curl http://localhost:8080/health
# Expected: {"status":"healthy","service":"iot-platform-api"}

# Test MQTT broker (should connect without errors)
echo "Testing MQTT connection..."
timeout 5s mosquitto_pub -h localhost -p 1883 -t test -m "deployment-test" && echo "✅ MQTT working" || echo "❌ MQTT failed"

# Test web interface routing
curl -s http://localhost:8080/grafana/api/health | head -n 1
# Expected: { (JSON response indicating Grafana is accessible)
```

**Step 5: Verify Cloudflare Tunnel**
```bash
# Check cloudflared service status
sudo systemctl status cloudflared --no-pager
# Expected: Active: active (running)

# Check tunnel connections
sudo journalctl -u cloudflared --no-pager -n 5 | grep "Registered tunnel"
# Expected: Multiple "Registered tunnel connection" messages

# If cloudflared is not active, see "Cloudflared Service Fails to Start" in troubleshooting
```

**Deployment Validation Checklist:**

- [ ] All 6 Docker services running (`docker compose ps`)
- [ ] API health check returns 200 OK (`curl localhost:8080/health`)
- [ ] MQTT broker accepts connections (`mosquitto_pub` test)
- [ ] Cloudflared tunnel is active (`systemctl status cloudflared`)
- [ ] No error messages in service logs
- [ ] Domain resolves to Cloudflare IPs (`nslookup demo.your-domain.com`)

> **⚠️ Important**: If any checklist item fails, refer to the "Common Issues and Fixes" section below before proceeding.

### Quick Validation Script

Create and run this validation script to automatically check your deployment:

```bash
# Create validation script
cat > /opt/iot-platform/validate-deployment.sh << 'EOF'
#!/bin/bash

echo "🔍 IoT Platform Deployment Validation"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Run this script from /opt/iot-platform directory"
    exit 1
fi

ERRORS=0

echo "1. Checking Docker services..."
RUNNING_SERVICES=$(docker compose ps --services --filter status=running | wc -l)
EXPECTED_SERVICES=6

if [ "$RUNNING_SERVICES" -eq "$EXPECTED_SERVICES" ]; then
    echo "   ✅ All $EXPECTED_SERVICES services are running"
else
    echo "   ❌ Only $RUNNING_SERVICES/$EXPECTED_SERVICES services running"
    echo "   Missing services:"
    docker compose ps --services | while read service; do
        if ! docker compose ps --services --filter status=running | grep -q "^$service$"; then
            echo "      - $service"
        fi
    done
    ERRORS=$((ERRORS + 1))
fi

echo "2. Testing API health..."
if curl -s http://localhost:8080/health | grep -q "healthy"; then
    echo "   ✅ API health check passed"
else
    echo "   ❌ API health check failed"
    ERRORS=$((ERRORS + 1))
fi

echo "3. Testing MQTT broker..."
if timeout 5s mosquitto_pub -h localhost -p 1883 -t test -m "validation-test" 2>/dev/null; then
    echo "   ✅ MQTT broker is accessible"
else
    echo "   ❌ MQTT broker connection failed"
    ERRORS=$((ERRORS + 1))
fi

echo "4. Checking Cloudflare tunnel..."
if systemctl is-active --quiet cloudflared; then
    echo "   ✅ Cloudflared service is active"
else
    echo "   ❌ Cloudflared service is not running"
    ERRORS=$((ERRORS + 1))
fi

echo "5. Checking recent logs for errors..."
ERROR_COUNT=$(docker compose logs --since=10m 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "   ✅ No recent errors in logs"
else
    echo "   ⚠️ Found $ERROR_COUNT error messages in recent logs"
    echo "   Run 'docker compose logs' to investigate"
fi

echo "========================================"
if [ "$ERRORS" -eq 0 ]; then
    echo "🎉 Deployment validation PASSED! Your IoT platform is ready."
    echo ""
    echo "🌐 Access your platform at:"
    echo "   - Demo: https://demo.your-domain.com"
    echo "   - Control: https://control.your-domain.com"
    echo "   - Admin: https://admin.your-domain.com"
else
    echo "❌ Deployment validation FAILED with $ERRORS errors."
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Review the errors above"
    echo "   2. Check the troubleshooting section in UBUNTU_SERVER_SETUP.md"
    echo "   3. Run 'docker compose logs [service-name]' for detailed error info"
    echo "   4. Fix issues and run this script again"
fi

exit $ERRORS
EOF

# Make script executable
chmod +x /opt/iot-platform/validate-deployment.sh

# Run validation
/opt/iot-platform/validate-deployment.sh
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

## � Common Issues and Fixes (Step-by-Step Solutions)

### Issue 1: Cloudflared Service Fails to Start

**Symptoms:**
```bash
sudo systemctl status cloudflared
# Shows: Active: activating (auto-restart) (Result: exit-code)
```

**Diagnosis:**
```bash
sudo journalctl -xeu cloudflared.service --no-pager -n 10
# Error: Cannot determine default origin certificate path
```

**Solution:**
```bash
# 1. Check if certificate exists in user directory
ls -la ~/.cloudflared/
# Should show: cert.pem and [tunnel-id].json

# 2. Copy certificates to system location
sudo cp ~/.cloudflared/*.json /etc/cloudflared/iot-demo.json
sudo cp ~/.cloudflared/cert.pem /etc/cloudflared/
sudo chmod 600 /etc/cloudflared/iot-demo.json /etc/cloudflared/cert.pem

# 3. Update cloudflared config to include origin certificate
sudo tee /etc/cloudflared/config.yml << 'EOF'
tunnel: iot-demo
credentials-file: /etc/cloudflared/iot-demo.json
origincert: /etc/cloudflared/cert.pem

ingress:
  - hostname: demo.your-domain.com
    service: http://localhost:8080
  - hostname: control.your-domain.com
    service: http://localhost:8080
  - hostname: mqtt.your-domain.com
    service: http://localhost:8080
  - hostname: admin.your-domain.com
    service: http://localhost:8080
  - service: http_status:404

metrics: 0.0.0.0:2000
EOF

# 4. Restart cloudflared service
sudo systemctl restart cloudflared.service
sudo systemctl status cloudflared.service
```

### Issue 2: MQTT Broker Container Keeps Crashing

**Symptoms:**
```bash
docker compose ps
# broker service missing from list
docker ps -a | grep broker
# Shows: Exited (13) or similar error
```

**Diagnosis:**
```bash
docker compose logs broker
# May show: Error: Duplicate password_file value
# Or: Error: Unable to open file /mosquitto/config/passwd
```

**Solution A: Fix Configuration Conflicts**
```bash
# 1. Check current mosquitto config
cat services/broker/mosquitto.conf

# 2. If you see duplicate entries, edit the file:
nano services/broker/mosquitto.conf

# 3. Ensure config looks like this (no duplicates):
cat > services/broker/mosquitto.conf << 'EOF'
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

# Authentication settings (applies to all listeners)
allow_anonymous false
password_file /mosquitto/config/passwd

# TCP listener for LAN devices (ESP32, etc.)
listener 1883

# WebSocket listener for browsers via Cloudflare
listener 9001
protocol websockets
EOF
```

**Solution B: Fix File Permissions and Mounts**
```bash
# 1. Create data directories with proper permissions
sudo mkdir -p data/mosquitto data/postgres data/grafana
sudo chown -R $USER:$USER data/

# 2. Remove problematic mounted files if they exist
rm -f services/broker/passwd services/broker/aclfile

# 3. Simplify docker-compose.yml broker section:
# Edit docker-compose.yml and ensure broker section looks like:
```
```yaml
  broker:
    image: eclipse-mosquitto:2
    env_file: .env
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./services/broker/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - broker_data:/mosquitto/data
      - broker_log:/mosquitto/log
    restart: unless-stopped
```
```bash
# 4. For testing, temporarily allow anonymous access:
sed -i 's/allow_anonymous false/allow_anonymous true/' services/broker/mosquitto.conf

# 5. Restart broker
docker compose down broker
docker compose up broker -d

# 6. Test MQTT connection
mosquitto_pub -h localhost -p 1883 -t test -m "hello world"
```

### Issue 3: Docker Compose Version Warnings

**Symptoms:**
```bash
docker compose ps
# Shows: WARN[0000] /path/docker-compose.yml: the attribute `version` is obsolete
```

**Solution:**
```bash
# Remove the version line from docker compose files
sed -i '/^version:/d' docker-compose.yml
sed -i '/^version:/d' docker-compose.prod.yml
```

### Issue 4: Nginx Can't Find Upstream Services

**Symptoms:**
```bash
docker compose logs nginx
# Shows: nginx: [emerg] host not found in upstream "broker"
```

**Solution:**
```bash
# 1. Ensure all services start in correct order
docker compose down
docker compose up -d

# 2. If broker is failing, fix broker first (see Issue 2)
# 3. Then restart nginx after broker is running:
docker compose up nginx -d
```

### Issue 5: Git Permission Errors During Updates

**Symptoms:**
```bash
git pull origin dev
# Shows: error: cannot open '.git/FETCH_HEAD': Permission denied
```

**Solution:**
```bash
# Fix git repository ownership
sudo chown -R $USER:$USER /opt/iot-platform
cd /opt/iot-platform
git pull origin dev
```

### Issue 6: MQTT Password File Creation Fails

**Symptoms:**
```bash
docker compose logs broker
# Shows: Password: Error: Empty password.
```

**Solution:**
```bash
# 1. Install mosquitto-clients for password management
sudo apt update && sudo apt install -y mosquitto mosquitto-clients

# 2. Stop system mosquitto service (we use Docker version)
sudo systemctl stop mosquitto
sudo systemctl disable mosquitto

# 3. Create password file manually
cd /opt/iot-platform
mkdir -p data/mosquitto
mosquitto_passwd -c -b data/mosquitto/passwd devuser your-mqtt-password
chmod 600 data/mosquitto/passwd

# 4. Update docker-compose to mount the password file
# Add this line to broker volumes in docker-compose.yml:
# - ./data/mosquitto/passwd:/mosquitto/config/passwd

# 5. Restart broker
docker compose restart broker
```

### Issue 7: Services Not Accessible via Cloudflare

**Symptoms:**
- Local access works: `curl http://localhost:8080/health`
- Cloudflare access fails: `https://demo.your-domain.com/health`

**Diagnosis:**
```bash
# Check if cloudflared is running and connected
sudo systemctl status cloudflared
# Should show: Active: active (running)

# Check tunnel connections
sudo journalctl -u cloudflared -n 20
# Should show: INF Registered tunnel connection
```

**Solution:**
```bash
# 1. Verify tunnel configuration
sudo cat /etc/cloudflared/config.yml

# 2. Test local service is accessible
curl http://localhost:8080/health

# 3. Check DNS propagation
nslookup demo.your-domain.com
# Should show Cloudflare IPs (104.x.x.x or 172.x.x.x)

# 4. Check Cloudflare dashboard:
# - Go to Zero Trust > Access > Tunnels
# - Your tunnel should show "Healthy"
# - Check if DNS records are created

# 5. If tunnel shows unhealthy, restart it:
sudo systemctl restart cloudflared
```

### Issue 8: Container Build Failures

**Symptoms:**
```bash
docker compose up -d
# Shows: failed to solve: failed to build
```

**Solution:**
```bash
# 1. Clean Docker cache
docker system prune -a

# 2. Rebuild with no cache
docker compose build --no-cache

# 3. Check disk space
df -h
# Ensure at least 2GB free space

# 4. If still failing, build services individually:
docker compose build db
docker compose build api
docker compose up -d
```

---

## �🔧 Troubleshooting Commands

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

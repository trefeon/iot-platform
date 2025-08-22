# Ubuntu Server Deployment Instructions

## Current Status
✅ Repository successfully cloned to `/home/trefeon/iot-platform-trefeon`  
✅ Environment file created from template  
✅ Docker permission issue resolved  
✅ Grafana image issue fixed in docker-compose.yml  
❌ Services not yet started  

## Step 1: Update Repository (IMPORTANT)
First, pull the latest changes that fix the Grafana image issue:

```bash
cd ~/iot-platform-trefeon

# Pull latest changes
git pull origin main
```

## Step 2: Start the IoT Platform
After fixing Docker permissions:

```bash
cd ~/iot-platform-trefeon

# Stop any old running containers
docker compose down

# Start all services
docker compose up -d

# Check container status
docker compose ps

# View logs if needed
docker compose logs -f
```

## Step 3: Verify Services
Once running, check these endpoints:
- **Main Dashboard**: http://192.168.123.7:8080
- **API Health**: http://192.168.123.7:8080/api/health
- **Grafana**: http://192.168.123.7:3000 (admin/admin)

## Step 4: Test ESP32 Connection
Your ESP32 should connect to:
- **MQTT Broker**: 192.168.123.7:1883
- **Username**: devuser
- **Password**: devpass

## Step 5: Setup Auto-Startup (Optional)
To make the platform start automatically on server reboot:

```bash
cd ~/iot-platform-trefeon

# Copy the service file
sudo cp iot-platform.service /etc/systemd/system/

# Edit the service to use correct path
sudo nano /etc/systemd/system/iot-platform.service
# Change WorkingDirectory to: /home/trefeon/iot-platform-trefeon

# Enable and start the service
sudo systemctl enable iot-platform.service
sudo systemctl start iot-platform.service
sudo systemctl status iot-platform.service
```

## Troubleshooting

### If containers fail to start:
```bash
# Check detailed logs
docker compose logs

# Check individual service logs
docker compose logs api
docker compose logs broker
docker compose logs db
```

### If permission denied errors occur:
```bash
# Verify user is in docker group
groups $USER

# If not listed, run the usermod command again and restart SSH session
```

### If ports are already in use:
```bash
# Check what's using port 8080
sudo netstat -tulpn | grep :8080

# Stop conflicting services if needed
```

## Migration from /opt/iot-platform
The old deployment in `/opt/iot-platform` (owned by iotuser) should be stopped and migrated:

```bash
# If you can access the old deployment:
cd /opt/iot-platform
sudo docker compose down

# Remove old containers and volumes if no longer needed:
sudo docker system prune -a
sudo docker volume prune
```

## Next Steps
1. Fix Docker permissions (requires sudo access)
2. Start the cleaned-up platform
3. Verify ESP32 connectivity
4. Setup auto-startup if desired
5. Remove old deployment from /opt/iot-platform

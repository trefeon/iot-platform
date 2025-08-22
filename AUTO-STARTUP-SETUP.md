# IoT Platform Auto-Startup Setup

## Current Issue
There appears to be a Docker daemon issue preventing automatic container startup due to a "read-only file system" error when mounting volumes. This is likely a temporary Docker bug that can be resolved.

## Manual Startup After Reboot
When you reboot your server, you can manually start the IoT platform by running:

```bash
ssh iotuser@192.168.123.7
cd /opt/iot-platform
docker compose up -d
```

## Auto-Startup Solutions Implemented

### 1. Crontab Entry (Active)
A crontab entry has been added for the `iotuser` to automatically start the platform on boot:
```bash
@reboot /opt/iot-platform/startup-iot-platform.sh
```

### 2. Systemd Service (Created but disabled due to Docker issue)
A systemd service file has been created at `/etc/systemd/system/iot-platform.service` and enabled, but it's currently affected by the same Docker mounting issue.

## Startup Script
The startup script `/opt/iot-platform/startup-iot-platform.sh` includes:
- 30-second delay for system initialization
- Docker service restart to clear any issues
- Retry logic (3 attempts)
- Logging to `/var/log/iot-platform-startup.log`

## Troubleshooting Docker Issue

If the auto-startup fails, you can:

1. **Check startup logs:**
   ```bash
   sudo tail -f /var/log/iot-platform-startup.log
   ```

2. **Manual Docker restart and startup:**
   ```bash
   sudo systemctl restart docker
   sleep 10
   cd /opt/iot-platform
   docker compose up -d
   ```

3. **Check Docker daemon status:**
   ```bash
   sudo systemctl status docker
   ```

## Expected Behavior After Fix
Once the Docker mounting issue is resolved (likely after a Docker update or system reboot), the IoT platform should automatically start on boot and be accessible at:
- Dashboard: http://192.168.123.7:8080
- API: http://192.168.123.7:8080/api
- Grafana: http://192.168.123.7:3000

## Current Workaround
For now, after any server reboot, manually run:
```bash
ssh iotuser@192.168.123.7 "cd /opt/iot-platform && docker compose up -d"
```

This typically resolves the mounting issue and starts all containers successfully.

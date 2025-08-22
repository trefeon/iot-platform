#!/bin/bash

# IoT Platform Auto-Startup Script
# This script ensures the IoT platform starts automatically on boot

# Wait for Docker to be ready
sleep 30

# Change to project directory
cd /opt/iot-platform

# Ensure proper permissions
sudo chown -R iotuser:iotuser /opt/iot-platform/

# Restart Docker to clear any issues
sudo systemctl restart docker
sleep 10

# Start the IoT platform with retry logic
for i in {1..3}; do
    echo "$(date): Attempting IoT Platform startup (attempt $i)" >> /var/log/iot-platform-startup.log
    
    if docker compose up -d; then
        echo "$(date): IoT Platform auto-startup completed successfully" >> /var/log/iot-platform-startup.log
        exit 0
    else
        echo "$(date): IoT Platform startup attempt $i failed, retrying..." >> /var/log/iot-platform-startup.log
        sleep 10
    fi
done

echo "$(date): IoT Platform auto-startup failed after 3 attempts" >> /var/log/iot-platform-startup.log

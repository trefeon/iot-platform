#!/bin/bash

# IoT Platform Deployment Script for Linux Server
# Usage: ./deploy.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
REPO_URL="https://github.com/your-user/iot-platform.git"
PROJECT_DIR="/opt/iot-platform"
BRANCH="main"

echo "Deploying IoT Platform - Environment: $ENVIRONMENT, Branch: $BRANCH"

# Create project directory if it doesn't exist
sudo mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clone or update repository
if [ ! -d ".git" ]; then
    echo "Cloning repository..."
    sudo git clone $REPO_URL .
else
    echo "Updating repository..."
    sudo git fetch origin
fi

# Switch to correct branch and pull latest changes
sudo git checkout $BRANCH
sudo git pull origin $BRANCH

# Copy environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from example..."
    sudo cp .env.example .env
    echo "⚠️  Please edit .env file with your production settings!"
    echo "⚠️  Don't forget to change default passwords and secrets!"
fi

# Create MQTT password file if it doesn't exist
if [ ! -f "services/broker/passwd" ]; then
    echo "Creating MQTT password file..."
    echo "Creating MQTT password file (you will be prompted to set a password for 'devuser')..."
    sudo docker run --rm -v $(pwd)/services/broker:/mosquitto/config -it eclipse-mosquitto:2 mosquitto_passwd -c /mosquitto/config/passwd devuser
fi

# Set proper permissions
sudo chown -R $USER:$USER .
sudo chmod +x deploy.sh

# Deploy based on environment
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "Deploying to production..."
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
else
    echo "Deploying to development..."
    docker compose up -d
fi

echo "✅ Deployment complete!"
echo ""
echo "Services available at:"
echo "- API Documentation: http://localhost:8080/docs"
echo "- Grafana Dashboard: http://localhost:3000"
echo "- Prometheus: http://localhost:9090"
echo "- MQTT Broker: localhost:1883 (dev) or localhost:8883 (prod)"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your settings"
echo "2. Configure your ESP32 with the correct MQTT credentials"
echo "3. Set up SSL certificates for production (in deploy/certs/)"
echo "4. Configure your firewall to allow necessary ports"

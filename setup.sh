#!/bin/bash

# Simple IoT Platform - Quick Setup Script
# This script sets up the IoT platform on Ubuntu Server

echo "🌟 Simple IoT Platform - Portfolio Setup"
echo "========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Create project directory
echo "📁 Setting up project directory..."
PROJECT_DIR="$HOME/simple-iot-platform"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Download project files (you would replace this with your actual repository)
echo "📥 Setting up project files..."
echo "👉 Please copy your project files to: $PROJECT_DIR"

# Create data directory
mkdir -p data config

# Set up environment file
cat > .env << EOF
# Simple IoT Platform Configuration
MQTT_BROKER=mqtt
MQTT_PORT=1883

# Cloudflare Tunnel Token (get from Cloudflare dashboard)
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here

# Timezone
TZ=UTC
EOF

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy your project files to: $PROJECT_DIR"
echo "2. Update the .env file with your Cloudflare tunnel token"
echo "3. Run: docker-compose -f simple-docker-compose.yml up -d"
echo "4. Configure your ESP32 with your WiFi and server IP"
echo ""
echo "📱 Your dashboard will be available at: http://your-server-ip:8000"
echo "🌐 Public access via Cloudflare: https://your-tunnel-domain.com"
echo ""
echo "⚠️  Note: You may need to log out and back in for Docker permissions to take effect"

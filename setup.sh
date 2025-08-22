#!/bin/bash
# Simple IoT Platform - Ubuntu Setup
echo "🌟 Setting up Simple IoT Platform..."

# Install Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose  
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo "✅ Setup complete! Run: docker-compose up -d"

#!/bin/bash

# Cloudflare Tunnel Setup Script for IoT Platform
# Usage: ./setup-cloudflare.sh yourdomain.com

set -e

DOMAIN=${1:-"yourdomain.com"}
TUNNEL_NAME="iot-demo"
CONFIG_DIR="/etc/cloudflared"

if [ "$DOMAIN" = "yourdomain.com" ]; then
    echo "❌ Please provide your actual domain name:"
    echo "Usage: $0 your-actual-domain.com"
    exit 1
fi

echo "🚀 Setting up Cloudflare Tunnel for $DOMAIN"

# Install cloudflared if not present
if ! command -v cloudflared &> /dev/null; then
    echo "📦 Installing cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
fi

# Login to Cloudflare (interactive)
echo "🔑 Please login to Cloudflare (browser window will open)..."
cloudflared tunnel login

# Create tunnel if it doesn't exist
echo "🌐 Creating tunnel '$TUNNEL_NAME'..."
cloudflared tunnel create $TUNNEL_NAME || echo "Tunnel may already exist, continuing..."

# Create config directory
sudo mkdir -p $CONFIG_DIR

# Generate config file
echo "📝 Creating tunnel configuration..."
sudo tee $CONFIG_DIR/config.yml > /dev/null <<EOF
tunnel: $TUNNEL_NAME
credentials-file: $CONFIG_DIR/$TUNNEL_NAME.json

ingress:
  # Public demo dashboard
  - hostname: demo.$DOMAIN
    service: http://localhost:8080
  
  # Access-protected control panel
  - hostname: control.$DOMAIN
    service: http://localhost:8080
  
  # Access-protected MQTT WebSocket endpoint
  - hostname: mqtt.$DOMAIN
    service: http://localhost:8080
  
  # Admin interface (optional)
  - hostname: admin.$DOMAIN
    service: http://localhost:8080
  
  # Catch-all
  - service: http_status:404

# Metrics endpoint for monitoring
metrics: 0.0.0.0:2000
EOF

# Set up DNS records
echo "🔧 Setting up DNS records..."
cloudflared tunnel route dns $TUNNEL_NAME demo.$DOMAIN
cloudflared tunnel route dns $TUNNEL_NAME control.$DOMAIN
cloudflared tunnel route dns $TUNNEL_NAME mqtt.$DOMAIN
cloudflared tunnel route dns $TUNNEL_NAME admin.$DOMAIN

# Install as systemd service
echo "⚙️  Installing systemd service..."
sudo cloudflared --config $CONFIG_DIR/config.yml service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo "✅ Cloudflare Tunnel setup complete!"
echo ""
echo "🌍 Your subdomains:"
echo "   • https://demo.$DOMAIN - Public dashboard (Grafana)"
echo "   • https://control.$DOMAIN - Protected control panel"
echo "   • https://mqtt.$DOMAIN - Protected MQTT WebSocket"
echo "   • https://admin.$DOMAIN - Protected admin interface"
echo ""
echo "📋 Next steps:"
echo "1. Configure Cloudflare Zero Trust Access policies"
echo "2. Update your .env file with:"
echo "   DOMAIN=$DOMAIN"
echo "   CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs"
echo "   CF_ACCESS_AUD=your-app-audience-id"
echo "3. Deploy with: ./deploy.sh prod"
echo ""
echo "🔍 Check tunnel status: sudo systemctl status cloudflared"
echo "📊 Monitor tunnel: http://localhost:2000/metrics"

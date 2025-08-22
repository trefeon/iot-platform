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

# Copy tunnel credentials to expected location
echo "📋 Setting up tunnel credentials..."
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
sudo cp ~/.cloudflared/$TUNNEL_ID.json $CONFIG_DIR/$TUNNEL_NAME.json

# Install as systemd service
echo "⚙️  Installing systemd service..."
sudo cloudflared --config $CONFIG_DIR/config.yml service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# Set up Cloudflare Zero Trust Access Policies
echo "🔐 Setting up Cloudflare Zero Trust Access policies..."
echo ""
echo "⚠️  IMPORTANT: You need to manually configure these in Cloudflare Zero Trust dashboard:"
echo "   1. Go to https://one.dash.cloudflare.com/"
echo "   2. Navigate to Access > Applications"
echo ""

# Create Access Policy script for reference
cat > setup-access-policies.txt <<EOF
=== CLOUDFLARE ZERO TRUST ACCESS POLICY SETUP ===

1. Create Application for Control Panel:
   - Name: IoT Platform Control
   - Domain: control.$DOMAIN
   - Type: Self-hosted
   - Policy Name: Control Access
   - Rule: Include - Email - trefeon@gmail.com
   - Decision: Allow
   
2. Create Application for Admin Panel:
   - Name: IoT Platform Admin
   - Domain: admin.$DOMAIN
   - Type: Self-hosted
   - Policy Name: Admin Access
   - Rule: Include - Email - trefeon@gmail.com
   - Decision: Allow

3. Create Application for MQTT WebSocket:
   - Name: IoT Platform MQTT
   - Domain: mqtt.$DOMAIN
   - Type: Self-hosted
   - Policy Name: MQTT Access
   - Rule: Include - Email - trefeon@gmail.com
   - Decision: Allow

4. Get Application Audience ID:
   - Copy the Audience (AUD) tag from each application
   - Update your environment variables

5. Authentication Settings:
   - Session Duration: 24 hours (or as preferred)
   - Enable "Accept all available identity providers"
   - Add Google as identity provider if not already configured

=== AUTOMATIC CLI SETUP (Alternative) ===

If you have the Cloudflare API token with Zone:Edit permissions:

# Set your API credentials
export CF_API_TOKEN="your-api-token"
export CF_ZONE_ID="your-zone-id"
export CF_ACCOUNT_ID="your-account-id"

# Create applications via API (run these commands):

# 1. Control Panel Application
curl -X POST "https://api.cloudflare.com/client/v4/accounts/\$CF_ACCOUNT_ID/access/apps" \\
  -H "Authorization: Bearer \$CF_API_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "IoT Platform Control",
    "domain": "control.$DOMAIN",
    "type": "self_hosted",
    "session_duration": "24h",
    "allowed_idps": ["google"],
    "auto_redirect_to_identity": false,
    "policies": [{
      "name": "Control Access Policy",
      "decision": "allow",
      "include": [{
        "email": {
          "email": "trefeon@gmail.com"
        }
      }]
    }]
  }'

# 2. Admin Panel Application  
curl -X POST "https://api.cloudflare.com/client/v4/accounts/\$CF_ACCOUNT_ID/access/apps" \\
  -H "Authorization: Bearer \$CF_API_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "IoT Platform Admin",
    "domain": "admin.$DOMAIN",
    "type": "self_hosted", 
    "session_duration": "24h",
    "allowed_idps": ["google"],
    "auto_redirect_to_identity": false,
    "policies": [{
      "name": "Admin Access Policy",
      "decision": "allow",
      "include": [{
        "email": {
          "email": "trefeon@gmail.com"
        }
      }]
    }]
  }'

# 3. MQTT WebSocket Application
curl -X POST "https://api.cloudflare.com/client/v4/accounts/\$CF_ACCOUNT_ID/access/apps" \\
  -H "Authorization: Bearer \$CF_API_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "IoT Platform MQTT",
    "domain": "mqtt.$DOMAIN", 
    "type": "self_hosted",
    "session_duration": "24h",
    "allowed_idps": ["google"],
    "auto_redirect_to_identity": false,
    "policies": [{
      "name": "MQTT Access Policy", 
      "decision": "allow",
      "include": [{
        "email": {
          "email": "trefeon@gmail.com"
        }
      }]
    }]
  }'

EOF

echo "📋 Access policy setup instructions saved to: setup-access-policies.txt"

echo "✅ Cloudflare Tunnel setup complete!"
echo ""
echo "🌍 Your subdomains:"
echo "   • https://demo.$DOMAIN - Public dashboard (open access)"
echo "   • https://control.$DOMAIN - Protected control panel (trefeon@gmail.com only)"
echo "   • https://mqtt.$DOMAIN - Protected MQTT WebSocket (trefeon@gmail.com only)"
echo "   • https://admin.$DOMAIN - Protected admin interface (trefeon@gmail.com only)"
echo ""
echo "🔐 SECURITY SETUP REQUIRED:"
echo "1. Review setup-access-policies.txt for detailed instructions"
echo "2. Configure Cloudflare Zero Trust Access policies manually or via API"
echo "3. Restrict control/admin/mqtt domains to trefeon@gmail.com"
echo ""
echo "📋 Next steps:"
echo "1. Configure Cloudflare Zero Trust Access policies (see setup-access-policies.txt)"
echo "2. Get your Application Audience ID from Cloudflare dashboard"
echo "3. Update your .env file with:"
echo "   DOMAIN=$DOMAIN"
echo "   CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs"
echo "   CF_ACCESS_AUD=your-app-audience-id"
echo "4. Re-enable Cloudflare Access in your FastAPI app"
echo "5. Deploy with: docker compose up -d"
echo ""
echo "🔍 Check tunnel status: sudo systemctl status cloudflared"
echo "📊 Monitor tunnel: http://localhost:2000/metrics"
echo "📖 Access policy setup: cat setup-access-policies.txt"

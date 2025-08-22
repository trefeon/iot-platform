#!/bin/bash

# Deploy Cloudflare Settings to Server
# This script configures Cloudflare Access policies and tunnel settings on your production server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cloudflare Settings Deployment       ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root${NC}"
   exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists docker; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! command_exists curl; then
    echo -e "${RED}Error: curl is not installed${NC}"
    exit 1
fi

# Check if cloudflared is installed
if ! command_exists cloudflared; then
    echo -e "${YELLOW}Installing cloudflared...${NC}"
    
    # Download and install cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
    
    echo -e "${GREEN}cloudflared installed successfully${NC}"
fi

# Source environment variables
if [ -f ".env" ]; then
    echo -e "${YELLOW}Loading environment variables...${NC}"
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create .env file with required variables"
    exit 1
fi

# Source Cloudflare Access environment
if [ -f "cloudflare-access.env" ]; then
    echo -e "${YELLOW}Loading Cloudflare Access configuration...${NC}"
    export $(grep -v '^#' cloudflare-access.env | xargs)
else
    echo -e "${RED}Error: cloudflare-access.env file not found${NC}"
    echo "Please run setup-cloudflare.sh first"
    exit 1
fi

# Validate required variables
REQUIRED_VARS=(
    "DOMAIN"
    "CLOUDFLARE_API_TOKEN"
    "CLOUDFLARE_ZONE_ID"
    "CLOUDFLARE_ACCOUNT_ID"
    "CF_ACCESS_AUD"
)

echo -e "${YELLOW}Validating configuration...${NC}"
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}Error: $var is not set${NC}"
        exit 1
    fi
done

echo -e "${GREEN}Configuration validated${NC}"

# Create cloudflared config directory
CLOUDFLARED_CONFIG_DIR="$HOME/.cloudflared"
mkdir -p "$CLOUDFLARED_CONFIG_DIR"

# Function to create tunnel config
create_tunnel_config() {
    echo -e "${YELLOW}Creating tunnel configuration...${NC}"
    
    cat > "$CLOUDFLARED_CONFIG_DIR/config.yml" << EOF
tunnel: $CLOUDFLARE_TUNNEL_ID
credentials-file: $CLOUDFLARED_CONFIG_DIR/$CLOUDFLARE_TUNNEL_ID.json

ingress:
  - hostname: demo.$DOMAIN
    service: http://localhost:8080
    originRequest:
      httpHostHeader: demo.$DOMAIN
      
  - hostname: control.$DOMAIN
    service: http://localhost:8080
    originRequest:
      httpHostHeader: control.$DOMAIN
      
  - hostname: admin.$DOMAIN
    service: http://localhost:8080
    originRequest:
      httpHostHeader: admin.$DOMAIN
      
  - hostname: grafana.$DOMAIN
    service: http://localhost:3000
    originRequest:
      httpHostHeader: grafana.$DOMAIN
      
  - service: http_status:404
EOF

    echo -e "${GREEN}Tunnel configuration created${NC}"
}

# Function to install tunnel service
install_tunnel_service() {
    echo -e "${YELLOW}Installing cloudflared as system service...${NC}"
    
    sudo cloudflared service install --config="$CLOUDFLARED_CONFIG_DIR/config.yml"
    
    echo -e "${GREEN}Cloudflared service installed${NC}"
}

# Function to start tunnel service
start_tunnel_service() {
    echo -e "${YELLOW}Starting cloudflared service...${NC}"
    
    sudo systemctl enable cloudflared
    sudo systemctl start cloudflared
    
    echo -e "${GREEN}Cloudflared service started${NC}"
}

# Function to verify tunnel status
verify_tunnel() {
    echo -e "${YELLOW}Verifying tunnel status...${NC}"
    
    sleep 5  # Wait for service to start
    
    if sudo systemctl is-active --quiet cloudflared; then
        echo -e "${GREEN}✅ Cloudflared service is running${NC}"
    else
        echo -e "${RED}❌ Cloudflared service failed to start${NC}"
        sudo systemctl status cloudflared
        exit 1
    fi
    
    # Check tunnel connectivity
    echo -e "${YELLOW}Testing tunnel connectivity...${NC}"
    if curl -s -o /dev/null -w "%{http_code}" "https://demo.$DOMAIN" | grep -q "200\|403"; then
        echo -e "${GREEN}✅ Tunnel is accessible${NC}"
    else
        echo -e "${RED}❌ Tunnel connectivity test failed${NC}"
    fi
}

# Function to update nginx configuration for Cloudflare
update_nginx_config() {
    echo -e "${YELLOW}Updating Nginx configuration for Cloudflare...${NC}"
    
    # Backup original nginx config
    if [ -f "services/nginx/nginx.conf" ]; then
        cp services/nginx/nginx.conf services/nginx/nginx.conf.backup
    fi
    
    # Update nginx config to trust Cloudflare IPs
    cat > services/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Trust Cloudflare IPs
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    
    # IPv6 ranges
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2a06:98c0::/29;
    set_real_ip_from 2c0f:f248::/32;
    
    real_ip_header CF-Connecting-IP;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    server {
        listen 80;
        server_name _;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        
        location / {
            proxy_pass http://api:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header CF-Connecting-IP $http_cf_connecting_ip;
            
            # Cloudflare Access headers
            proxy_set_header CF-Access-Jwt-Assertion $http_cf_access_jwt_assertion;
            proxy_set_header CF-Access-Authenticated-User-Email $http_cf_access_authenticated_user_email;
        }
        
        location /grafana/ {
            proxy_pass http://grafana:3000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

    echo -e "${GREEN}Nginx configuration updated${NC}"
}

# Function to restart services
restart_services() {
    echo -e "${YELLOW}Restarting Docker services...${NC}"
    
    docker compose down
    docker compose up -d
    
    echo -e "${GREEN}Services restarted${NC}"
}

# Function to run health checks
run_health_checks() {
    echo -e "${YELLOW}Running health checks...${NC}"
    
    # Wait for services to start
    sleep 10
    
    # Check API health
    if curl -s -f "http://localhost:8080/health" > /dev/null; then
        echo -e "${GREEN}✅ API service is healthy${NC}"
    else
        echo -e "${RED}❌ API service health check failed${NC}"
    fi
    
    # Check Grafana
    if curl -s -f "http://localhost:3000/api/health" > /dev/null; then
        echo -e "${GREEN}✅ Grafana service is healthy${NC}"
    else
        echo -e "${RED}❌ Grafana service health check failed${NC}"
    fi
    
    # Check external access
    echo -e "${YELLOW}Testing external access...${NC}"
    
    for subdomain in demo control admin grafana; do
        echo -e "${YELLOW}Testing https://$subdomain.$DOMAIN${NC}"
        
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$subdomain.$DOMAIN" || echo "000")
        
        if [[ "$status_code" =~ ^(200|403|302)$ ]]; then
            echo -e "${GREEN}✅ $subdomain.$DOMAIN is accessible (HTTP $status_code)${NC}"
        else
            echo -e "${RED}❌ $subdomain.$DOMAIN is not accessible (HTTP $status_code)${NC}"
        fi
    done
}

# Main deployment process
main() {
    echo -e "${BLUE}Starting Cloudflare settings deployment...${NC}"
    
    # Check if tunnel credentials exist
    if [ ! -f "$CLOUDFLARED_CONFIG_DIR/$CLOUDFLARE_TUNNEL_ID.json" ]; then
        echo -e "${RED}Error: Tunnel credentials not found${NC}"
        echo "Please run setup-cloudflare.sh first to create the tunnel"
        exit 1
    fi
    
    echo -e "${YELLOW}Deploying Cloudflare configuration...${NC}"
    
    # Create tunnel configuration
    create_tunnel_config
    
    # Update nginx configuration
    update_nginx_config
    
    # Restart services
    restart_services
    
    # Install and start tunnel service
    install_tunnel_service
    start_tunnel_service
    
    # Verify deployment
    verify_tunnel
    run_health_checks
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Cloudflare Deployment Complete!     ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Your IoT platform is now accessible at:${NC}"
    echo -e "${GREEN}🌐 Demo:    https://demo.$DOMAIN${NC}"
    echo -e "${GREEN}🔧 Control: https://control.$DOMAIN${NC}"
    echo -e "${GREEN}⚙️  Admin:   https://admin.$DOMAIN${NC}"
    echo -e "${GREEN}📊 Grafana: https://grafana.$DOMAIN${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Configure Cloudflare Access policies (if not done)"
    echo -e "2. Test device connections via MQTT"
    echo -e "3. Monitor system health in Grafana"
    echo -e "4. Review security settings"
    echo ""
    echo -e "${BLUE}Service commands:${NC}"
    echo -e "• Check tunnel status: ${YELLOW}sudo systemctl status cloudflared${NC}"
    echo -e "• View tunnel logs:   ${YELLOW}sudo journalctl -u cloudflared -f${NC}"
    echo -e "• Restart tunnel:     ${YELLOW}sudo systemctl restart cloudflared${NC}"
    echo -e "• Stop tunnel:        ${YELLOW}sudo systemctl stop cloudflared${NC}"
}

# Handle script interruption
trap 'echo -e "\n${RED}Deployment interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"

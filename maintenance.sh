#!/bin/bash

# IoT Platform Server Maintenance Script
# Run this script weekly to keep your server healthy

set -e

echo "🔧 IoT Platform Server Maintenance - $(date)"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="/opt/iot-platform"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# System Updates
echo -e "\n🔄 Updating System Packages..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean
print_status "System packages updated"

# Docker Maintenance
echo -e "\n🐳 Docker Maintenance..."
docker system prune -f
docker image prune -f
print_status "Docker cleanup completed"

# Check Project Directory
if [ -d "$PROJECT_DIR" ]; then
    cd $PROJECT_DIR
    
    # Update Repository
    echo -e "\n📦 Updating IoT Platform..."
    git fetch origin
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)
    
    if [ $LOCAL != $REMOTE ]; then
        print_warning "Updates available for IoT Platform"
        echo "Run 'cd $PROJECT_DIR && git pull origin main && ./deploy.sh prod' to update"
    else
        print_status "IoT Platform is up to date"
    fi
    
    # Check Services
    echo -e "\n🔍 Checking Services Status..."
    if docker compose ps | grep -q "Up"; then
        print_status "Docker services are running"
    else
        print_error "Some Docker services may be down"
        docker compose ps
    fi
    
    # Check Cloudflare Tunnel
    if sudo systemctl is-active --quiet cloudflared; then
        print_status "Cloudflare tunnel is running"
    else
        print_warning "Cloudflare tunnel may be down"
        sudo systemctl status cloudflared --no-pager -l
    fi
    
    # Disk Space Check
    echo -e "\n💾 Disk Space Check..."
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 80 ]; then
        print_warning "Disk usage is high: ${DISK_USAGE}%"
    else
        print_status "Disk usage is OK: ${DISK_USAGE}%"
    fi
    
    # Memory Check
    echo -e "\n🧠 Memory Check..."
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ $MEMORY_USAGE -gt 80 ]; then
        print_warning "Memory usage is high: ${MEMORY_USAGE}%"
    else
        print_status "Memory usage is OK: ${MEMORY_USAGE}%"
    fi
    
    # Log Rotation
    echo -e "\n📝 Log Maintenance..."
    sudo journalctl --vacuum-time=7d
    docker compose logs --tail=0 > /dev/null 2>&1
    print_status "Log rotation completed"
    
    # Backup Database
    echo -e "\n💾 Creating Database Backup..."
    BACKUP_DIR="/home/$USER/backups"
    mkdir -p $BACKUP_DIR
    DATE=$(date +%Y%m%d_%H%M%S)
    
    if docker compose exec -T db pg_dump -U iotuser iot > $BACKUP_DIR/iot_backup_$DATE.sql; then
        print_status "Database backup created: iot_backup_$DATE.sql"
        
        # Keep only last 7 backups
        ls -t $BACKUP_DIR/iot_backup_*.sql | tail -n +8 | xargs -r rm
        print_status "Old backups cleaned up"
    else
        print_error "Database backup failed"
    fi
    
else
    print_error "IoT Platform directory not found: $PROJECT_DIR"
fi

# Security Updates Check
echo -e "\n🔒 Security Check..."
SECURITY_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)
if [ $SECURITY_UPDATES -gt 0 ]; then
    print_warning "$SECURITY_UPDATES security updates available"
    echo "Run 'sudo apt upgrade' to install them"
else
    print_status "No security updates needed"
fi

# SSL Certificate Check (if using Let's Encrypt)
if command -v certbot &> /dev/null; then
    echo -e "\n🔐 SSL Certificate Check..."
    if sudo certbot certificates 2>/dev/null | grep -q "VALID"; then
        print_status "SSL certificates are valid"
    else
        print_warning "Check SSL certificates manually"
    fi
fi

# Firewall Status
echo -e "\n🛡️  Firewall Status..."
if sudo ufw status | grep -q "Status: active"; then
    print_status "Firewall is active"
else
    print_warning "Firewall may not be active"
fi

# System Load Check
echo -e "\n⚡ System Load..."
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/^[ \t]*//')
print_status "Current load average: $LOAD"

# Final Summary
echo -e "\n📊 Maintenance Summary"
echo "======================"
echo "Date: $(date)"
echo "Uptime: $(uptime -p)"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
echo "Memory Usage: $(free -h | awk 'NR==2{printf "%.1f%", $3*100/$2}')"
echo "Docker Services: $(docker compose ps 2>/dev/null | grep -c "Up" || echo "N/A")"
echo "Cloudflare Tunnel: $(sudo systemctl is-active cloudflared 2>/dev/null || echo "unknown")"

echo -e "\n✅ Maintenance completed successfully!"
echo "💡 Run this script weekly for optimal performance"

# Optional: Send summary to log
echo "Maintenance completed on $(date)" >> /var/log/iot-platform-maintenance.log

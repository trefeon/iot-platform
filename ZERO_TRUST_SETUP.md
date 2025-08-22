# 🔒 Zero Trust IoT Platform Setup Guide

This guide shows how to deploy your IoT platform with **Cloudflare Zero Trust** protection, making it safe for public demonstration while keeping sensitive controls protected.

## 🏗 Architecture Overview

```
ESP32 Devices → MQTT (LAN) → FastAPI → Nginx → Cloudflare Tunnel → Internet
                                            ↓
                                        Grafana (Public Read-Only)
                                            ↓
                                    Control Panel (Access-Protected)
```

## 🌐 Subdomains Setup

- **`demo.yourdomain.com`** - Public Grafana dashboard (read-only)
- **`control.yourdomain.com`** - Protected control panel (CF Access)
- **`mqtt.yourdomain.com`** - Protected MQTT WebSocket (CF Access)
- **`admin.yourdomain.com`** - Protected admin interface (CF Access)

## 📋 Prerequisites

1. **Domain name** managed by Cloudflare
2. **Cloudflare account** with Zero Trust enabled
3. **Linux server** with Docker installed
4. **GitHub repository** with your IoT platform code

## 🚀 Quick Start

### 1. Server Setup

```bash
# Clone your repository
git clone https://github.com/trefeon/iot-platform.git
cd iot-platform

# Setup Cloudflare Tunnel
chmod +x setup-cloudflare.sh
./setup-cloudflare.sh your-domain.com
```

### 2. Configure Environment

```bash
# Copy and edit environment file
cp .env.example .env
nano .env
```

Update these values in `.env`:
```bash
DOMAIN=your-domain.com
CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs
CF_ACCESS_AUD=your-application-audience-id
```

### 3. Deploy

```bash
# Deploy production stack
./deploy.sh prod
```

## 🔐 Cloudflare Zero Trust Configuration

### 1. Access Applications

In Cloudflare Dashboard → **Zero Trust** → **Access** → **Applications**:

#### Control Panel Application
- **Application Name**: IoT Control Panel
- **Application Domain**: `control.your-domain.com`
- **Identity Providers**: Google, GitHub, or Email OTP
- **Policies**:
  - **Allow**: Emails you specify
  - **Require**: Additional factors (optional)

#### MQTT WebSocket Application  
- **Application Name**: IoT MQTT WebSocket
- **Application Domain**: `mqtt.your-domain.com`
- **Same policies as Control Panel**

#### Admin Interface Application
- **Application Name**: IoT Admin Interface  
- **Application Domain**: `admin.your-domain.com`
- **Stricter policies**: Device certificates, WARP client, etc.

### 2. Service Tokens (Optional)

For API access without browser:
- **Zero Trust** → **Access** → **Service Tokens**
- Create token for automation/monitoring
- Use in API calls: `CF-Access-Client-Id` and `CF-Access-Client-Secret` headers

## 🛡 Security Features Enabled

### ✅ Public Demo Protection
- **Anonymous Grafana**: Read-only access to dashboards
- **Rate limiting**: Via Cloudflare
- **Bot protection**: Cloudflare Bot Fight Mode
- **DDoS protection**: Automatic

### ✅ Control Access Protection  
- **Zero Trust Authentication**: Google/GitHub/Email OTP
- **JWT Verification**: Double-checked in FastAPI
- **Device Certificates**: Optional for admin access
- **Audit Logs**: All access attempts logged

### ✅ Network Security
- **No direct MQTT**: Only WebSocket via Cloudflare
- **No exposed database**: Internal Docker network only
- **TLS Termination**: At Cloudflare edge
- **Real IP Forwarding**: Via CF headers

## 🎯 Usage Examples

### Public Demo Access
```bash
# Anyone can view (no login required)
curl https://demo.your-domain.com/grafana/api/health
```

### Protected Control Access
```bash
# Requires Cloudflare Access login
curl https://control.your-domain.com/api/devices \
  -H "CF-Access-Jwt-Assertion: <jwt-token>"
```

### MQTT WebSocket (Browser)
```javascript
// Requires CF Access authentication in browser
const ws = new WebSocket('wss://mqtt.your-domain.com/mqtt');
ws.onopen = () => console.log('Connected to MQTT');
```

### Device Command (Protected)
```bash
# Send LED command to ESP32
curl -X POST https://control.your-domain.com/api/commands/esp32-01 \
  -H "Content-Type: application/json" \
  -H "CF-Access-Jwt-Assertion: <jwt-token>" \
  -d '{"action": "led", "value": 1}'
```

## 🔧 Customization Options

### Add More Devices
1. Update ESP32 firmware with unique `DEVICE_ID`
2. Add device via API: `POST /api/devices/register`
3. Device appears in control panel automatically

### Custom Dashboards
1. Login to Grafana admin: `https://demo.your-domain.com/grafana/`
2. Create dashboards using PostgreSQL data source
3. Set appropriate permissions (Viewer for public)

### Additional Subdomains
1. Add to `setup-cloudflare.sh`
2. Update Nginx routing in `deploy/nginx/nginx.conf`
3. Configure CF Access policies

### MQTT Topics & ACLs
Edit `services/broker/aclfile`:
```
user device_esp32_01
topic write devices/esp32-01/telemetry
topic read devices/esp32-01/cmd

user admin_user  
topic readwrite devices/+/telemetry
topic readwrite devices/+/cmd
```

## 📊 Monitoring & Maintenance

### Tunnel Status
```bash
sudo systemctl status cloudflared
curl http://localhost:2000/metrics  # Tunnel metrics
```

### Service Health
```bash
docker compose ps
docker compose logs api
docker compose logs broker
```

### Access Logs
- **Cloudflare Dashboard** → **Zero Trust** → **Logs**
- **API logs**: `docker compose logs api`
- **Nginx logs**: `docker compose logs nginx`

## 🐛 Troubleshooting

### Tunnel Issues
```bash
# Restart tunnel
sudo systemctl restart cloudflared

# Check tunnel logs  
sudo journalctl -u cloudflared -f

# Test local connectivity
curl http://localhost:8080/health
```

### Access Denied
1. Check CF Access policies
2. Verify audience ID in `.env`
3. Check JWT verification in API logs
4. Ensure user email is in allowed list

### MQTT WebSocket Issues
```bash
# Test WebSocket endpoint
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  http://localhost:8080/mqtt
```

### Grafana Subpath Issues
1. Check `GF_SERVER_SERVE_FROM_SUB_PATH=true`
2. Verify Nginx sub_filter rules
3. Test direct Grafana access: `http://localhost:3000`

## 🎉 Demo Scenarios

### 1. **Public Showcase**
- Share `https://demo.your-domain.com/grafana/` 
- Live telemetry updates from your ESP32
- No login required, completely safe

### 2. **Investor Demo**  
- Login to `https://control.your-domain.com/control`
- Show real-time device control
- Toggle LEDs, change sampling rates
- Display security: "Only authorized users can control"

### 3. **Technical Demo**
- Show MQTT WebSocket: `https://mqtt.your-domain.com/mqtt`
- Demonstrate Zero Trust policies
- Live device provisioning via API

## 🚀 Next Level Features

Want to add more advanced features? Here are some ideas:

### 📱 Mobile App Integration
- Use CF Access service tokens
- React Native or Flutter app
- Push notifications via WebSocket

### 🤖 AI/ML Integration  
- Device anomaly detection
- Predictive maintenance alerts
- Automated responses via MQTT

### 📈 Advanced Analytics
- TimescaleDB for time-series optimization
- Custom Grafana plugins
- Real-time alerting

### 🔄 OTA Updates
- Secure firmware updates for ESP32
- Version management via API
- Rollback capabilities

---

## 📞 Support

If you need help with any part of this setup:

1. **Check logs** first (tunnel, API, broker)
2. **Verify configuration** (CF Access, DNS, environment)
3. **Test components** individually (Nginx, API, Grafana)
4. **Review CF Access policies** and JWT verification

Your IoT platform is now production-ready with enterprise-grade security! 🎉

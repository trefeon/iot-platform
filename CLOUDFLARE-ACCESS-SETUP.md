# 🔐 Cloudflare Zero Trust Access Setup

This guide helps you set up secure access control for your IoT platform, restricting admin and control interfaces to only **trefeon@gmail.com**.

## 🎯 Access Control Overview

| Domain | Access Level | Authentication |
|--------|-------------|----------------|
| `demo.trefeon.site` | **Public** | None required |
| `control.trefeon.site` | **Restricted** | trefeon@gmail.com only |
| `admin.trefeon.site` | **Restricted** | trefeon@gmail.com only |
| `mqtt.trefeon.site` | **Restricted** | trefeon@gmail.com only |

## 🚀 Quick Setup (Automated)

### 1. Run the Main Setup Script
```bash
./setup-cloudflare.sh trefeon.site
```

### 2. Configure Access Policies (API Method)
```bash
# Set your Cloudflare credentials
export CF_API_TOKEN="your-api-token"
export CF_ACCOUNT_ID="your-account-id"

# Run the automated policy setup
./setup-access-policies.sh trefeon.site
```

### 3. Update Environment Variables
```bash
# Copy the example file
cp cloudflare-access.env.example .env

# Edit .env with your actual values:
# CF_ACCESS_AUD=your-app-audience-id
# CF_ACCESS_CERTS=https://your-team.cloudflareaccess.com/cdn-cgi/access/certs
```

### 4. Re-enable Protection
```bash
# Re-enable Cloudflare Access middleware
./enable-access-protection.sh

# Deploy the changes
docker compose build api && docker compose up -d api
```

## 🖱️ Manual Setup (Dashboard Method)

### 1. Run Tunnel Setup
```bash
./setup-cloudflare.sh trefeon.site
```

### 2. Configure Access Policies Manually
1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Access > Applications**
3. Create three applications:

#### Control Panel Application
- **Name**: IoT Platform Control
- **Domain**: `control.trefeon.site`
- **Type**: Self-hosted
- **Policy Name**: Control Access
- **Rule**: Include → Email → `trefeon@gmail.com`
- **Decision**: Allow

#### Admin Panel Application
- **Name**: IoT Platform Admin  
- **Domain**: `admin.trefeon.site`
- **Type**: Self-hosted
- **Policy Name**: Admin Access
- **Rule**: Include → Email → `trefeon@gmail.com`
- **Decision**: Allow

#### MQTT WebSocket Application
- **Name**: IoT Platform MQTT
- **Domain**: `mqtt.trefeon.site`
- **Type**: Self-hosted  
- **Policy Name**: MQTT Access
- **Rule**: Include → Email → `trefeon@gmail.com`
- **Decision**: Allow

### 3. Get Configuration Values
From each application, copy:
- **Application Audience (AUD)** - Use the same AUD for all apps
- **Team Domain** - Found in Settings → Authentication

### 4. Update Environment and Deploy
```bash
# Edit .env file with your values
nano .env

# Re-enable protection
./enable-access-protection.sh

# Deploy
docker compose build api && docker compose up -d api
```

## 🔧 Getting Cloudflare Credentials

### API Token
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Create Custom Token with permissions:
   - **Zone:Edit** (for DNS records)
   - **Account:Cloudflare Access:Edit** (for Access policies)
3. Include your domain in Zone Resources

### Account ID
1. Go to any domain overview in Cloudflare Dashboard
2. Find **Account ID** in the right sidebar
3. Copy the value

### Team Domain
1. Go to [Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Check the URL or go to Settings → Authentication
3. Format: `https://YOUR-TEAM.cloudflareaccess.com`

## 🧪 Testing Access Control

### Public Access (Should Work)
```bash
curl -I https://demo.trefeon.site
# Should return 200 OK
```

### Protected Access (Should Redirect to Login)
```bash
curl -I https://control.trefeon.site
# Should return 302 redirect to Cloudflare login
```

### Browser Testing
1. **Demo**: Visit `https://demo.trefeon.site` - should load immediately
2. **Control**: Visit `https://control.trefeon.site` - should prompt for Google login
3. **Admin**: Visit `https://admin.trefeon.site` - should prompt for Google login
4. Use `trefeon@gmail.com` - other emails will be denied

## 🔍 Troubleshooting

### Common Issues

**"Missing CF Access JWT" Error**
- Check that `CF_ACCESS_AUD` and `CF_ACCESS_CERTS` are set correctly
- Verify the Audience ID matches your Cloudflare application
- Ensure the team domain URL is correct

**Authentication Loop**
- Clear browser cookies for your domain
- Check that the email `trefeon@gmail.com` is exactly as configured
- Verify Google is configured as an identity provider

**DNS Not Resolving**
- Wait up to 5 minutes for DNS propagation
- Check tunnel status: `sudo systemctl status cloudflared`
- Verify tunnel metrics: `curl http://localhost:2000/metrics`

### Verification Commands
```bash
# Check tunnel status
sudo systemctl status cloudflared

# View tunnel logs  
sudo journalctl -u cloudflared -f

# Test DNS resolution
nslookup control.trefeon.site

# Check API logs
docker logs iot-platform-api-1
```

## 📝 Files Reference

- `setup-cloudflare.sh` - Main tunnel and DNS setup
- `setup-access-policies.sh` - Automated Access policy creation
- `enable-access-protection.sh` - Re-enable FastAPI middleware
- `cloudflare-access.env.example` - Environment configuration template
- `setup-access-policies.txt` - Manual setup instructions (auto-generated)

## 🔒 Security Notes

- Only `trefeon@gmail.com` can access protected domains
- Session duration is set to 24 hours
- Demo dashboard remains publicly accessible
- All authentication goes through Google OAuth
- JWT tokens are verified on every request to protected endpoints

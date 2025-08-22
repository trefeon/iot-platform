# 🔐 Securing Admin and Control Panels - Complete Guide

## Current Status
- ✅ **Platform**: Deployed and running at trefeon.site
- ✅ **Cloudflare Tunnel**: Active and working
- ⚠️ **Security**: Admin and control panels are currently open (need protection)

## What You Need to Secure

### 🎯 **Endpoints to Protect:**
- `https://control.trefeon.site` - Device control panel
- `https://admin.trefeon.site` - System administration panel
- `https://demo.trefeon.site` - Can remain public (showcase)

### 🔒 **Security Goal:**
Restrict access to control and admin panels to only your email address using Cloudflare Access.

---

## 🚀 **OPTION 1: Manual Setup (Recommended - 10 minutes)**

### Step 1: Access Cloudflare Zero Trust Dashboard
1. Go to: **https://one.dash.cloudflare.com/**
2. Sign in with your Cloudflare account
3. If first time, complete the Teams setup (free plan available)

### Step 2: Set Up Identity Provider
1. Navigate to **Settings** → **Authentication**
2. Click **Add new** identity provider
3. Choose **Google** (easiest) or **GitHub**
4. Follow the setup wizard
5. **Save** the configuration

### Step 3: Create Access Applications

#### For Control Panel:
1. Navigate to **Access** → **Applications**
2. Click **Add an application**
3. Select **Self-hosted**
4. Configure:
   - **Application name**: `IoT Control Panel`
   - **Subdomain**: `control`
   - **Domain**: `trefeon.site`
   - **Path**: (leave empty)
5. Click **Next**

#### Set Access Policy:
1. **Policy name**: `Admin Only`
2. **Action**: `Allow`
3. **Configure rules**:
   - **Selector**: `Emails`
   - **Value**: `your-email@gmail.com` (replace with your actual email)
4. Click **Next** → **Add application**

#### For Admin Panel:
Repeat the same process with:
- **Application name**: `IoT Admin Panel`
- **Subdomain**: `admin`
- **Domain**: `trefeon.site`
- Same access policy restricting to your email

### Step 4: Get Application Configuration
1. In **Access** → **Applications**
2. Click on your control panel application
3. Copy the **Application Audience (AUD) Tag**
4. Note your **Team Domain** (e.g., `yourname.cloudflareaccess.com`)

### Step 5: Update Server Configuration
SSH to your server and update the configuration:

```bash
ssh iotuser@192.168.123.7
cd /opt/iot-platform

# Edit the cloudflare-access.env file
nano cloudflare-access.env
```

Update these values:
```bash
CF_ACCESS_TEAM_DOMAIN=https://yourname.cloudflareaccess.com
CF_ACCESS_CERTS=https://yourname.cloudflareaccess.com/cdn-cgi/access/certs
CF_ACCESS_AUD=your-application-audience-id-from-step-4
```

### Step 6: Enable Protection in FastAPI
```bash
# Restart the API service to apply changes
docker compose restart api
```

---

## 🤖 **OPTION 2: Automated Setup (Advanced - Requires API)**

### Prerequisites:
You need to obtain from Cloudflare dashboard:

1. **API Token**: https://dash.cloudflare.com/profile/api-tokens
   - Create with permissions: Zone:Read, Access:Edit
2. **Account ID**: Found in Cloudflare dashboard sidebar
3. **Zone ID**: Found in trefeon.site domain overview

### Automated Commands:
```bash
ssh iotuser@192.168.123.7
cd /opt/iot-platform

# Configure with your credentials
export CLOUDFLARE_API_TOKEN="your_api_token"
export CLOUDFLARE_ACCOUNT_ID="your_account_id" 
export CLOUDFLARE_ZONE_ID="your_zone_id"

# Run the automated setup
./setup-access-policies.sh trefeon.site
./enable-access-protection.sh
```

---

## 🧪 **Testing Your Security**

After setup, test the protection:

### 1. Test Demo (Should work without login):
```bash
curl -I https://demo.trefeon.site
# Should return: HTTP/2 200
```

### 2. Test Control Panel (Should require login):
Visit: **https://control.trefeon.site**
- Should redirect to Cloudflare Access login
- Login with your configured identity provider
- Should then show the control panel

### 3. Test Admin Panel (Should require login):
Visit: **https://admin.trefeon.site**
- Should redirect to Cloudflare Access login
- Same authentication flow as control panel

---

## 🔧 **Current FastAPI Configuration**

Your FastAPI app already has Cloudflare Access middleware configured in `main.py`:

```python
@app.middleware("http")
async def cf_access_guard(request: Request, call_next):
    """Protect control.* and admin.* subdomains with Cloudflare Access"""
    host = request.headers.get("host", "")
    
    # Protect only control.* and admin.* (demo stays open)
    if host.startswith("control.") or host.startswith("admin."):
        token = request.headers.get("Cf-Access-Jwt-Assertion")
        if not token:
            raise HTTPException(status_code=401, detail="Missing CF Access JWT")
        verify_cf_access(token)
    
    response = await call_next(request)
    return response
```

Once you configure the Cloudflare Access settings, you need to uncomment and enable this protection.

---

## 🎯 **Recommended Next Steps**

1. **Start with Option 1 (Manual)** - It's easier to understand and configure
2. **Set up Google as identity provider** - Most straightforward
3. **Test with your email** - Ensure you can access both panels
4. **Enable FastAPI middleware** - Uncomment the JWT verification code
5. **Test end-to-end** - Verify complete protection

---

## 📞 **Need Help?**

If you encounter issues:
1. Check Cloudflare Zero Trust logs: https://one.dash.cloudflare.com/
2. Verify your email is in the access policy
3. Ensure identity provider is properly configured
4. Check FastAPI logs: `docker logs iot-platform-api-1`

Your platform will then be fully secured with enterprise-grade authentication! 🛡️

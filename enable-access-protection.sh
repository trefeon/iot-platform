#!/bin/bash

# Script to re-enable Cloudflare Access protection
# Usage: ./enable-access-protection.sh

echo "🔐 Re-enabling Cloudflare Access protection in FastAPI app..."

# Check if we're in the correct directory
if [ ! -f "services/api/app/main.py" ]; then
    echo "❌ Please run this script from the iot-platform root directory"
    exit 1
fi

# Backup current main.py
cp services/api/app/main.py services/api/app/main.py.backup
echo "📋 Backed up main.py to main.py.backup"

# Re-enable Cloudflare Access middleware
sed -i 's/# TODO: Configure Cloudflare Access properly/# Cloudflare Access protection enabled/' services/api/app/main.py
sed -i 's/# For now, disable protection until CF Access is configured with real values/# Protection enabled with proper CF Access configuration/' services/api/app/main.py
sed -i 's/# Temporarily disabled - need to configure CF_ACCESS_AUD and CF_ACCESS_CERTS/# Cloudflare Access JWT validation enabled/' services/api/app/main.py
sed -i 's/        pass/        token = request.headers.get("Cf-Access-Jwt-Assertion")/' services/api/app/main.py
sed -i '/token = request.headers.get("Cf-Access-Jwt-Assertion")/a\        if not token:\n            raise HTTPException(status_code=401, detail="Missing CF Access JWT")\n        verify_cf_access(token)' services/api/app/main.py

# Remove commented lines
sed -i '/^        # token = request.headers.get("Cf-Access-Jwt-Assertion")/d' services/api/app/main.py
sed -i '/^        # if not token:/d' services/api/app/main.py
sed -i '/^        #     raise HTTPException(status_code=401, detail="Missing CF Access JWT")/d' services/api/app/main.py
sed -i '/^        # verify_cf_access(token)/d' services/api/app/main.py

echo "✅ Cloudflare Access protection re-enabled!"
echo ""
echo "📋 What was changed:"
echo "   • Uncommented JWT token validation"
echo "   • Re-enabled verify_cf_access() calls"
echo "   • Protection now active for control.* and admin.* domains"
echo ""
echo "⚠️  IMPORTANT: Make sure you have set these environment variables:"
echo "   CF_ACCESS_AUD=your-application-audience-id"
echo "   CF_ACCESS_CERTS=https://YOUR-TEAM.cloudflareaccess.com/cdn-cgi/access/certs"
echo ""
echo "🚀 To apply changes:"
echo "   docker compose build api"
echo "   docker compose up -d api"
echo ""
echo "🔍 Test access:"
echo "   • https://demo.yourdomain.com (should work without login)"
echo "   • https://control.yourdomain.com (should require trefeon@gmail.com login)"
echo "   • https://admin.yourdomain.com (should require trefeon@gmail.com login)"

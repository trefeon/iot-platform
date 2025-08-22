#!/bin/bash

# Cloudflare Zero Trust Access Policy Setup Script
# Usage: ./setup-access-policies.sh yourdomain.com

set -e

DOMAIN=${1:-"yourdomain.com"}
ADMIN_EMAIL="trefeon@gmail.com"

if [ "$DOMAIN" = "yourdomain.com" ]; then
    echo "❌ Please provide your actual domain name:"
    echo "Usage: $0 your-actual-domain.com"
    exit 1
fi

echo "🔐 Setting up Cloudflare Zero Trust Access Policies for $DOMAIN"
echo "🔒 Restricting access to: $ADMIN_EMAIL"

# Check for required environment variables
if [ -z "$CF_API_TOKEN" ] || [ -z "$CF_ACCOUNT_ID" ]; then
    echo ""
    echo "❌ Missing required environment variables!"
    echo "Please set the following:"
    echo "  export CF_API_TOKEN='your-cloudflare-api-token'"
    echo "  export CF_ACCOUNT_ID='your-cloudflare-account-id'"
    echo ""
    echo "To get these values:"
    echo "1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Create token with 'Zone:Edit' and 'Account:Cloudflare Access:Edit' permissions"
    echo "3. Find your Account ID in the right sidebar of any domain overview"
    exit 1
fi

# Function to create Access application
create_access_app() {
    local app_name="$1"
    local domain="$2"
    local policy_name="$3"
    
    echo "📋 Creating Access application: $app_name"
    
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/access/apps" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$app_name\",
            \"domain\": \"$domain\",
            \"type\": \"self_hosted\",
            \"session_duration\": \"24h\",
            \"auto_redirect_to_identity\": false,
            \"policies\": [{
                \"name\": \"$policy_name\",
                \"decision\": \"allow\",
                \"include\": [{
                    \"email\": {
                        \"email\": \"$ADMIN_EMAIL\"
                    }
                }]
            }]
        }")
    
    # Check if request was successful
    if echo "$response" | grep -q '"success":true'; then
        app_aud=$(echo "$response" | grep -o '"aud":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Created $app_name (AUD: $app_aud)"
        echo "   Domain: $domain"
        echo "   Access: $ADMIN_EMAIL only"
    else
        echo "❌ Failed to create $app_name"
        echo "Response: $response"
    fi
    echo ""
}

# Create Access applications
echo "🚀 Creating Cloudflare Zero Trust Access applications..."
echo ""

create_access_app "IoT Platform Control" "control.$DOMAIN" "Control Access Policy"
create_access_app "IoT Platform Admin" "admin.$DOMAIN" "Admin Access Policy"  
create_access_app "IoT Platform MQTT" "mqtt.$DOMAIN" "MQTT Access Policy"

echo "✅ Cloudflare Zero Trust Access setup complete!"
echo ""
echo "🔐 Access Control Summary:"
echo "   • control.$DOMAIN - Restricted to $ADMIN_EMAIL"
echo "   • admin.$DOMAIN - Restricted to $ADMIN_EMAIL"
echo "   • mqtt.$DOMAIN - Restricted to $ADMIN_EMAIL"
echo "   • demo.$DOMAIN - Public access (no restrictions)"
echo ""
echo "📋 Next steps:"
echo "1. Note the AUD (Audience) IDs from above"
echo "2. Update your IoT platform environment variables:"
echo "   CF_ACCESS_AUD=your-main-app-audience-id"
echo "   CF_ACCESS_CERTS=https://YOUR-TEAM.cloudflareaccess.com/cdn-cgi/access/certs"
echo "3. Re-enable Cloudflare Access middleware in your FastAPI app"
echo "4. Test access by visiting the protected domains"
echo ""
echo "🔍 View applications: https://one.dash.cloudflare.com/"
echo "📖 Manage policies: Access > Applications"

#!/bin/bash

# GitHub Branch Protection Setup Script
# Run this on your local machine if you have GitHub CLI installed

echo "🔒 Setting up branch protection for main branch..."

# Set branch protection for main
gh api repos/trefeon/iot-platform/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false

echo "✅ Branch protection configured for main branch"

# Add repository topics for better discoverability
echo "🏷️ Adding repository topics..."
gh repo edit trefeon/iot-platform \
  --add-topic iot,fastapi,mqtt,postgresql,cloudflare,esp32,docker,grafana,timescaledb,python

# Update repository description
echo "📝 Updating repository description..."
gh repo edit trefeon/iot-platform \
  --description "Production-ready IoT platform with FastAPI, MQTT, PostgreSQL, and Cloudflare Zero Trust security. Real-time monitoring, device management, and responsive web interfaces."

echo "🎉 Repository configuration complete!"
echo ""
echo "Your repository is now:"
echo "✅ Public and discoverable"
echo "✅ Protected main branch (requires PR and reviews)"
echo "✅ Properly tagged and described"
echo ""
echo "Next: Deploy to your server using ./deploy-cloudflare.sh"

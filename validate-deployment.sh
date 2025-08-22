#!/bin/bash

echo "🔍 IoT Platform Deployment Validation"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Run this script from /opt/iot-platform directory"
    exit 1
fi

ERRORS=0

echo "1. Checking Docker services..."
RUNNING_SERVICES=$(docker compose ps --services --filter status=running | wc -l)
EXPECTED_SERVICES=6

if [ "$RUNNING_SERVICES" -eq "$EXPECTED_SERVICES" ]; then
    echo "   ✅ All $EXPECTED_SERVICES services are running"
else
    echo "   ❌ Only $RUNNING_SERVICES/$EXPECTED_SERVICES services running"
    echo "   Missing services:"
    docker compose ps --services | while read service; do
        if ! docker compose ps --services --filter status=running | grep -q "^$service$"; then
            echo "      - $service"
        fi
    done
    ERRORS=$((ERRORS + 1))
fi

echo "2. Testing API health..."
if curl -s http://localhost:8080/health | grep -q "healthy"; then
    echo "   ✅ API health check passed"
else
    echo "   ❌ API health check failed"
    ERRORS=$((ERRORS + 1))
fi

echo "3. Testing MQTT broker..."
if timeout 5s mosquitto_pub -h localhost -p 1883 -t test -m "validation-test" 2>/dev/null; then
    echo "   ✅ MQTT broker is accessible"
else
    echo "   ❌ MQTT broker connection failed"
    ERRORS=$((ERRORS + 1))
fi

echo "4. Checking Cloudflare tunnel..."
if systemctl is-active --quiet cloudflared; then
    echo "   ✅ Cloudflared service is active"
else
    echo "   ❌ Cloudflared service is not running"
    ERRORS=$((ERRORS + 1))
fi

echo "5. Checking recent logs for errors..."
ERROR_COUNT=$(docker compose logs --since=10m 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "   ✅ No recent errors in logs"
else
    echo "   ⚠️ Found $ERROR_COUNT error messages in recent logs"
    echo "   Run 'docker compose logs' to investigate"
fi

echo "6. Testing external connectivity..."
if command -v nslookup >/dev/null 2>&1; then
    DOMAIN=$(grep "^DOMAIN=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "your-domain.com" ]; then
        if nslookup "demo.$DOMAIN" >/dev/null 2>&1; then
            echo "   ✅ Domain demo.$DOMAIN resolves correctly"
        else
            echo "   ⚠️ Domain demo.$DOMAIN not resolving"
        fi
    else
        echo "   ⚠️ DOMAIN not configured in .env file"
    fi
else
    echo "   ⚠️ nslookup not available, skipping DNS check"
fi

echo "========================================"
if [ "$ERRORS" -eq 0 ]; then
    echo "🎉 Deployment validation PASSED! Your IoT platform is ready."
    echo ""
    echo "🌐 Access your platform at:"
    DOMAIN=$(grep "^DOMAIN=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "your-domain.com" ]; then
        echo "   - Demo: https://demo.$DOMAIN"
        echo "   - Control: https://control.$DOMAIN"
        echo "   - Admin: https://admin.$DOMAIN"
    else
        echo "   - Local: http://localhost:8080"
        echo "   - Update .env DOMAIN setting for external access"
    fi
else
    echo "❌ Deployment validation FAILED with $ERRORS errors."
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Review the errors above"
    echo "   2. Check the troubleshooting section in UBUNTU_SERVER_SETUP.md"
    echo "   3. Run 'docker compose logs [service-name]' for detailed error info"
    echo "   4. Fix issues and run this script again"
fi

exit $ERRORS

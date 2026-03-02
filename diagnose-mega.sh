#!/bin/bash

# CaixaPreta Stack - MEGA (Chatwoot) Diagnostic Script
# This script helps diagnose MEGA/Chatwoot access issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== CaixaPreta Stack - MEGA (Chatwoot) Diagnostics ===${NC}"
echo

# Get domain
read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Domain is required!${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking MEGA (Chatwoot) for: mega.$DOMAIN${NC}"
echo

# 1. Check if MEGA service is running
echo -e "${YELLOW}1. Checking MEGA service status...${NC}"
if docker service ps apps_mega-rails 2>/dev/null; then
    echo -e "${GREEN}✅ MEGA Rails service exists${NC}"
    
    # Check if it's actually running
    RUNNING=$(docker service ps apps_mega-rails --format "{{.CurrentState}}" | grep "Running" | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
        echo -e "${GREEN}✅ MEGA Rails service is running${NC}"
    else
        echo -e "${RED}❌ MEGA Rails service is not running${NC}"
        echo "Service details:"
        docker service ps apps_mega-rails
    fi
else
    echo -e "${RED}❌ MEGA Rails service not found${NC}"
fi
echo

# 2. Check Sidekiq worker
echo -e "${YELLOW}2. Checking MEGA Sidekiq worker...${NC}"
if docker service ps apps_mega-sidekiq 2>/dev/null; then
    echo -e "${GREEN}✅ MEGA Sidekiq service exists${NC}"
    
    RUNNING=$(docker service ps apps_mega-sidekiq --format "{{.CurrentState}}" | grep "Running" | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
        echo -e "${GREEN}✅ MEGA Sidekiq service is running${NC}"
    else
        echo -e "${RED}❌ MEGA Sidekiq service is not running${NC}"
    fi
else
    echo -e "${RED}❌ MEGA Sidekiq service not found${NC}"
fi
echo

# 3. Check database connectivity
echo -e "${YELLOW}3. Testing database connectivity...${NC}"
DB_TEST=$(docker run --rm --network db_internal-net postgres:15-alpine \
    psql postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
    -c "SELECT 1;" 2>/dev/null || echo "failed")

if [ "$DB_TEST" != "failed" ]; then
    echo -e "${GREEN}✅ Database connection successful${NC}"
else
    echo -e "${RED}❌ Database connection failed${NC}"
fi
echo

# 4. Check Redis connectivity
echo -e "${YELLOW}4. Testing Redis connectivity...${NC}"
REDIS_TEST=$(docker run --rm --network db_internal-net redis:7-alpine \
    redis-cli -h redis-mega ping 2>/dev/null || echo "failed")

if [ "$REDIS_TEST" = "PONG" ]; then
    echo -e "${GREEN}✅ Redis connection successful${NC}"
else
    echo -e "${RED}❌ Redis connection failed${NC}"
fi
echo

# 5. Check MEGA logs
echo -e "${YELLOW}5. Recent MEGA Rails logs (last 20 lines)...${NC}"
docker service logs --tail 20 apps_mega-rails 2>/dev/null || echo "Cannot get MEGA Rails logs"
echo

echo -e "${YELLOW}6. Recent MEGA Sidekiq logs (last 10 lines)...${NC}"
docker service logs --tail 10 apps_mega-sidekiq 2>/dev/null || echo "Cannot get MEGA Sidekiq logs"
echo

# 7. Test HTTP access
echo -e "${YELLOW}7. Testing HTTP/HTTPS access to MEGA...${NC}"
echo "Testing HTTP redirect..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 10 http://mega.$DOMAIN 2>/dev/null || echo "000")
echo "HTTP response code: $HTTP_CODE"

echo "Testing HTTPS access..."
HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 10 -k https://mega.$DOMAIN 2>/dev/null || echo "000")
echo "HTTPS response code: $HTTPS_CODE"

if [ "$HTTPS_CODE" = "200" ]; then
    echo -e "${GREEN}✅ MEGA is accessible via HTTPS${NC}"
elif [ "$HTTPS_CODE" = "404" ]; then
    echo -e "${RED}❌ MEGA returns 404 - service may not be properly initialized${NC}"
elif [ "$HTTPS_CODE" = "502" ] || [ "$HTTPS_CODE" = "503" ]; then
    echo -e "${RED}❌ MEGA service is down or not responding${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected response code: $HTTPS_CODE${NC}"
fi
echo

# 8. Check data directory
echo -e "${YELLOW}8. Checking MEGA data directory...${NC}"
if [ -d "/data/mega" ]; then
    echo -e "${GREEN}✅ /data/mega directory exists${NC}"
    echo "Directory contents:"
    ls -la /data/mega/ 2>/dev/null || echo "Cannot list directory contents"
else
    echo -e "${RED}❌ /data/mega directory not found${NC}"
fi
echo

echo -e "${YELLOW}=== MEGA Troubleshooting Recommendations ===${NC}"

if [ "$HTTPS_CODE" = "404" ]; then
    echo -e "${YELLOW}For 404 errors:${NC}"
    echo "1. Initialize the Chatwoot database:"
    echo "   docker run --rm --network db_internal-net \\"
    echo "     -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \\"
    echo "     -e RAILS_ENV=production \\"
    echo "     sendingtk/chatwoot:v4.11.2 \\"
    echo "     bundle exec rails db:chatwoot_prepare"
    echo
    echo "2. Restart the MEGA service:"
    echo "   docker service update --force apps_mega-rails"
    echo
elif [ "$HTTPS_CODE" = "502" ] || [ "$HTTPS_CODE" = "503" ]; then
    echo -e "${YELLOW}For 502/503 errors:${NC}"
    echo "1. Check if the service is running:"
    echo "   docker service ps apps_mega-rails"
    echo
    echo "2. Check service logs:"
    echo "   docker service logs apps_mega-rails"
    echo
    echo "3. Restart the service:"
    echo "   docker service update --force apps_mega-rails"
fi

echo -e "${YELLOW}General troubleshooting:${NC}"
echo "- Wait 2-3 minutes after deployment for services to fully start"
echo "- Ensure DNS is properly configured for mega.$DOMAIN"
echo "- Check that database and Redis services are running"
echo "- Verify SSL certificates are generated (check Traefik logs)"

echo -e "\n${GREEN}Diagnostic complete!${NC}"
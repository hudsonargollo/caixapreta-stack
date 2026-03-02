#!/bin/bash

# CaixaPreta Stack - MEGA (Chatwoot) Fix Script
# Use this to fix MEGA/Chatwoot 404 issues on existing installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== CaixaPreta Stack - MEGA (Chatwoot) Fix ===${NC}"
echo

# Get domain
read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Domain is required!${NC}"
    exit 1
fi

echo -e "${YELLOW}Fixing MEGA (Chatwoot) for: mega.$DOMAIN${NC}"
echo

# 1. Check if database and Redis are running
echo -e "${YELLOW}1. Checking dependencies...${NC}"
DB_RUNNING=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_postgres" | grep -v "0/" | wc -l)
REDIS_RUNNING=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_redis-mega" | grep -v "0/" | wc -l)

if [ "$DB_RUNNING" -eq 0 ]; then
    echo -e "${RED}❌ PostgreSQL is not running. Please fix database first.${NC}"
    exit 1
fi

if [ "$REDIS_RUNNING" -eq 0 ]; then
    echo -e "${RED}❌ Redis is not running. Please fix Redis first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database and Redis are running${NC}"

# 2. Wait for services to be ready
echo -e "${YELLOW}2. Waiting for services to be ready...${NC}"
sleep 10

# 3. Initialize Chatwoot database
echo -e "${YELLOW}3. Initializing Chatwoot database...${NC}"
docker run --rm --network db_internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=caixapretastack2626 \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database initialization completed${NC}"
else
    echo -e "${YELLOW}⚠️  Database initialization failed or already done${NC}"
fi

# 4. Create admin user (optional)
echo -e "${YELLOW}4. Creating admin user...${NC}"
read -p "Do you want to create an admin user? (y/n): " CREATE_ADMIN

if [ "$CREATE_ADMIN" = "y" ] || [ "$CREATE_ADMIN" = "Y" ]; then
    read -p "Enter admin email: " ADMIN_EMAIL
    read -p "Enter admin name: " ADMIN_NAME
    
    if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_NAME" ]; then
        docker run --rm --network db_internal-net \
          -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
          -e RAILS_ENV=production \
          -e SECRET_KEY_BASE=caixapretastack2626 \
          sendingtk/chatwoot:v4.11.2 \
          bundle exec rails runner "
            user = User.find_or_create_by(email: '$ADMIN_EMAIL') do |u|
              u.name = '$ADMIN_NAME'
              u.password = 'password123'
              u.password_confirmation = 'password123'
              u.confirmed_at = Time.current
            end
            
            account = Account.find_or_create_by(name: 'CaixaPreta')
            AccountUser.find_or_create_by(user: user, account: account) do |au|
              au.role = 'administrator'
            end
            
            puts \"Admin user created: #{user.email}\"
            puts \"Default password: password123\"
            puts \"Please change the password after first login\"
          "
        
        echo -e "${GREEN}✅ Admin user created${NC}"
        echo -e "${YELLOW}Email: $ADMIN_EMAIL${NC}"
        echo -e "${YELLOW}Password: password123${NC}"
        echo -e "${RED}⚠️  Please change the password after first login!${NC}"
    fi
fi

# 5. Restart MEGA services
echo -e "${YELLOW}5. Restarting MEGA services...${NC}"
docker service update --force apps_mega-rails
docker service update --force apps_mega-sidekiq

echo -e "${YELLOW}Waiting for services to restart...${NC}"
sleep 15

# 6. Check service status
echo -e "${YELLOW}6. Checking service status...${NC}"
docker service ps apps_mega-rails
echo
docker service ps apps_mega-sidekiq

# 7. Test access
echo -e "${YELLOW}7. Testing MEGA access...${NC}"
sleep 10

HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 15 -k https://mega.$DOMAIN 2>/dev/null || echo "000")
echo "HTTPS response code: $HTTPS_CODE"

if [ "$HTTPS_CODE" = "200" ]; then
    echo -e "${GREEN}✅ MEGA is now accessible at: https://mega.$DOMAIN${NC}"
elif [ "$HTTPS_CODE" = "404" ]; then
    echo -e "${RED}❌ Still getting 404. Check logs with: docker service logs apps_mega-rails${NC}"
elif [ "$HTTPS_CODE" = "502" ] || [ "$HTTPS_CODE" = "503" ]; then
    echo -e "${YELLOW}⚠️  Service is starting. Wait 2-3 minutes and try again.${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected response: $HTTPS_CODE. Check service logs.${NC}"
fi

echo -e "\n${YELLOW}=== Next Steps ===${NC}"
echo "1. Access MEGA at: https://mega.$DOMAIN"
echo "2. If still having issues, run: ./diagnose-mega.sh"
echo "3. Check logs with: docker service logs apps_mega-rails"
echo "4. Monitor services with: docker service ls"

echo -e "\n${GREEN}MEGA fix completed!${NC}"
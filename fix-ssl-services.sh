#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔧 SSL & SERVICES FIX UTILITY${NC}"
echo "=============================="
echo

# Get domain from user
echo -e "${YELLOW}Enter your domain (e.g., yourdomain.com):${NC}"
read -p "Domain: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ Domain is required${NC}"
    exit 1
fi

echo
echo -e "${BLUE}🔧 Fixing SSL and services for: $DOMAIN${NC}"
echo "============================================="

# 1. Check and fix Docker Swarm
echo -e "\n${YELLOW}1. Checking Docker Swarm...${NC}"
if ! docker info | grep -q "Swarm: active"; then
    echo -e "${RED}❌ Docker Swarm is not active${NC}"
    echo -e "${YELLOW}Reinitializing Docker Swarm...${NC}"
    
    PUBLIC_IP=$(curl -s ifconfig.me)
    docker swarm leave --force 2>/dev/null || true
    docker swarm init --advertise-addr $PUBLIC_IP
    
    if docker info | grep -q "Swarm: active"; then
        echo -e "${GREEN}✅ Docker Swarm reinitialized${NC}"
    else
        echo -e "${RED}❌ Failed to initialize Docker Swarm${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Docker Swarm is active${NC}"
fi

# 2. Recreate networks
echo -e "\n${YELLOW}2. Recreating Docker networks...${NC}"
docker network rm traefik-public 2>/dev/null || true
docker network rm db_internal-net 2>/dev/null || true

docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable db_internal-net

echo -e "${GREEN}✅ Networks recreated${NC}"

# 3. Update Traefik configuration with correct domain
echo -e "\n${YELLOW}3. Updating Traefik configuration...${NC}"
mkdir -p /data/traefik

cat > /data/traefik/traefik.yml << EOF
api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    swarmMode: true
    exposedByDefault: false
    network: traefik-public

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@${DOMAIN}
      storage: /certificates/acme.json
      httpChallenge:
        entryPoint: web

log:
  level: INFO

accessLog: {}
EOF

# Set correct permissions
chmod 600 /data/traefik/traefik.yml
touch /data/traefik/acme.json
chmod 600 /data/traefik/acme.json

echo -e "${GREEN}✅ Traefik configuration updated${NC}"

# 4. Redeploy core services (Traefik + Portainer)
echo -e "\n${YELLOW}4. Redeploying core services...${NC}"

cat > /tmp/core-stack.yml << EOF
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - --configFile=/etc/traefik/traefik.yml
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /data/traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - /data/traefik:/certificates
    networks:
      - traefik-public
    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.traefik.rule=Host(\`traefik.${DOMAIN}\`)
        - traefik.http.routers.traefik.tls.certresolver=letsencrypt
        - traefik.http.routers.traefik.service=api@internal
        - traefik.http.services.traefik.loadbalancer.server.port=8080

  portainer:
    image: portainer/portainer-ce:latest
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /data/portainer:/data
    networks:
      - traefik-public
    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.portainer.rule=Host(\`portainer.${DOMAIN}\`)
        - traefik.http.routers.portainer.tls.certresolver=letsencrypt
        - traefik.http.services.portainer.loadbalancer.server.port=9000

networks:
  traefik-public:
    external: true

EOF

docker stack deploy -c /tmp/core-stack.yml core
rm /tmp/core-stack.yml

echo -e "${GREEN}✅ Core services redeployed${NC}"

# 5. Wait for Traefik to be ready
echo -e "\n${YELLOW}5. Waiting for Traefik to initialize...${NC}"
sleep 30

# 6. Redeploy application services
echo -e "\n${YELLOW}6. Redeploying application services...${NC}"

# MEGA (Chatwoot)
echo -e "   Deploying MEGA (Chatwoot)..."
cat > /tmp/apps-stack.yml << EOF
version: '3.8'

services:
  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - NODE_ENV=production
      - RAILS_ENV=production
      - INSTALLATION_ENV=docker
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - REDIS_URL=redis://redis-mega:6379
      - SECRET_KEY_BASE=caixapretastack2626secretkey
      - FRONTEND_URL=https://mega.${DOMAIN}
    networks:
      - traefik-public
      - db_internal-net
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.mega.rule=Host(\`mega.${DOMAIN}\`)
        - traefik.http.routers.mega.tls.certresolver=letsencrypt
        - traefik.http.services.mega.loadbalancer.server.port=3000

  mega-sidekiq:
    image: sendingtk/chatwoot:v4.11.2
    command: bundle exec sidekiq -C config/sidekiq.yml
    environment:
      - NODE_ENV=production
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - REDIS_URL=redis://redis-mega:6379
      - SECRET_KEY_BASE=caixapretastack2626secretkey
    networks:
      - db_internal-net

  evolution:
    image: atendai/evolution-api:latest
    environment:
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - DATABASE_CONNECTION_DB=evolution_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://redis-n8n:6379
      - AUTHENTICATION_API_KEY=caixapretastack2626
    networks:
      - traefik-public
      - db_internal-net
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.evolution.rule=Host(\`evolution.${DOMAIN}\`)
        - traefik.http.routers.evolution.tls.certresolver=letsencrypt
        - traefik.http.services.evolution.loadbalancer.server.port=8080

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
    volumes:
      - /data/minio:/data
    networks:
      - traefik-public
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.minio.rule=Host(\`minio.${DOMAIN}\`)
        - traefik.http.routers.minio.tls.certresolver=letsencrypt
        - traefik.http.services.minio.loadbalancer.server.port=9001

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://grafana.${DOMAIN}
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.grafana.rule=Host(\`grafana.${DOMAIN}\`)
        - traefik.http.routers.grafana.tls.certresolver=letsencrypt
        - traefik.http.services.grafana.loadbalancer.server.port=3000

networks:
  traefik-public:
    external: true
  db_internal-net:
    external: true
EOF

docker stack deploy -c /tmp/apps-stack.yml apps
rm /tmp/apps-stack.yml

echo -e "${GREEN}✅ Application services redeployed${NC}"

# 7. Initialize MEGA database
echo -e "\n${YELLOW}7. Initializing MEGA database...${NC}"
sleep 20

docker run --rm --network db_internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
  -e RAILS_ENV=production \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare

echo -e "${GREEN}✅ MEGA database initialized${NC}"

# 8. Final status check
echo -e "\n${YELLOW}8. Final status check...${NC}"
sleep 10

echo -e "\n${BLUE}Service Status:${NC}"
docker service ls

echo -e "\n${BLUE}SSL Certificate Status:${NC}"
if [ -f "/data/traefik/acme.json" ]; then
    CERT_SIZE=$(stat -c%s "/data/traefik/acme.json")
    echo "Certificate file size: $CERT_SIZE bytes"
    if [ "$CERT_SIZE" -gt 100 ]; then
        echo -e "${GREEN}✅ SSL certificates are being generated${NC}"
    else
        echo -e "${YELLOW}⚠️  SSL certificates are still being generated (wait 5-10 minutes)${NC}"
    fi
else
    echo -e "${RED}❌ SSL certificate file not found${NC}"
fi

echo
echo -e "${CYAN}🎉 FIX COMPLETE!${NC}"
echo "================"
echo
echo -e "${GREEN}Your services should now be accessible at:${NC}"
echo "• MEGA (Chatwoot): https://mega.$DOMAIN"
echo "• Evolution API: https://evolution.$DOMAIN"
echo "• MinIO: https://minio.$DOMAIN"
echo "• Grafana: https://grafana.$DOMAIN"
echo "• Portainer: https://portainer.$DOMAIN"
echo
echo -e "${YELLOW}⏰ Note: SSL certificates may take 5-15 minutes to generate${NC}"
echo -e "${BLUE}💡 If issues persist, run: ./diagnose-ssl-dns.sh${NC}"
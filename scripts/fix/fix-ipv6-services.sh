#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔧 IPv6 SERVER FIX UTILITY${NC}"
echo "=========================="
echo

DOMAIN="clubemkt.digital"
SERVER_IP="2a02:c207:2309:5501::1"

echo -e "${BLUE}🔧 Fixing services for IPv6 server: $SERVER_IP${NC}"
echo "=================================================="

# 1. Fix directory permissions
echo -e "\n${YELLOW}1. Fixing directory permissions...${NC}"
mkdir -p /data/{traefik,portainer,grafana,minio,postgres,redis-mega,redis-n8n,n8n}
chown -R 472:472 /data/grafana  # Grafana user ID
chown -R 999:999 /data/minio    # MinIO user ID
chown -R 1000:1000 /data/n8n    # n8n user ID
chmod -R 755 /data
echo -e "${GREEN}✅ Permissions fixed${NC}"

# 2. Remove problematic stacks
echo -e "\n${YELLOW}2. Removing problematic stacks...${NC}"
docker stack rm apps 2>/dev/null || true
docker stack rm automation 2>/dev/null || true
sleep 10

# 3. Clean up networks
echo -e "\n${YELLOW}3. Recreating networks...${NC}"
docker network rm traefik-public 2>/dev/null || true
docker network rm db_internal-net 2>/dev/null || true
sleep 5

docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable db_internal-net
echo -e "${GREEN}✅ Networks recreated${NC}"

# 4. Update Traefik configuration for IPv6
echo -e "\n${YELLOW}4. Updating Traefik configuration for IPv6...${NC}"
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

chmod 600 /data/traefik/traefik.yml
rm -f /data/traefik/acme.json
touch /data/traefik/acme.json
chmod 600 /data/traefik/acme.json
echo -e "${GREEN}✅ Traefik configuration updated${NC}"

# 5. Redeploy core services
echo -e "\n${YELLOW}5. Redeploying core services...${NC}"
docker service update --force core_traefik
docker service update --force core_portainer
sleep 15

# 6. Deploy automation stack (n8n)
echo -e "\n${YELLOW}6. Deploying automation services...${NC}"
cat > /tmp/automation-stack.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_HOST=n8n.${DOMAIN}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.${DOMAIN}
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - QUEUE_BULL_REDIS_HOST=redis-n8n
      - EXECUTIONS_MODE=queue
      - QUEUE_HEALTH_CHECK_ACTIVE=true
    volumes:
      - /data/n8n:/home/node/.n8n
    networks:
      - traefik-public
      - db_internal-net
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.n8n.rule=Host(\`n8n.${DOMAIN}\`)
        - traefik.http.routers.n8n.tls.certresolver=letsencrypt
        - traefik.http.services.n8n.loadbalancer.server.port=5678

networks:
  traefik-public:
    external: true
  db_internal-net:
    external: true
EOF

docker stack deploy -c /tmp/automation-stack.yml automation
rm /tmp/automation-stack.yml
echo -e "${GREEN}✅ Automation services deployed${NC}"

# 7. Deploy application services with fixed configuration
echo -e "\n${YELLOW}7. Deploying application services...${NC}"
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
      - FORCE_SSL=true
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
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@postgres:5432/evolution_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://redis-n8n:6379
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - SERVER_URL=https://evolution.${DOMAIN}
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
      - MINIO_SERVER_URL=https://minio.${DOMAIN}
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
    user: "472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://grafana.${DOMAIN}
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
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
echo -e "${GREEN}✅ Application services deployed${NC}"

# 8. Initialize databases
echo -e "\n${YELLOW}8. Initializing databases...${NC}"
sleep 30

# Create Evolution database
docker exec -i $(docker ps -q -f name=db_postgres) psql -U postgres -c "CREATE DATABASE evolution_db;" 2>/dev/null || true

# Initialize MEGA database
docker run --rm --network db_internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
  -e RAILS_ENV=production \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare 2>/dev/null || true

echo -e "${GREEN}✅ Databases initialized${NC}"

# 9. Final status check
echo -e "\n${YELLOW}9. Final status check...${NC}"
sleep 15

echo -e "\n${BLUE}Service Status:${NC}"
docker service ls

echo
echo -e "${CYAN}🎉 IPv6 FIX COMPLETE!${NC}"
echo "====================="
echo
echo -e "${RED}⚠️  IMPORTANT: You MUST configure DNS first!${NC}"
echo
echo -e "${YELLOW}Add these AAAA records (IPv6) in your DNS provider:${NC}"
echo "mega.clubemkt.digital     → 2a02:c207:2309:5501::1"
echo "evolution.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "minio.clubemkt.digital    → 2a02:c207:2309:5501::1"
echo "grafana.clubemkt.digital  → 2a02:c207:2309:5501::1"
echo "n8n.clubemkt.digital      → 2a02:c207:2309:5501::1"
echo "portainer.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "traefik.clubemkt.digital  → 2a02:c207:2309:5501::1"
echo
echo -e "${BLUE}💡 After DNS is configured (wait 5-15 minutes):${NC}"
echo "• Services will be accessible via HTTPS"
echo "• SSL certificates will generate automatically"
echo "• Run the diagnostic script again to verify"
echo
echo -e "${GREEN}Your services will be accessible at:${NC}"
echo "• MEGA: https://mega.clubemkt.digital"
echo "• Evolution: https://evolution.clubemkt.digital"
echo "• MinIO: https://minio.clubemkt.digital"
echo "• Grafana: https://grafana.clubemkt.digital"
echo "• n8n: https://n8n.clubemkt.digital"
echo "• Portainer: https://portainer.clubemkt.digital"
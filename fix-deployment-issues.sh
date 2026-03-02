#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - DEPLOYMENT ISSUES FIX
# Fix script for network and service deployment issues
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}${1}${NC}"
    echo "=================================="
}

print_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

print_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  ${1}${NC}"
}

print_header "CAIXA PRETA STACK - DEPLOYMENT ISSUES FIX"

# 1. Fix Docker network issues
print_info "Step 1: Fixing Docker network configuration..."

# Remove and recreate networks with proper settings
echo "Removing existing networks..."
docker network rm traefik-public internal-net 2>/dev/null || true

echo "Creating networks with correct configuration..."
docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable internal-net

print_success "Networks recreated with attachable flag"

# 2. Fix service deployment issues
print_info "Step 2: Redeploying failed services..."

# Remove failed stacks
echo "Removing failed application stack..."
docker stack rm apps 2>/dev/null || true

# Wait for cleanup
echo "Waiting for cleanup..."
sleep 10

# 3. Redeploy applications with fixed configuration
print_info "Step 3: Redeploying applications with fixed configuration..."

# Get domain from existing Traefik config
DOMAIN=$(grep -o 'Host(`[^`]*`' /data/traefik/traefik.yml | head -1 | sed 's/Host(`//;s/`//' | cut -d'.' -f2- 2>/dev/null || echo "clubemkt.digital")

cat <<EOF > /tmp/swarm-apps-fixed.yml
version: '3.8'
services:
  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evolution.$DOMAIN
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/evolution_db
      - DATABASE_CONNECTION_STRING=postgresql://postgres:caixapretastack2626@db_postgres:5432/evolution_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - WEBHOOK_GLOBAL_URL=https://evolution.$DOMAIN
      - CONFIG_SESSION_SECRET=caixapretastack2626
      - QRCODE_LIMIT=30
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
    volumes:
      - /data/evolution:/evolution/instances
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.evolution.rule=Host(\`evolution.$DOMAIN\`)"
        - "traefik.http.routers.evolution.entrypoints=websecure"
        - "traefik.http.routers.evolution.tls.certresolver=letsencrypt"
        - "traefik.http.services.evolution.loadbalancer.server.port=8080"

  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - FRONTEND_URL=https://mega.$DOMAIN
      - FORCE_SSL=true
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true
      - WOO_REDIS_URL=redis://db_redis-mega:6379/1
      - WOO_REDIS_HOST=db_redis-mega
      - WOO_REDIS_PORT=6379
      - WOO_REDIS_DB=1
      - INSTALLATION_ENV=docker
    volumes:
      - /data/mega/storage:/app/storage
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.mega.rule=Host(\`mega.$DOMAIN\`)"
        - "traefik.http.routers.mega.entrypoints=websecure"
        - "traefik.http.routers.mega.tls.certresolver=letsencrypt"
        - "traefik.http.services.mega.loadbalancer.server.port=3000"

  mega-sidekiq:
    image: sendingtk/chatwoot:v4.11.2
    command: bundle exec sidekiq -c 5 -q default -q mailers -q medium -q low -q realtime -q push_notifications -q webhooks -q presence -q analytics
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - WOO_REDIS_URL=redis://db_redis-mega:6379/1
      - WOO_REDIS_HOST=db_redis-mega
      - WOO_REDIS_PORT=6379
      - WOO_REDIS_DB=1
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001" --address ":9000"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
      - MINIO_SERVER_URL=https://s3.$DOMAIN
      - MINIO_BROWSER_REDIRECT_URL=https://minio.$DOMAIN
    volumes:
      - /data/minio:/data
    networks:
      - traefik-public
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        # S3 API endpoint
        - "traefik.http.routers.minio-api.rule=Host(\`s3.$DOMAIN\`)"
        - "traefik.http.routers.minio-api.entrypoints=websecure"
        - "traefik.http.routers.minio-api.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-api.service=minio-api"
        - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
        # Console endpoint
        - "traefik.http.routers.minio-console.rule=Host(\`minio.$DOMAIN\`)"
        - "traefik.http.routers.minio-console.entrypoints=websecure"
        - "traefik.http.routers.minio-console.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-console.service=minio-console"
        - "traefik.http.services.minio-console.loadbalancer.server.port=9001"

  grafana:
    image: grafana/grafana:latest
    user: "472:472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://grafana.$DOMAIN
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
      - GF_PATHS_DATA=/var/lib/grafana
      - GF_PATHS_LOGS=/var/log/grafana
      - GF_PATHS_PLUGINS=/var/lib/grafana/plugins
      - GF_PATHS_PROVISIONING=/etc/grafana/provisioning
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana.rule=Host(\`grafana.$DOMAIN\`)"
        - "traefik.http.routers.grafana.entrypoints=websecure"
        - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
        - "traefik.http.services.grafana.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

# Deploy the fixed applications
echo "Deploying applications with fixed configuration..."
docker stack deploy -c /tmp/swarm-apps-fixed.yml apps

print_success "Applications redeployed with fixed configuration"

# 4. Fix n8n workers
print_info "Step 4: Fixing n8n worker deployment..."

# Remove and redeploy automation stack
docker stack rm automation 2>/dev/null || true
sleep 5

cat <<EOF > /tmp/swarm-automation-fixed.yml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_HOST=n8n.$DOMAIN
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://n8n.$DOMAIN/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - N8N_ENCRYPTION_KEY=caixapretastack2626
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=db_redis-n8n
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.n8n.rule=Host(\`n8n.$DOMAIN\`)"
        - "traefik.http.routers.n8n.entrypoints=websecure"
        - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
        - "traefik.http.services.n8n.loadbalancer.server.port=5678"

  n8n-worker:
    image: n8nio/n8n:latest
    command: worker
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - QUEUE_BULL_REDIS_HOST=db_redis-n8n
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      replicas: 2

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

docker stack deploy -c /tmp/swarm-automation-fixed.yml automation

print_success "n8n automation stack redeployed"

# 5. Wait and check services
print_info "Step 5: Waiting for services to start..."
sleep 30

echo "Current service status:"
docker service ls

# 6. Check for remaining issues
print_info "Step 6: Checking for remaining issues..."

FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)

if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_warning "Some services are still starting up:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/" || true
    echo
    print_info "Check individual service logs with:"
    echo "docker service logs SERVICE_NAME"
else
    print_success "All services are now running!"
fi

# 7. DNS Configuration reminder
print_info "Step 7: DNS Configuration Required"
echo
print_warning "IMPORTANT: You need to configure DNS records for your subdomains!"
echo
echo "Add these AAAA records to your DNS provider:"
echo "portainer.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "traefik.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "n8n.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "evolution.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "minio.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "s3.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "mega.clubemkt.digital → 2a02:c207:2309:5501::1"
echo "grafana.clubemkt.digital → 2a02:c207:2309:5501::1"
echo
print_info "After adding DNS records, SSL certificates will be generated automatically (5-15 minutes)"

# 8. Cleanup
rm -f /tmp/swarm-apps-fixed.yml /tmp/swarm-automation-fixed.yml

print_success "Deployment issues fix completed!"
echo
print_info "Monitor SSL certificate generation with:"
echo "docker service logs core_traefik"
#!/bin/bash

# Redeploy all services with updated Cloudflare SSL configuration
# This removes all tls.certresolver=letsencrypt labels from services

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${YELLOW}[STEP]${NC} $1"
}

# Get domain
read -p "Enter your domain (e.g., clubemkt.digital): " DOMAIN

if [ -z "$DOMAIN" ]; then
    log_error "Domain is required"
    exit 1
fi

log_step "Removing all services except Traefik and Portainer..."

# Remove all stacks
docker stack ls --format "{{.Name}}" | while read stack; do
    if [ "$stack" != "core" ]; then
        log_info "Removing stack: $stack"
        docker stack rm "$stack" 2>/dev/null || true
    fi
done

# Wait for cleanup
log_info "Waiting for services to be removed..."
sleep 30

log_step "Redeploying database services..."

# Create database stack
cat > /tmp/db-stack.yml << 'EOFDB'
version: '3.8'

services:
  db_postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=caixapretastack2626
      - POSTGRES_INITDB_ARGS=-c max_connections=500 -c shared_buffers=256MB
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  db_redis-n8n:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - /data/redis-n8n:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  db_redis-mega:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - /data/redis-mega:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

networks:
  internal-net:
    external: true
EOFDB

docker stack deploy -c /tmp/db-stack.yml core_db
log_success "Database services deployed"

log_info "Waiting for databases to be ready..."
sleep 30

log_step "Redeploying automation services (n8n, Evolution API)..."

# Create automation stack with updated labels (no tls.certresolver)
cat > /tmp/apps-stack.yml << 'EOFAPPS'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336
      - N8N_HOST=auto.DOMAIN_PLACEHOLDER
      - N8N_PROTOCOL=https
      - N8N_PORT=5678
      - N8N_SECURE_COOKIE=true
      - WEBHOOK_TUNNEL_URL=https://auto.DOMAIN_PLACEHOLDER/
      - REDIS_HOST=db_redis-n8n
      - REDIS_PORT=6379
      - REDIS_DB=0
    volumes:
      - /data/n8n:/home/node/.n8n
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(\`auto.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
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
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336
      - REDIS_HOST=db_redis-n8n
      - REDIS_PORT=6379
      - REDIS_DB=0
    networks:
      - internal-net
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evo.DOMAIN_PLACEHOLDER
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - DATABASE_CONNECTION_LIMIT=10
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379/1
      - REDIS_PREFIX_KEY=evolution
      - LOG_LEVEL=info
      - CORS_ORIGIN=*
      - CORS_CREDENTIALS=true
    volumes:
      - /data/evolution:/home/evolution/instances
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.evolution.rule=Host(\`evo.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.evolution.entrypoints=websecure"
      - "traefik.http.services.evolution.loadbalancer.server.port=8080"

  evolution2:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evo2.DOMAIN_PLACEHOLDER
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - DATABASE_CONNECTION_LIMIT=10
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379/2
      - REDIS_PREFIX_KEY=evolution2
      - LOG_LEVEL=info
      - CORS_ORIGIN=*
      - CORS_CREDENTIALS=true
    volumes:
      - /data/evolution2:/home/evolution/instances
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.evolution2.rule=Host(\`evo2.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.evolution2.entrypoints=websecure"
      - "traefik.http.services.evolution2.loadbalancer.server.port=8080"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOFAPPS

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /tmp/apps-stack.yml

docker stack deploy -c /tmp/apps-stack.yml automation
log_success "Automation services deployed"

log_info "Waiting for automation services to start..."
sleep 30

log_step "Redeploying MEGA and additional services..."

# Create MEGA stack with updated labels
cat > /tmp/mega-stack.yml << 'EOFMEGA'
version: '3.8'

services:
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
      - MINIO_BROWSER=on
    volumes:
      - /data/minio:/data
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    labels:
      - "traefik.enable=true"
      # API endpoint
      - "traefik.http.routers.minio-api.rule=Host(\`s3.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.minio-api.entrypoints=websecure"
      - "traefik.http.routers.minio-api.service=minio-api"
      - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
      # Console endpoint
      - "traefik.http.routers.minio-console.rule=Host(\`min.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.minio-console.entrypoints=websecure"
      - "traefik.http.routers.minio-console.service=minio-console"
      - "traefik.http.services.minio-console.loadbalancer.server.port=9001"

  grafana:
    image: grafana/grafana:latest
    user: "472:472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://graf.DOMAIN_PLACEHOLDER
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
      - GF_SECURITY_ALLOW_EMBEDDING=true
      - GF_AUTH_ANONYMOUS_ENABLED=false
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(\`graf.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.grafana.entrypoints=websecure"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"

  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - INSTALLATION_ENV=docker
      - FRONTEND_URL=https://chat.DOMAIN_PLACEHOLDER
      - MAILER_SENDER_EMAIL=noreply@DOMAIN_PLACEHOLDER
    volumes:
      - /data/mega:/app/storage
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mega.rule=Host(\`chat.DOMAIN_PLACEHOLDER\`)"
      - "traefik.http.routers.mega.entrypoints=websecure"
      - "traefik.http.services.mega.loadbalancer.server.port=3000"

  mega-sidekiq:
    image: sendingtk/chatwoot:v4.11.2
    command: bundle exec sidekiq -c 5 -q default -q mailers -q medium -q low -q realtime -q push_notifications -q webhooks -q presence -q analytics
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - INSTALLATION_ENV=docker
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep sidekiq | grep -v grep || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOFMEGA

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /tmp/mega-stack.yml

docker stack deploy -c /tmp/mega-stack.yml apps
log_success "MEGA and additional services deployed"

log_info "Waiting for services to stabilize..."
sleep 30

log_step "Verifying all services..."

# Check service status
docker service ls

log_success "All services redeployed with Cloudflare SSL configuration"
log_info "Services should now be accessible via HTTPS"
log_info "Test with: curl -k https://trae.$DOMAIN"

# Cleanup
rm -f /tmp/db-stack.yml /tmp/apps-stack.yml /tmp/mega-stack.yml

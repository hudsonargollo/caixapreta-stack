#!/bin/bash

# ==============================================================================
# INFRA CAIXA PRETA v3 - PRODUCTION INSTALLER
# Simplified, robust deployment with nginx reverse proxy
# Uses Cloudflare SSL termination (no Let's Encrypt complexity)
# Author: Hudson Argollo
# System: Debian/Ubuntu
# ==============================================================================

set -e

# UTF-8 locale
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

BOLD='\033[1m'

# Logging
INSTALL_LOG="/tmp/caixapreta-install.log"

log_info() {
    echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$INSTALL_LOG"
}

log_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} ${GREEN}$1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$INSTALL_LOG"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$INSTALL_LOG"
}

log_step() {
    echo -e "${PURPLE}${BOLD}>>> ${NC}${PURPLE}$1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [STEP] $1" >> "$INSTALL_LOG"
}

# Error handling
handle_error() {
    local line=$1
    log_error "Script failed at line $line"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Check root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

log_step "CAIXA PRETA PRODUCTION INSTALLER v3"

# Get configuration
read -p "Enter your domain (e.g., clubemkt.digital): " DOMAIN
read -p "Enter your email (for reference): " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    log_error "Domain and email are required"
    exit 1
fi

log_success "Configuration: Domain=$DOMAIN, Email=$EMAIL"

# System checks
log_step "System Requirements Check"

if ! grep -E "(Ubuntu|Debian)" /etc/os-release >/dev/null 2>&1; then
    log_error "This script requires Ubuntu or Debian"
    exit 1
fi

MEMORY_GB=$(free -g | awk 'NR==2{print $2}')
if [ "$MEMORY_GB" -lt 4 ]; then
    log_error "Minimum 4GB RAM required (detected: ${MEMORY_GB}GB)"
    exit 1
fi

DISK_GB=$(df / | awk 'NR==2 {print $4}' | awk '{print int($1/1024/1024)}')
if [ "$DISK_GB" -lt 40 ]; then
    log_error "Minimum 40GB disk required (detected: ${DISK_GB}GB)"
    exit 1
fi

log_success "System requirements met"

# Install Docker
log_step "Installing Docker"

if command -v docker >/dev/null 2>&1; then
    log_info "Docker already installed"
else
    log_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    bash /tmp/get-docker.sh >/dev/null 2>&1
    rm /tmp/get-docker.sh
    systemctl start docker
    systemctl enable docker
    log_success "Docker installed"
fi

# Wait for Docker daemon
log_info "Waiting for Docker daemon..."
for i in {1..30}; do
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon ready"
        break
    fi
    sleep 2
done

# Initialize Swarm
log_step "Initializing Docker Swarm"

if docker info | grep -q "Swarm: active"; then
    log_info "Docker Swarm already active"
else
    log_info "Initializing Swarm..."
    docker swarm init >/dev/null 2>&1
    log_success "Docker Swarm initialized"
fi

# Create networks
log_step "Creating Docker Networks"

for network in traefik-public internal-net; do
    if docker network ls --format "{{.Name}}" | grep -q "^$network$"; then
        log_info "Network $network already exists"
    else
        docker network create --driver overlay --attachable "$network" >/dev/null 2>&1
        log_success "Network $network created"
    fi
done

# Setup data directories
log_step "Setting Up Data Directories"

DIRS=(
    "/data/postgres"
    "/data/redis-n8n"
    "/data/redis-mega"
    "/data/n8n"
    "/data/evolution"
    "/data/evolution2"
    "/data/minio"
    "/data/grafana"
    "/data/mega"
    "/data/nginx/certs"
)

for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
    chmod 755 "$dir"
done

log_success "Data directories created"

# Generate self-signed certificate
log_step "Generating Self-Signed Certificate"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /data/nginx/certs/key.pem \
    -out /data/nginx/certs/cert.pem \
    -subj "/CN=$DOMAIN" >/dev/null 2>&1

log_success "Certificate generated"

# Create nginx config
log_step "Creating Nginx Configuration"

cat > /tmp/nginx.conf << 'EOFNGINX'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 2048;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    # Upstream services
    upstream n8n {
        server automation_n8n:5678;
    }

    upstream evolution {
        server automation_evolution:8080;
    }

    upstream evolution2 {
        server automation_evolution2:8080;
    }

    upstream minio {
        server apps_minio:9000;
    }

    upstream minio_console {
        server apps_minio:9001;
    }

    upstream grafana {
        server apps_grafana:3000;
    }

    upstream mega {
        server apps_mega-rails:3000;
    }

    upstream portainer {
        server core_portainer:9000;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        listen [::]:80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # n8n
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name auto.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://n8n;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # Evolution API 1
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name evo.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://evolution;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Evolution API 2
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name evo2.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://evolution2;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # MinIO API
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name s3.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://minio;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # MinIO Console
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name min.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://minio_console;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Grafana
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name graf.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://grafana;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Chatwoot/MEGA
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name chat.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://mega;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Portainer
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name port.DOMAIN_PLACEHOLDER;

        ssl_certificate /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://portainer;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOFNGINX

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /tmp/nginx.conf

log_success "Nginx configuration created"

# Deploy databases
log_step "Deploying Database Services"

cat > /tmp/db-stack.yml << 'EOFDB'
version: '3.8'
services:
  db_postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: caixapretastack2626
    command:
      - "postgres"
      - "-c"
      - "max_connections=500"
      - "-c"
      - "shared_buffers=256MB"
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - internal-net
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

sleep 30

# Deploy automation services
log_step "Deploying Automation Services (n8n, Evolution)"

cat > /tmp/apps-stack.yml << 'EOFAPPS'
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_DATABASE: main_db
      DB_POSTGRESDB_HOST: db_postgres
      DB_POSTGRESDB_USER: postgres
      DB_POSTGRESDB_PASSWORD: caixapretastack2626
      N8N_HOST: auto.DOMAIN_PLACEHOLDER
      N8N_PROTOCOL: https
      N8N_PORT: 5678
      WEBHOOK_TUNNEL_URL: https://auto.DOMAIN_PLACEHOLDER/
      REDIS_HOST: db_redis-n8n
      REDIS_PORT: 6379
      REDIS_DB: 0
    volumes:
      - /data/n8n:/home/node/.n8n
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  n8n-worker:
    image: n8nio/n8n:latest
    command: worker
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_DATABASE: main_db
      DB_POSTGRESDB_HOST: db_postgres
      DB_POSTGRESDB_USER: postgres
      DB_POSTGRESDB_PASSWORD: caixapretastack2626
      REDIS_HOST: db_redis-n8n
      REDIS_PORT: 6379
      REDIS_DB: 0
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
      SERVER_URL: https://evo.DOMAIN_PLACEHOLDER
      DATABASE_PROVIDER: postgresql
      DATABASE_ENABLED: "true"
      DATABASE_CONNECTION_URI: postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      REDIS_ENABLED: "true"
      REDIS_URI: redis://db_redis-n8n:6379/1
      REDIS_PREFIX_KEY: evolution
      LOG_LEVEL: info
    volumes:
      - /data/evolution:/home/evolution/instances
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  evolution2:
    image: atendai/evolution-api:latest
    environment:
      SERVER_URL: https://evo2.DOMAIN_PLACEHOLDER
      DATABASE_PROVIDER: postgresql
      DATABASE_ENABLED: "true"
      DATABASE_CONNECTION_URI: postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      REDIS_ENABLED: "true"
      REDIS_URI: redis://db_redis-n8n:6379/2
      REDIS_PREFIX_KEY: evolution2
      LOG_LEVEL: info
    volumes:
      - /data/evolution2:/home/evolution/instances
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOFAPPS

sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /tmp/apps-stack.yml

docker stack deploy -c /tmp/apps-stack.yml automation
log_success "Automation services deployed"

sleep 30

# Deploy MEGA and monitoring
log_step "Deploying MEGA, MinIO, and Grafana"

cat > /tmp/mega-stack.yml << 'EOFMEGA'
version: '3.8'
services:
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: caixapretastack2626
      MINIO_BROWSER: "on"
    volumes:
      - /data/minio:/data
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  grafana:
    image: grafana/grafana:latest
    user: "472:472"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: caixapretastack2626
      GF_SERVER_ROOT_URL: https://graf.DOMAIN_PLACEHOLDER
      GF_SERVER_SERVE_FROM_SUB_PATH: "true"
      GF_SECURITY_ALLOW_EMBEDDING: "true"
      GF_AUTH_ANONYMOUS_ENABLED: "false"
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      REDIS_URL: redis://db_redis-mega:6379/1
      SECRET_KEY_BASE: caixapretastack2626
      INSTALLATION_ENV: docker
      FRONTEND_URL: https://chat.DOMAIN_PLACEHOLDER
    volumes:
      - /data/mega:/app/storage
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints:
          - node.role==manager
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  mega-sidekiq:
    image: sendingtk/chatwoot:v4.11.2
    command: bundle exec sidekiq -c 5 -q default -q mailers -q medium -q low -q realtime -q push_notifications -q webhooks -q presence -q analytics
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      REDIS_URL: redis://db_redis-mega:6379/1
      SECRET_KEY_BASE: caixapretastack2626
      INSTALLATION_ENV: docker
    networks:
      - internal-net
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

sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /tmp/mega-stack.yml

docker stack deploy -c /tmp/mega-stack.yml apps
log_success "MEGA, MinIO, and Grafana deployed"

sleep 30

# Deploy Portainer
log_step "Deploying Portainer"

docker service create \
    --name core_portainer \
    --constraint 'node.role==manager' \
    --publish mode=host,target=9000,published=9000 \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=bind,source=/data/portainer,target=/data \
    --network traefik-public \
    portainer/portainer-ce:latest \
    -H unix:///var/run/docker.sock

log_success "Portainer deployed"

sleep 20

# Deploy Nginx reverse proxy
log_step "Deploying Nginx Reverse Proxy"

docker service create \
    --name core_nginx \
    --constraint 'node.role==manager' \
    --publish mode=host,target=80,published=80 \
    --publish mode=host,target=443,published=443 \
    --mount type=bind,source=/tmp/nginx.conf,target=/etc/nginx/nginx.conf \
    --mount type=bind,source=/data/nginx/certs,target=/etc/nginx/certs \
    --network traefik-public \
    nginx:latest

log_success "Nginx reverse proxy deployed"

sleep 20

# Final verification
log_step "Final Verification"

echo ""
echo "Checking service status..."
docker service ls

echo ""
log_success "Installation Complete!"

echo ""
echo "=========================================="
echo "ACCESS ENDPOINTS"
echo "=========================================="
echo "n8n:        https://auto.$DOMAIN"
echo "Evolution:  https://evo.$DOMAIN"
echo "Evolution2: https://evo2.$DOMAIN"
echo "MinIO API:  https://s3.$DOMAIN"
echo "MinIO UI:   https://min.$DOMAIN"
echo "Grafana:    https://graf.$DOMAIN"
echo "Chatwoot:   https://chat.$DOMAIN"
echo "Portainer:  https://port.$DOMAIN"
echo ""
echo "=========================================="
echo "DEFAULT CREDENTIALS"
echo "=========================================="
echo "All services: caixapretastack2626"
echo ""
echo "=========================================="
echo "IMPORTANT NOTES"
echo "=========================================="
echo "1. DNS must be proxied through Cloudflare (orange cloud)"
echo "2. Cloudflare provides valid SSL to end users"
echo "3. Internal nginx uses self-signed certificates (normal)"
echo "4. Test with: curl -k https://auto.$DOMAIN"
echo ""
echo "=========================================="
echo "MONITORING"
echo "=========================================="
echo "View logs: docker service logs <service_name>"
echo "List services: docker service ls"
echo "Check status: docker service ps <service_name>"
echo ""

log_success "Caixa Preta is ready!"

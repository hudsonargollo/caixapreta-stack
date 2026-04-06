#!/bin/bash

# Fix Traefik configuration for Cloudflare SSL termination
# This removes ACME/Let's Encrypt configuration and relies on Cloudflare for SSL

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

# Get domain from user
read -p "Enter your domain (e.g., clubemkt.digital): " DOMAIN
read -p "Enter your email (for reference only): " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    log_error "Domain and email are required"
    exit 1
fi

log_info "Removing old Traefik service..."
docker service rm core_traefik 2>/dev/null || true
docker service rm core_portainer 2>/dev/null || true

# Wait for cleanup
sleep 10

log_info "Deploying Traefik v2.11 with Cloudflare SSL termination..."

docker service create \
  --name core_traefik \
  --constraint 'node.role==manager' \
  --publish mode=host,target=80,published=80 \
  --publish mode=host,target=443,published=443 \
  --publish mode=host,target=8080,published=8080 \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/data/traefik,target=/data \
  --network traefik-public \
  --label traefik.enable=true \
  --label "traefik.http.routers.traefik.rule=Host(\`trae.$DOMAIN\`)" \
  --label traefik.http.routers.traefik.service=api@internal \
  --label traefik.http.routers.traefik.entrypoints=websecure \
  --label traefik.http.services.traefik.loadbalancer.server.port=8080 \
  traefik:v2.11 \
  --api.dashboard=true \
  --api.insecure=false \
  --providers.docker=true \
  --providers.docker.exposedbydefault=false \
  --providers.docker.swarmmode=true \
  --entrypoints.web.address=:80 \
  --entrypoints.websecure.address=:443 \
  --entrypoints.web.http.redirections.entrypoint.to=websecure \
  --entrypoints.web.http.redirections.entrypoint.scheme=https \
  --log.level=INFO

log_success "Traefik deployed"

log_info "Deploying Portainer..."

docker service create \
  --name core_portainer \
  --constraint 'node.role==manager' \
  --publish mode=host,target=9000,published=9000 \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/data/portainer,target=/data \
  --network traefik-public \
  --label traefik.enable=true \
  --label "traefik.http.routers.portainer.rule=Host(\`port.$DOMAIN\`)" \
  --label traefik.http.routers.portainer.entrypoints=websecure \
  --label traefik.http.services.portainer.loadbalancer.server.port=9000 \
  portainer/portainer-ce:latest \
  -H unix:///var/run/docker.sock

log_success "Portainer deployed"

log_info "Waiting for services to start..."
sleep 15

log_info "Checking Traefik logs..."
docker service logs core_traefik --tail 20

log_success "Traefik reconfigured for Cloudflare SSL termination"
log_info "Services should now be accessible via HTTPS with Cloudflare SSL certificates"
log_info "Test with: curl -k https://trae.$DOMAIN"

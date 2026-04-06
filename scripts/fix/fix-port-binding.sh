#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - FIX PORT BINDING ISSUE
# Fix Traefik port binding problems
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

echo -e "${CYAN}🔧 FIXING TRAEFIK PORT BINDING ISSUE${NC}"
echo "=================================="

# Get domain from existing Traefik config
DOMAIN=$(grep -o 'Host(`[^`]*`' /data/traefik/traefik.yml 2>/dev/null | head -1 | sed 's/Host(`//;s/`//' | cut -d'.' -f2- 2>/dev/null || echo "clubemkt.digital")

print_info "Using domain: $DOMAIN"

# 1. Check current port status
print_info "Step 1: Checking current port binding..."
if netstat -tlnp | grep -q ":80 "; then
    print_success "Port 80 is currently bound"
else
    print_error "Port 80 is NOT bound"
fi

if netstat -tlnp | grep -q ":443 "; then
    print_success "Port 443 is currently bound"
else
    print_error "Port 443 is NOT bound"
fi

# 2. Force restart Traefik
print_info "Step 2: Force restarting Traefik service..."
docker service update --force core_traefik

print_info "Waiting 30 seconds for Traefik to restart..."
sleep 30

# 3. Check if ports are now bound
print_info "Step 3: Checking ports after restart..."
if netstat -tlnp | grep -q ":80 "; then
    print_success "Port 80 is now bound"
    PORT_80_OK=true
else
    print_error "Port 80 is still NOT bound"
    PORT_80_OK=false
fi

if netstat -tlnp | grep -q ":443 "; then
    print_success "Port 443 is now bound"
    PORT_443_OK=true
else
    print_error "Port 443 is still NOT bound"
    PORT_443_OK=false
fi

# 4. If ports still not bound, redeploy core stack
if [ "$PORT_80_OK" = false ] || [ "$PORT_443_OK" = false ]; then
    print_warning "Ports still not bound. Redeploying core stack..."
    
    # Remove existing core stack
    print_info "Removing existing core stack..."
    docker stack rm core
    
    print_info "Waiting for cleanup..."
    sleep 15
    
    # Recreate core stack with proper configuration
    print_info "Creating new core stack configuration..."
    
cat <<EOF > /tmp/swarm-core-fixed.yml
version: '3.8'
services:
  traefik:
    image: traefik:v2.10
    command:
      - "--configfile=/etc/traefik/traefik.yml"
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
      - target: 443
        published: 443
        protocol: tcp
        mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /data/traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - /data/traefik/acme.json:/etc/traefik/acme.json
    networks:
      - traefik-public
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.traefik.rule=Host(\`traefik.$DOMAIN\`)"
        - "traefik.http.routers.traefik.service=api@internal"
        - "traefik.http.routers.traefik.entrypoints=websecure"
        - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
        - "traefik.http.services.traefik.loadbalancer.server.port=8080"

  portainer:
    image: portainer/portainer-ce:latest
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /data/portainer:/data
    networks:
      - traefik-public
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.portainer.rule=Host(\`portainer.$DOMAIN\`)"
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik-public:
    external: true
EOF

    # Deploy the fixed core stack
    print_info "Deploying fixed core stack..."
    docker stack deploy -c /tmp/swarm-core-fixed.yml core
    
    print_info "Waiting for services to start..."
    sleep 30
    
    # Clean up temp file
    rm -f /tmp/swarm-core-fixed.yml
fi

# 5. Final verification
print_info "Step 4: Final verification..."
echo
echo "Current service status:"
docker service ls | grep core

echo
echo "Port binding status:"
if netstat -tlnp | grep -q ":80 "; then
    print_success "Port 80 is bound"
    netstat -tlnp | grep ":80 " | head -1
else
    print_error "Port 80 is still NOT bound"
fi

if netstat -tlnp | grep -q ":443 "; then
    print_success "Port 443 is bound"
    netstat -tlnp | grep ":443 " | head -1
else
    print_error "Port 443 is still NOT bound"
fi

# 6. Test connectivity
print_info "Step 5: Testing connectivity..."
sleep 10

echo "Testing HTTP connectivity:"
HTTP_CODE=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "http://portainer.$DOMAIN" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    print_success "HTTP redirect working (code: $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    print_error "HTTP connection failed"
else
    print_warning "HTTP returned code: $HTTP_CODE"
fi

# 7. Check Traefik logs for any remaining issues
print_info "Step 6: Recent Traefik logs..."
docker service logs --tail 5 core_traefik 2>/dev/null || print_warning "Could not fetch Traefik logs"

echo
if netstat -tlnp | grep -q ":80 " && netstat -tlnp | grep -q ":443 "; then
    print_success "🎉 PORT BINDING FIXED! Services should now be accessible."
    echo
    print_info "Test your services:"
    echo "- http://portainer.$DOMAIN (should redirect to HTTPS)"
    echo "- https://portainer.$DOMAIN (may show SSL warning initially)"
    echo
    print_info "SSL certificates will generate automatically in 5-15 minutes"
else
    print_error "Port binding issue persists. Manual intervention required."
    echo
    print_info "Manual troubleshooting steps:"
    echo "1. Check if another service is using ports 80/443:"
    echo "   sudo lsof -i :80"
    echo "   sudo lsof -i :443"
    echo "2. Restart Docker daemon:"
    echo "   sudo systemctl restart docker"
    echo "3. Check Docker Swarm status:"
    echo "   docker info | grep Swarm"
fi

print_success "Port binding fix script completed!"
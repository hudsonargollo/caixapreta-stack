#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - TRAEFIK DEPLOYMENT FIX
# Quick fix for Traefik deployment failures
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

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

print_fix() {
    echo -e "${PURPLE}🔧 ${1}${NC}"
}

clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"
████████╗██████╗  █████╗ ███████╗███████╗██╗██╗  ██╗    ███████╗██╗██╗  ██╗
╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║██║ ██╔╝    ██╔════╝██║╚██╗██╔╝
   ██║   ██████╔╝███████║█████╗  █████╗  ██║█████╔╝     █████╗  ██║ ╚███╔╝ 
   ██║   ██╔══██╗██╔══██║██╔══╝  ██╔══╝  ██║██╔═██╗     ██╔══╝  ██║ ██╔██╗ 
   ██║   ██║  ██║██║  ██║███████╗██║     ██║██║  ██╗    ██║     ██║██╔╝ ██╗
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${CYAN}${BOLD}TRAEFIK DEPLOYMENT FIX UTILITY${NC}"
echo "=================================="
echo

print_info "Applying common fixes for Traefik deployment failures..."
echo

# 1. Stop conflicting web servers
print_fix "Step 1: Stopping conflicting web servers..."

if systemctl is-active --quiet apache2 2>/dev/null; then
    systemctl stop apache2 >/dev/null 2>&1
    systemctl disable apache2 >/dev/null 2>&1
    print_success "Apache2 stopped and disabled"
else
    print_info "Apache2 not running"
fi

if systemctl is-active --quiet nginx 2>/dev/null; then
    systemctl stop nginx >/dev/null 2>&1
    systemctl disable nginx >/dev/null 2>&1
    print_success "Nginx stopped and disabled"
else
    print_info "Nginx not running"
fi

# 2. Fix SSL certificate permissions
print_fix "Step 2: Fixing SSL certificate permissions..."

if [ -f "/data/traefik/acme.json" ]; then
    chmod 600 /data/traefik/acme.json
    print_success "acme.json permissions fixed (600)"
else
    touch /data/traefik/acme.json
    chmod 600 /data/traefik/acme.json
    print_success "acme.json created with correct permissions"
fi

# 3. Check and fix data directory permissions
print_fix "Step 3: Fixing data directory permissions..."

if [ -d "/data/traefik" ]; then
    chown -R root:root /data/traefik
    chmod 755 /data/traefik
    print_success "Traefik directory permissions fixed"
else
    mkdir -p /data/traefik
    chown -R root:root /data/traefik
    chmod 755 /data/traefik
    print_success "Traefik directory created with correct permissions"
fi

# 4. Clean up any stuck containers
print_fix "Step 4: Cleaning up stuck containers..."

# Stop any running Traefik containers
docker ps -a | grep traefik | awk '{print $1}' | xargs -r docker stop >/dev/null 2>&1 || true
docker ps -a | grep traefik | awk '{print $1}' | xargs -r docker rm >/dev/null 2>&1 || true

print_success "Cleaned up any stuck Traefik containers"

# 5. Force update the service
print_fix "Step 5: Force updating Traefik service..."

if docker service ls | grep -q "core_traefik"; then
    docker service update --force core_traefik >/dev/null 2>&1
    print_success "Traefik service force updated"
    
    # Wait and check status
    print_info "Waiting 30 seconds for service to stabilize..."
    sleep 30
    
    TRAEFIK_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "core_traefik" | awk '{print $2}')
    
    if [[ "$TRAEFIK_STATUS" == "1/1" ]]; then
        print_success "Traefik is now running successfully! ($TRAEFIK_STATUS)"
        
        # Test port binding
        if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
            print_success "Port 80 is bound"
        else
            print_warning "Port 80 not bound yet (may take a few more seconds)"
        fi
        
        if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
            print_success "Port 443 is bound"
        else
            print_warning "Port 443 not bound yet (may take a few more seconds)"
        fi
        
    elif [[ "$TRAEFIK_STATUS" == "0/1" ]]; then
        print_error "Traefik still failing to start"
        print_info "Check logs with: docker service logs core_traefik"
        
        echo
        print_fix "Additional troubleshooting steps:"
        echo "1. Check recent logs: docker service logs --tail 50 core_traefik"
        echo "2. Check service tasks: docker service ps core_traefik --no-trunc"
        echo "3. Verify DNS: nslookup traefik.clubemkt.digital"
        echo "4. If still failing, remove and recreate:"
        echo "   docker service rm core_traefik"
        echo "   # Then re-run the installation script"
        
    else
        print_warning "Traefik status: $TRAEFIK_STATUS (still starting up)"
        print_info "Wait a few more minutes and check: docker service ls"
    fi
    
else
    print_error "Traefik service not found"
    print_info "Re-run the installation script to create the service"
fi

echo
echo -e "${CYAN}${BOLD}FIX UTILITY COMPLETE${NC}"
echo "=================================="

print_info "Next steps:"
echo "1. If Traefik is now running (1/1), continue with the installation"
echo "2. If still failing, run: ./diagnose-traefik.sh for detailed analysis"
echo "3. Check service status: docker service ls"
#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - TRAEFIK DIAGNOSTIC TOOL
# Comprehensive diagnosis for Traefik deployment failures
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

print_header() {
    echo -e "${CYAN}${BOLD}${1}${NC}"
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

print_fix() {
    echo -e "${PURPLE}🔧 ${1}${NC}"
}

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
████████╗██████╗  █████╗ ███████╗███████╗██╗██╗  ██╗
╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║██║ ██╔╝
   ██║   ██████╔╝███████║█████╗  █████╗  ██║█████╔╝ 
   ██║   ██╔══██╗██╔══██║██╔══╝  ██╔══╝  ██║██╔═██╗ 
   ██║   ██║  ██║██║  ██║███████╗██║     ██║██║  ██╗
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝
                                                     
██████╗ ██╗ █████╗  ██████╗ ███╗   ██╗ ██████╗ ███████╗████████╗██╗ ██████╗
██╔══██╗██║██╔══██╗██╔════╝ ████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██║██╔════╝
██║  ██║██║███████║██║  ███╗██╔██╗ ██║██║   ██║███████╗   ██║   ██║██║     
██║  ██║██║██╔══██║██║   ██║██║╚██╗██║██║   ██║╚════██║   ██║   ██║██║     
██████╔╝██║██║  ██║╚██████╔╝██║ ╚████║╚██████╔╝███████║   ██║   ██║╚██████╗
╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝ ╚═════╝
EOF
echo -e "${NC}"

print_header "TRAEFIK DEPLOYMENT DIAGNOSTIC"

# 1. Check Traefik Service Status
print_info "Step 1: Checking Traefik Service Status"
echo

if docker service ls | grep -q "core_traefik"; then
    TRAEFIK_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "core_traefik" | awk '{print $2}')
    print_info "Traefik service status: $TRAEFIK_STATUS"
    
    if [[ "$TRAEFIK_STATUS" == "0/1" ]]; then
        print_error "Traefik is failing to start (0/1 replicas)"
    elif [[ "$TRAEFIK_STATUS" == "1/1" ]]; then
        print_success "Traefik is running successfully"
        exit 0
    else
        print_warning "Traefik status unclear: $TRAEFIK_STATUS"
    fi
else
    print_error "Traefik service not found"
    exit 1
fi

# 2. Get Detailed Service Information
print_info "Step 2: Detailed Service Analysis"
echo

print_info "Service tasks and their states:"
docker service ps core_traefik --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}\t{{.Error}}"

echo
print_info "Recent Traefik service logs:"
docker service logs --tail 20 core_traefik 2>/dev/null || print_warning "Could not fetch service logs"

# 3. Check Port Conflicts
print_info "Step 3: Port Conflict Analysis"
echo

print_info "Checking if ports 80 and 443 are available:"

# Check port 80
if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    PROCESS_80=$(netstat -tlnp 2>/dev/null | grep ":80 " | head -1)
    print_warning "Port 80 is occupied: $PROCESS_80"
    
    # Check if it's Apache or Nginx
    if systemctl is-active --quiet apache2 2>/dev/null; then
        print_error "Apache2 is running and blocking port 80"
        print_fix "Run: systemctl stop apache2 && systemctl disable apache2"
    fi
    
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_error "Nginx is running and blocking port 80"
        print_fix "Run: systemctl stop nginx && systemctl disable nginx"
    fi
else
    print_success "Port 80 is available"
fi

# Check port 443
if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    PROCESS_443=$(netstat -tlnp 2>/dev/null | grep ":443 " | head -1)
    print_warning "Port 443 is occupied: $PROCESS_443"
else
    print_success "Port 443 is available"
fi

# 4. Check Traefik Configuration
print_info "Step 4: Traefik Configuration Analysis"
echo

if [ -f "/data/traefik/traefik.yml" ]; then
    print_success "Traefik configuration file exists"
    
    print_info "Configuration file contents:"
    cat /data/traefik/traefik.yml
    
    # Check for common configuration issues
    if grep -q "clubemkt.digital" /data/traefik/traefik.yml 2>/dev/null; then
        print_success "Domain found in configuration"
    else
        print_warning "Domain not found in Traefik configuration"
    fi
    
else
    print_error "Traefik configuration file missing: /data/traefik/traefik.yml"
fi

# 5. Check SSL Certificate File
print_info "Step 5: SSL Certificate File Analysis"
echo

if [ -f "/data/traefik/acme.json" ]; then
    ACME_PERMS=$(stat -c "%a" /data/traefik/acme.json 2>/dev/null)
    ACME_SIZE=$(stat -c "%s" /data/traefik/acme.json 2>/dev/null)
    
    print_info "acme.json permissions: $ACME_PERMS"
    print_info "acme.json size: $ACME_SIZE bytes"
    
    if [ "$ACME_PERMS" != "600" ]; then
        print_error "Incorrect acme.json permissions (should be 600)"
        print_fix "Run: chmod 600 /data/traefik/acme.json"
    else
        print_success "acme.json permissions are correct"
    fi
else
    print_error "SSL certificate file missing: /data/traefik/acme.json"
    print_fix "Run: touch /data/traefik/acme.json && chmod 600 /data/traefik/acme.json"
fi

# 6. DNS Resolution Check
print_info "Step 6: DNS Resolution Analysis"
echo

DOMAIN="clubemkt.digital"
SUBDOMAINS=("traefik" "portainer" "n8n" "evolution" "mega" "grafana" "minio" "s3")

print_info "Checking DNS resolution for subdomains:"
for subdomain in "${SUBDOMAINS[@]}"; do
    FULL_DOMAIN="$subdomain.$DOMAIN"
    if nslookup "$FULL_DOMAIN" >/dev/null 2>&1; then
        IP=$(nslookup "$FULL_DOMAIN" 2>/dev/null | grep -A1 "Name:" | tail -1 | awk '{print $2}' 2>/dev/null || echo "unknown")
        print_success "$FULL_DOMAIN resolves to $IP"
    else
        print_warning "$FULL_DOMAIN DNS resolution failed"
    fi
done

# 7. Docker Network Analysis
print_info "Step 7: Docker Network Analysis"
echo

if docker network ls | grep -q "traefik-public"; then
    print_success "traefik-public network exists"
    
    # Check network configuration
    print_info "Network details:"
    docker network inspect traefik-public --format "{{.Name}}: {{.Driver}} - {{.Scope}}"
else
    print_error "traefik-public network missing"
    print_fix "Run: docker network create --driver overlay --attachable traefik-public"
fi

# 8. System Resources Check
print_info "Step 8: System Resources Analysis"
echo

# Check memory
MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.0f", $2}')
MEMORY_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
MEMORY_PERCENT=$(( MEMORY_USED * 100 / MEMORY_TOTAL ))

print_info "Memory usage: ${MEMORY_USED}MB / ${MEMORY_TOTAL}MB (${MEMORY_PERCENT}%)"

if [ "$MEMORY_PERCENT" -gt 90 ]; then
    print_error "High memory usage may be causing container failures"
elif [ "$MEMORY_PERCENT" -gt 80 ]; then
    print_warning "Memory usage is high"
else
    print_success "Memory usage is acceptable"
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
print_info "Disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 90 ]; then
    print_error "Low disk space may be causing issues"
elif [ "$DISK_USAGE" -gt 80 ]; then
    print_warning "Disk space is getting low"
else
    print_success "Disk space is sufficient"
fi

# 9. Recommended Fixes
print_info "Step 9: Recommended Fixes"
echo

print_header "RECOMMENDED ACTIONS"

echo -e "${PURPLE}${BOLD}Immediate Fixes:${NC}"
echo

print_fix "1. Stop conflicting web servers:"
echo "   systemctl stop apache2 nginx"
echo "   systemctl disable apache2 nginx"
echo

print_fix "2. Fix SSL certificate permissions:"
echo "   chmod 600 /data/traefik/acme.json"
echo

print_fix "3. Force update Traefik service:"
echo "   docker service update --force core_traefik"
echo

print_fix "4. If still failing, restart the service:"
echo "   docker service rm core_traefik"
echo "   # Wait 10 seconds, then re-run the installation script"
echo

print_fix "5. Check DNS propagation:"
echo "   Make sure your domain DNS A/AAAA records point to: 38.242.145.204"
echo

print_header "DIAGNOSTIC COMPLETE"
print_info "Run the recommended fixes above and then restart the deployment"
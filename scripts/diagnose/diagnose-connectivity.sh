#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - CONNECTIVITY DIAGNOSTIC TOOL
# Comprehensive diagnosis for service accessibility issues
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

print_header "CAIXA PRETA STACK - CONNECTIVITY DIAGNOSTIC"

DOMAIN="clubemkt.digital"
SUBDOMAINS=("portainer" "traefik" "n8n" "evolution" "minio" "s3" "mega" "grafana")

# 1. Check Docker Swarm and Services
print_info "Step 1: Docker Swarm and Service Status"
echo
if docker info | grep -q "Swarm: active"; then
    print_success "Docker Swarm is active"
else
    print_error "Docker Swarm is not active!"
    exit 1
fi

echo "Current service status:"
docker service ls
echo

FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)
if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_error "$FAILED_SERVICES services are not running:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}" | grep "0/"
else
    print_success "All services are running"
fi

# 2. Check Traefik Status (Critical for routing)
print_info "Step 2: Traefik Proxy Status"
echo
if docker service ps core_traefik --format "{{.CurrentState}}" | grep -q "Running"; then
    print_success "Traefik service is running"
    
    # Check Traefik logs for errors
    echo "Recent Traefik logs:"
    docker service logs --tail 10 core_traefik 2>/dev/null || print_warning "Could not fetch Traefik logs"
else
    print_error "Traefik service is not running!"
    print_info "Traefik is critical for routing - checking why it failed..."
    docker service ps core_traefik
fi

# 3. Check Network Configuration
print_info "Step 3: Docker Network Configuration"
echo
if docker network ls | grep -q "traefik-public"; then
    print_success "traefik-public network exists"
else
    print_error "traefik-public network missing!"
fi

if docker network ls | grep -q "internal-net"; then
    print_success "internal-net network exists"
else
    print_error "internal-net network missing!"
fi

# 4. Check Port Binding
print_info "Step 4: Port Binding Check"
echo
if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    print_success "Port 80 is bound"
    netstat -tlnp 2>/dev/null | grep ":80 " | head -1
else
    print_error "Port 80 is not bound!"
fi

if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    print_success "Port 443 is bound"
    netstat -tlnp 2>/dev/null | grep ":443 " | head -1
else
    print_error "Port 443 is not bound!"
fi

# 5. DNS Resolution Test
print_info "Step 5: DNS Resolution Test"
echo
for subdomain in "${SUBDOMAINS[@]}"; do
    FULL_DOMAIN="$subdomain.$DOMAIN"
    echo -n "Testing $FULL_DOMAIN: "
    
    if nslookup "$FULL_DOMAIN" >/dev/null 2>&1; then
        IP=$(nslookup "$FULL_DOMAIN" 2>/dev/null | grep -A1 "Name:" | tail -1 | awk '{print $2}' 2>/dev/null || echo "unknown")
        print_success "Resolves to $IP"
    else
        print_error "DNS resolution failed"
    fi
done

# 6. Server IP Detection
print_info "Step 6: Server IP Configuration"
echo
SERVER_IPV4=$(timeout 5 curl -s -4 ifconfig.me 2>/dev/null || echo "")
SERVER_IPV6=$(timeout 5 curl -s -6 ifconfig.me 2>/dev/null || echo "")

if [ -n "$SERVER_IPV4" ]; then
    print_info "Server IPv4: $SERVER_IPV4"
else
    print_warning "Could not detect IPv4 address"
fi

if [ -n "$SERVER_IPV6" ]; then
    print_info "Server IPv6: $SERVER_IPV6"
else
    print_warning "Could not detect IPv6 address"
fi

# 7. Firewall Check
print_info "Step 7: Firewall Configuration"
echo
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status 2>/dev/null | head -1)
    echo "UFW Status: $UFW_STATUS"
    
    if ufw status 2>/dev/null | grep -q "80.*ALLOW"; then
        print_success "Port 80 allowed in firewall"
    else
        print_warning "Port 80 may be blocked by firewall"
    fi
    
    if ufw status 2>/dev/null | grep -q "443.*ALLOW"; then
        print_success "Port 443 allowed in firewall"
    else
        print_warning "Port 443 may be blocked by firewall"
    fi
else
    print_info "UFW not installed - checking iptables"
    if iptables -L INPUT 2>/dev/null | grep -q "ACCEPT.*80"; then
        print_success "Port 80 appears to be allowed"
    else
        print_warning "Port 80 status unclear in iptables"
    fi
fi

# 8. Direct Service Connectivity Test
print_info "Step 8: Direct Service Connectivity Test"
echo
for subdomain in "portainer" "traefik" "n8n" "evolution"; do
    FULL_DOMAIN="$subdomain.$DOMAIN"
    echo -n "Testing HTTPS $FULL_DOMAIN: "
    
    HTTP_CODE=$(timeout 10 curl -s -o /dev/null -w "%{http_code}" -k "https://$FULL_DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
        print_success "HTTP $HTTP_CODE"
    elif [ "$HTTP_CODE" = "404" ]; then
        print_warning "HTTP 404 (service not configured in Traefik)"
    elif [ "$HTTP_CODE" = "000" ]; then
        print_error "Connection failed (timeout/refused)"
    else
        print_warning "HTTP $HTTP_CODE"
    fi
done

# 9. SSL Certificate Check
print_info "Step 9: SSL Certificate Status"
echo
if [ -f "/data/traefik/acme.json" ]; then
    CERT_SIZE=$(stat -c%s "/data/traefik/acme.json" 2>/dev/null || echo "0")
    if [ "$CERT_SIZE" -gt 100 ]; then
        print_success "SSL certificates exist (${CERT_SIZE} bytes)"
        
        # Try to show certificate domains
        if command -v jq >/dev/null 2>&1; then
            CERT_DOMAINS=$(jq -r '.letsencrypt.Certificates[]?.domain.main' /data/traefik/acme.json 2>/dev/null | head -3)
            if [ -n "$CERT_DOMAINS" ]; then
                echo "Certificate domains:"
                echo "$CERT_DOMAINS" | while read domain; do
                    echo "  - $domain"
                done
            fi
        fi
    else
        print_warning "SSL certificate file is empty (${CERT_SIZE} bytes)"
    fi
else
    print_error "SSL certificate file not found"
fi

# 10. Traefik Configuration Check
print_info "Step 10: Traefik Configuration"
echo
if [ -f "/data/traefik/traefik.yml" ]; then
    print_success "Traefik config file exists"
    
    if grep -q "$DOMAIN" /data/traefik/traefik.yml 2>/dev/null; then
        print_success "Domain found in Traefik config"
    else
        print_warning "Domain not found in Traefik config"
    fi
else
    print_error "Traefik config file missing"
fi

# 11. Service Labels Check (Traefik routing)
print_info "Step 11: Service Routing Labels"
echo
echo "Checking if services have proper Traefik labels..."

# Check core services
for service in "core_traefik" "core_portainer"; do
    if docker service inspect "$service" >/dev/null 2>&1; then
        LABELS=$(docker service inspect "$service" --format '{{range $key, $value := .Spec.Labels}}{{$key}}={{$value}}{{"\n"}}{{end}}' 2>/dev/null | grep traefik | wc -l)
        if [ "$LABELS" -gt 0 ]; then
            print_success "$service has $LABELS Traefik labels"
        else
            print_warning "$service has no Traefik labels"
        fi
    else
        print_error "$service not found"
    fi
done

# 12. Summary and Recommendations
print_info "Step 12: Diagnosis Summary"
echo
print_header "DIAGNOSIS RESULTS"

# Critical issues that prevent access
CRITICAL_ISSUES=0

if ! docker service ps core_traefik --format "{{.CurrentState}}" | grep -q "Running"; then
    print_error "CRITICAL: Traefik proxy is not running"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if ! netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    print_error "CRITICAL: Port 80 is not bound"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if ! netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    print_error "CRITICAL: Port 443 is not bound"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if [ "$CRITICAL_ISSUES" -gt 0 ]; then
    echo
    print_error "Found $CRITICAL_ISSUES critical issues preventing service access"
    echo
    print_info "IMMEDIATE FIXES NEEDED:"
    echo "1. Restart Traefik: docker service update --force core_traefik"
    echo "2. Check Traefik logs: docker service logs core_traefik"
    echo "3. Verify network configuration: docker network ls"
    echo "4. Run deployment fix: ./fix-deployment-issues.sh"
else
    print_success "No critical infrastructure issues found"
    print_info "Issue may be DNS propagation or SSL certificate generation"
    print_info "Wait 10-15 minutes and test again"
fi

echo
print_info "For detailed service logs, run:"
echo "docker service logs core_traefik"
echo "docker service logs core_portainer"
echo "docker service logs apps_evolution"

print_success "Connectivity diagnosis completed!"
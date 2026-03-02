#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔍 SSL & DNS DIAGNOSTIC TOOL${NC}"
echo "============================="
echo

# Get domain from user
echo -e "${YELLOW}Enter your domain (e.g., yourdomain.com):${NC}"
read -p "Domain: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ Domain is required${NC}"
    exit 1
fi

echo
echo -e "${BLUE}🌐 Checking domain: $DOMAIN${NC}"
echo "================================"

# 1. Check DNS resolution
echo -e "\n${YELLOW}1. DNS Resolution Check:${NC}"
SUBDOMAINS=("mega" "evolution" "minio" "grafana" "n8n" "portainer" "traefik")

for subdomain in "${SUBDOMAINS[@]}"; do
    FULL_DOMAIN="$subdomain.$DOMAIN"
    echo -n "   $FULL_DOMAIN: "
    
    if nslookup "$FULL_DOMAIN" >/dev/null 2>&1; then
        IP=$(nslookup "$FULL_DOMAIN" | grep -A1 "Name:" | tail -1 | awk '{print $2}' 2>/dev/null)
        if [ -n "$IP" ]; then
            echo -e "${GREEN}✅ Resolves to $IP${NC}"
        else
            echo -e "${GREEN}✅ Resolves${NC}"
        fi
    else
        echo -e "${RED}❌ DNS not configured${NC}"
    fi
done

# 2. Check server IP
echo -e "\n${YELLOW}2. Server IP Check:${NC}"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)
if [ -n "$SERVER_IP" ]; then
    echo -e "   Server IP: ${GREEN}$SERVER_IP${NC}"
else
    echo -e "   ${RED}❌ Could not detect server IP${NC}"
fi

# 3. Check Docker services
echo -e "\n${YELLOW}3. Docker Services Status:${NC}"
if docker service ls >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Swarm is active${NC}"
    echo
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Ports}}"
    
    # Check for failed services
    FAILED_COUNT=$(docker service ls --format "{{.Replicas}}" | grep "0/" | wc -l)
    if [ "$FAILED_COUNT" -gt 0 ]; then
        echo -e "\n${RED}❌ $FAILED_COUNT services are not running${NC}"
        echo -e "${YELLOW}Failed services:${NC}"
        docker service ls --format "table {{.Name}}\t{{.Replicas}}" | grep "0/"
    fi
else
    echo -e "${RED}❌ Docker Swarm is not active${NC}"
    exit 1
fi

# 4. Check Traefik status and SSL certificates
echo -e "\n${YELLOW}4. Traefik & SSL Certificate Check:${NC}"
if docker service ps core_traefik --format "{{.CurrentState}}" | grep -q "Running"; then
    echo -e "${GREEN}✅ Traefik service is running${NC}"
    
    # Check SSL certificate file
    if [ -f "/data/traefik/acme.json" ]; then
        CERT_SIZE=$(stat -c%s "/data/traefik/acme.json" 2>/dev/null || echo "0")
        if [ "$CERT_SIZE" -gt 100 ]; then
            echo -e "${GREEN}✅ SSL certificates exist (${CERT_SIZE} bytes)${NC}"
            
            # Check certificate domains
            if command -v jq >/dev/null 2>&1; then
                CERT_DOMAINS=$(jq -r '.letsencrypt.Certificates[]?.domain.main' /data/traefik/acme.json 2>/dev/null | head -5)
                if [ -n "$CERT_DOMAINS" ]; then
                    echo -e "${BLUE}   Certificate domains:${NC}"
                    echo "$CERT_DOMAINS" | while read domain; do
                        echo "     - $domain"
                    done
                fi
            fi
        else
            echo -e "${RED}❌ SSL certificate file is empty or missing${NC}"
        fi
    else
        echo -e "${RED}❌ SSL certificate file not found${NC}"
    fi
else
    echo -e "${RED}❌ Traefik service is not running${NC}"
fi

# 5. Test HTTP/HTTPS connectivity
echo -e "\n${YELLOW}5. Connectivity Tests:${NC}"
for subdomain in "mega" "evolution" "minio" "grafana"; do
    FULL_DOMAIN="$subdomain.$DOMAIN"
    echo -n "   Testing $FULL_DOMAIN: "
    
    # Test HTTPS first
    HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "https://$FULL_DOMAIN" 2>/dev/null)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$FULL_DOMAIN" 2>/dev/null)
    
    if [ "$HTTPS_CODE" = "200" ] || [ "$HTTPS_CODE" = "302" ] || [ "$HTTPS_CODE" = "301" ]; then
        echo -e "${GREEN}✅ HTTPS $HTTPS_CODE${NC}"
    elif [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
        echo -e "${YELLOW}⚠️  HTTP $HTTP_CODE (no SSL)${NC}"
    elif [ "$HTTPS_CODE" = "404" ]; then
        echo -e "${RED}❌ HTTPS 404 (service not configured)${NC}"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo -e "${RED}❌ HTTP 404 (service not configured)${NC}"
    else
        echo -e "${RED}❌ No response (HTTPS: $HTTPS_CODE, HTTP: $HTTP_CODE)${NC}"
    fi
done

# 6. Check Traefik configuration
echo -e "\n${YELLOW}6. Traefik Configuration:${NC}"
if [ -f "/data/traefik/traefik.yml" ]; then
    echo -e "${GREEN}✅ Traefik config exists${NC}"
    
    # Check if domain is in config
    if grep -q "$DOMAIN" /data/traefik/traefik.yml 2>/dev/null; then
        echo -e "${GREEN}✅ Domain found in Traefik config${NC}"
    else
        echo -e "${RED}❌ Domain not found in Traefik config${NC}"
    fi
else
    echo -e "${RED}❌ Traefik config file missing${NC}"
fi

# 7. Check firewall
echo -e "\n${YELLOW}7. Firewall Check:${NC}"
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status | head -1)
    echo "   UFW Status: $UFW_STATUS"
    
    if ufw status | grep -q "80.*ALLOW"; then
        echo -e "${GREEN}✅ Port 80 (HTTP) is open${NC}"
    else
        echo -e "${RED}❌ Port 80 (HTTP) may be blocked${NC}"
    fi
    
    if ufw status | grep -q "443.*ALLOW"; then
        echo -e "${GREEN}✅ Port 443 (HTTPS) is open${NC}"
    else
        echo -e "${RED}❌ Port 443 (HTTPS) may be blocked${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  UFW not installed${NC}"
fi

# 8. Check specific service logs
echo -e "\n${YELLOW}8. Service Logs (last 10 lines):${NC}"
for service in "core_traefik" "apps_mega-rails" "apps_evolution" "apps_minio" "apps_grafana"; do
    echo -e "\n${BLUE}--- $service ---${NC}"
    if docker service logs --tail 5 "$service" 2>/dev/null; then
        echo -e "${GREEN}✅ Logs available${NC}"
    else
        echo -e "${RED}❌ Service not found or no logs${NC}"
    fi
done

echo
echo -e "${CYAN}📋 DIAGNOSIS SUMMARY${NC}"
echo "==================="

# Provide recommendations
echo -e "\n${BLUE}💡 RECOMMENDATIONS:${NC}"

# Check if DNS is the issue
DNS_ISSUES=0
for subdomain in "mega" "evolution" "minio" "grafana"; do
    if ! nslookup "$subdomain.$DOMAIN" >/dev/null 2>&1; then
        DNS_ISSUES=$((DNS_ISSUES + 1))
    fi
done

if [ "$DNS_ISSUES" -gt 0 ]; then
    echo -e "${RED}🔴 DNS Configuration Issues Detected${NC}"
    echo "   1. Add these DNS A records pointing to $SERVER_IP:"
    for subdomain in "mega" "evolution" "minio" "grafana" "n8n" "portainer" "traefik"; do
        echo "      $subdomain.$DOMAIN → $SERVER_IP"
    done
    echo "   2. Wait 5-15 minutes for DNS propagation"
    echo "   3. Re-run this diagnostic script"
fi

if [ -f "/data/traefik/acme.json" ]; then
    CERT_SIZE=$(stat -c%s "/data/traefik/acme.json" 2>/dev/null || echo "0")
    if [ "$CERT_SIZE" -lt 100 ]; then
        echo -e "${YELLOW}🟡 SSL Certificate Issues${NC}"
        echo "   1. Certificates are not generated yet"
        echo "   2. Check Traefik logs: docker service logs core_traefik"
        echo "   3. Ensure DNS is properly configured first"
        echo "   4. Wait 10-15 minutes for Let's Encrypt generation"
    fi
fi

FAILED_COUNT=$(docker service ls --format "{{.Replicas}}" | grep "0/" | wc -l 2>/dev/null || echo "0")
if [ "$FAILED_COUNT" -gt 0 ]; then
    echo -e "${RED}🔴 Service Deployment Issues${NC}"
    echo "   1. Run: ./fix-and-redeploy.sh"
    echo "   2. Check individual service logs"
    echo "   3. Verify Docker Swarm is healthy"
fi

echo
echo -e "${CYAN}🛠️  QUICK FIXES:${NC}"
echo "1. Fix DNS: Configure A records in your domain provider"
echo "2. Fix services: wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-and-redeploy.sh && chmod +x fix-and-redeploy.sh && sudo ./fix-and-redeploy.sh"
echo "3. Fix MEGA specifically: wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-mega.sh && chmod +x fix-mega.sh && sudo ./fix-mega.sh"
echo "4. Check Traefik: docker service logs core_traefik"

echo
echo -e "${GREEN}Diagnostic complete!${NC}"
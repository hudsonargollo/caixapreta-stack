#!/bin/bash

# CaixaPreta Stack - Portainer Diagnostic Script
# This script helps diagnose common Portainer access issues

echo "=== CaixaPreta Stack - Portainer Diagnostics ==="
echo

# Get domain from user
read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "Domain is required!"
    exit 1
fi

echo "Checking Portainer access for: portainer.$DOMAIN"
echo

# 1. Check Docker Swarm status
echo "1. Checking Docker Swarm status..."
if docker info | grep -q "Swarm: active"; then
    echo "✅ Docker Swarm is active"
else
    echo "❌ Docker Swarm is not active"
    exit 1
fi
echo

# 2. Check if services are running
echo "2. Checking services status..."
echo "Stack status:"
docker stack ls
echo
echo "Service status:"
docker service ls
echo

# 3. Check Portainer service specifically
echo "3. Checking Portainer service..."
if docker service ps core_portainer 2>/dev/null; then
    echo "✅ Portainer service exists"
    echo "Portainer service details:"
    docker service ps core_portainer
else
    echo "❌ Portainer service not found"
    echo "Available services:"
    docker service ls
fi
echo

# 4. Check Traefik service
echo "4. Checking Traefik service..."
if docker service ps core_traefik 2>/dev/null; then
    echo "✅ Traefik service exists"
    echo "Traefik service details:"
    docker service ps core_traefik
else
    echo "❌ Traefik service not found"
fi
echo

# 5. Check networks
echo "5. Checking Docker networks..."
if docker network ls | grep -q "traefik-public"; then
    echo "✅ traefik-public network exists"
else
    echo "❌ traefik-public network missing"
fi
echo

# 6. Check DNS resolution
echo "6. Checking DNS resolution..."
if command -v nslookup &> /dev/null; then
    echo "DNS lookup for portainer.$DOMAIN:"
    nslookup portainer.$DOMAIN || echo "❌ DNS resolution failed"
else
    echo "nslookup not available, trying ping..."
    ping -c 1 portainer.$DOMAIN || echo "❌ Cannot reach portainer.$DOMAIN"
fi
echo

# 7. Check SSL certificates
echo "7. Checking SSL certificates..."
if [ -f "/data/traefik/acme.json" ]; then
    echo "✅ ACME file exists"
    if [ -s "/data/traefik/acme.json" ]; then
        echo "✅ ACME file has content"
        echo "Certificate count: $(cat /data/traefik/acme.json | jq '.letsencrypt.Certificates | length' 2>/dev/null || echo 'Cannot parse')"
    else
        echo "⚠️  ACME file is empty"
    fi
else
    echo "❌ ACME file missing"
fi
echo

# 8. Check firewall
echo "8. Checking firewall..."
if command -v ufw &> /dev/null; then
    echo "UFW status:"
    ufw status
else
    echo "UFW not installed"
fi
echo

# 9. Check if ports are listening
echo "9. Checking listening ports..."
echo "Port 80 (HTTP):"
netstat -tlnp | grep :80 || echo "❌ Port 80 not listening"
echo "Port 443 (HTTPS):"
netstat -tlnp | grep :443 || echo "❌ Port 443 not listening"
echo

# 10. Test HTTP/HTTPS access
echo "10. Testing HTTP/HTTPS access..."
echo "Testing HTTP redirect..."
curl -I -s http://portainer.$DOMAIN | head -n 5 || echo "❌ HTTP test failed"
echo
echo "Testing HTTPS access..."
curl -I -s -k https://portainer.$DOMAIN | head -n 5 || echo "❌ HTTPS test failed"
echo

# 11. Show recent logs
echo "11. Recent Traefik logs (last 20 lines)..."
docker service logs --tail 20 core_traefik 2>/dev/null || echo "Cannot get Traefik logs"
echo

echo "12. Recent Portainer logs (last 20 lines)..."
docker service logs --tail 20 core_portainer 2>/dev/null || echo "Cannot get Portainer logs"
echo

echo "=== Diagnostic Complete ==="
echo
echo "Common solutions:"
echo "1. If DNS fails: Check your DNS A record for portainer.$DOMAIN"
echo "2. If services are down: Run 'docker stack deploy -c swarm-core.yml core'"
echo "3. If SSL fails: Wait 5-10 minutes for Let's Encrypt, check Traefik logs"
echo "4. If ports not listening: Check firewall with 'ufw allow 80' and 'ufw allow 443'"
echo "5. If still failing: Try accessing via IP: https://YOUR_SERVER_IP:9000"
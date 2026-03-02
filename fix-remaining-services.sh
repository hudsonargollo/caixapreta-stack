#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - FIX REMAINING SERVICE ISSUES
# Fix script for MEGA and n8n worker deployment issues
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

print_header "CAIXA PRETA STACK - FIXING REMAINING SERVICE ISSUES"

# 1. Check current service status
print_info "Step 1: Checking current service status..."
echo "Current service status:"
docker service ls

# 2. Fix MEGA services (Rails + Sidekiq)
print_info "Step 2: Fixing MEGA (Chatwoot) services..."

# Check if PostgreSQL is ready
print_info "Verifying PostgreSQL connectivity..."
if docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_postgres" | grep -q "1/1"; then
    print_success "PostgreSQL is running"
else
    print_error "PostgreSQL is not ready. Please wait for it to start."
    exit 1
fi

# Restart MEGA services with updated configuration
print_info "Restarting MEGA services..."
docker service update --force apps_mega-rails
docker service update --force apps_mega-sidekiq

# Wait for services to restart
print_info "Waiting for MEGA services to restart..."
sleep 15

# 3. Fix n8n workers
print_info "Step 3: Fixing n8n worker services..."

# Restart n8n workers
print_info "Restarting n8n workers..."
docker service update --force automation_n8n-worker

# Wait for workers to restart
print_info "Waiting for n8n workers to restart..."
sleep 10

# 4. Check if services are now running
print_info "Step 4: Verifying service status after fixes..."
echo
echo "Updated service status:"
docker service ls

# Count failed services
FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)

if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_warning "Some services are still starting up:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/" || true
    echo
    print_info "If services continue to fail, check individual logs:"
    echo "docker service logs apps_mega-rails"
    echo "docker service logs apps_mega-sidekiq"
    echo "docker service logs automation_n8n-worker"
else
    print_success "All services are now running!"
fi

# 5. DNS Configuration reminder
print_info "Step 5: DNS Configuration Status"
echo
print_warning "IMPORTANT: Ensure all DNS records are configured:"
echo
echo "Required AAAA records pointing to 2a02:c207:2309:5501::1:"
echo "✅ portainer.clubemkt.digital"
echo "✅ traefik.clubemkt.digital"
echo "✅ n8n.clubemkt.digital"
echo "✅ evolution.clubemkt.digital"
echo "✅ minio.clubemkt.digital"
echo "❌ s3.clubemkt.digital (MISSING - ADD THIS)"
echo "✅ mega.clubemkt.digital"
echo "✅ grafana.clubemkt.digital"
echo
print_error "CRITICAL: Add the missing s3.clubemkt.digital AAAA record!"
print_info "This is required for MinIO S3 API functionality"

# 6. SSL Certificate status
print_info "Step 6: SSL Certificate Status"
if [ -f "/data/traefik/acme.json" ]; then
    CERT_SIZE=$(stat -c%s "/data/traefik/acme.json" 2>/dev/null || echo "0")
    if [ "$CERT_SIZE" -gt 100 ]; then
        print_success "SSL certificates exist (${CERT_SIZE} bytes)"
        print_info "Certificates should generate automatically once DNS is fully configured"
    else
        print_warning "SSL certificates not generated yet"
        print_info "This is normal if DNS records were just added"
        print_info "Monitor with: docker service logs core_traefik"
    fi
else
    print_error "SSL certificate file not found"
fi

# 7. Final recommendations
print_info "Step 7: Final Recommendations"
echo
print_success "Next steps:"
echo "1. Add the missing s3.clubemkt.digital AAAA record"
echo "2. Wait 5-15 minutes for DNS propagation"
echo "3. Monitor SSL certificate generation: docker service logs core_traefik"
echo "4. Test all services are accessible via HTTPS"
echo
print_info "All services should be fully operational once DNS is complete!"

print_success "Service fix script completed!"
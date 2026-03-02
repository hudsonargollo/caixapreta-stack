#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - POSTGRESQL DEPLOYMENT FIX
# Quick fix for PostgreSQL deployment failures
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
██████╗  ██████╗ ███████╗████████╗ ██████╗ ██████╗ ███████╗███████╗ ██████╗ ██╗     
██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔════╝ ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║     
██████╔╝██║   ██║███████╗   ██║   ██║  ███╗██████╔╝█████╗  ███████╗██║   ██║██║     
██╔═══╝ ██║   ██║╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║██║▄▄ ██║██║     
██║     ╚██████╔╝███████║   ██║   ╚██████╔╝██║  ██║███████╗███████║╚██████╔╝███████╗
╚═╝      ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝ ╚══▀▀═╝ ╚══════╝
                                                                                     
███████╗██╗██╗  ██╗
██╔════╝██║╚██╗██╔╝
█████╗  ██║ ╚███╔╝ 
██╔══╝  ██║ ██╔██╗ 
██║     ██║██╔╝ ██╗
╚═╝     ╚═╝╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${CYAN}${BOLD}POSTGRESQL DEPLOYMENT FIX UTILITY${NC}"
echo "=================================="
echo

print_info "Applying common fixes for PostgreSQL deployment failures..."
echo

# 1. Stop conflicting PostgreSQL services
print_fix "Step 1: Stopping conflicting PostgreSQL services..."

if systemctl is-active --quiet postgresql 2>/dev/null; then
    systemctl stop postgresql >/dev/null 2>&1
    systemctl disable postgresql >/dev/null 2>&1
    print_success "System PostgreSQL stopped and disabled"
else
    print_info "System PostgreSQL not running"
fi

# Check for other PostgreSQL variants
for service in postgresql-14 postgresql-15 postgresql-16; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        systemctl stop "$service" >/dev/null 2>&1
        systemctl disable "$service" >/dev/null 2>&1
        print_success "$service stopped and disabled"
    fi
done

# 2. Fix data directory permissions
print_fix "Step 2: Fixing PostgreSQL data directory..."

if [ -d "/data/postgres" ]; then
    # Stop any containers using the directory
    docker ps -q -f name=postgres | xargs -r docker stop >/dev/null 2>&1 || true
    
    # Fix permissions (PostgreSQL uses UID 999)
    chown -R 999:999 /data/postgres
    chmod 755 /data/postgres
    print_success "PostgreSQL data directory permissions fixed"
else
    mkdir -p /data/postgres
    chown -R 999:999 /data/postgres
    chmod 755 /data/postgres
    print_success "PostgreSQL data directory created with correct permissions"
fi

# 3. Clean up any stuck containers
print_fix "Step 3: Cleaning up stuck PostgreSQL containers..."

# Stop and remove any PostgreSQL containers
docker ps -a | grep postgres | awk '{print $1}' | xargs -r docker stop >/dev/null 2>&1 || true
docker ps -a | grep postgres | awk '{print $1}' | xargs -r docker rm >/dev/null 2>&1 || true

print_success "Cleaned up any stuck PostgreSQL containers"

# 4. Check system resources
print_fix "Step 4: Checking system resources..."

MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.0f", $2}')
MEMORY_AVAILABLE=$(free -m | awk 'NR==2{printf "%.0f", $7}')

print_info "Total memory: ${MEMORY_TOTAL}MB"
print_info "Available memory: ${MEMORY_AVAILABLE}MB"

if [ "$MEMORY_AVAILABLE" -lt 512 ]; then
    print_warning "Low available memory (${MEMORY_AVAILABLE}MB). PostgreSQL may struggle."
    print_info "Consider freeing up memory or using a smaller PostgreSQL configuration"
else
    print_success "Sufficient memory available for PostgreSQL"
fi

# 5. Force update the service
print_fix "Step 5: Force updating PostgreSQL service..."

if docker service ls | grep -q "db_postgres"; then
    docker service update --force db_postgres >/dev/null 2>&1
    print_success "PostgreSQL service force updated"
    
    # Wait and check status
    print_info "Waiting 45 seconds for PostgreSQL to initialize..."
    sleep 45
    
    POSTGRES_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_postgres" | awk '{print $2}')
    
    if [[ "$POSTGRES_STATUS" == "1/1" ]]; then
        print_success "PostgreSQL is now running successfully! ($POSTGRES_STATUS)"
        
        # Test database readiness
        POSTGRES_CONTAINER=$(docker ps -q -f name=db_postgres 2>/dev/null)
        if [ -n "$POSTGRES_CONTAINER" ]; then
            print_info "Testing database readiness..."
            sleep 10
            
            if docker exec "$POSTGRES_CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then
                print_success "PostgreSQL is ready for connections"
                
                # Test basic connection
                if docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
                    print_success "Database connection test successful"
                else
                    print_warning "Database connection test failed (may need more time)"
                fi
            else
                print_warning "PostgreSQL not ready yet (may need more time to initialize)"
            fi
        fi
        
    elif [[ "$POSTGRES_STATUS" == "0/1" ]]; then
        print_error "PostgreSQL still failing to start"
        print_info "Check logs with: docker service logs db_postgres"
        
        echo
        print_fix "Additional troubleshooting steps:"
        echo "1. Check recent logs: docker service logs --tail 50 db_postgres"
        echo "2. Check service tasks: docker service ps db_postgres --no-trunc"
        echo "3. Check system resources: free -h && df -h"
        echo "4. If still failing, try recreating:"
        echo "   docker service rm db_postgres"
        echo "   # Then re-run the installation script"
        
    else
        print_warning "PostgreSQL status: $POSTGRES_STATUS (still starting up)"
        print_info "PostgreSQL can take 1-2 minutes to fully initialize"
        print_info "Wait a few more minutes and check: docker service ls"
    fi
    
else
    print_error "PostgreSQL service not found"
    print_info "Re-run the installation script to create the service"
fi

echo
echo -e "${CYAN}${BOLD}POSTGRESQL FIX UTILITY COMPLETE${NC}"
echo "=================================="

print_info "Next steps:"
echo "1. If PostgreSQL is now running (1/1), continue with the installation"
echo "2. If still failing, run: ./diagnose-postgres.sh for detailed analysis"
echo "3. Check service status: docker service ls"
echo "4. Monitor logs: docker service logs db_postgres"
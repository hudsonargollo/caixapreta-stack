#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - POSTGRESQL DIAGNOSTIC TOOL
# Comprehensive diagnosis for PostgreSQL deployment failures
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
echo -e "${BLUE}${BOLD}"
cat << "EOF"
██████╗  ██████╗ ███████╗████████╗ ██████╗ ██████╗ ███████╗███████╗ ██████╗ ██╗     
██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝██╔════╝ ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║     
██████╔╝██║   ██║███████╗   ██║   ██║  ███╗██████╔╝█████╗  ███████╗██║   ██║██║     
██╔═══╝ ██║   ██║╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║██║▄▄ ██║██║     
██║     ╚██████╔╝███████║   ██║   ╚██████╔╝██║  ██║███████╗███████║╚██████╔╝███████╗
╚═╝      ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝ ╚══▀▀═╝ ╚══════╝
                                                                                     
██████╗ ██╗ █████╗  ██████╗ ███╗   ██╗ ██████╗ ███████╗████████╗██╗ ██████╗
██╔══██╗██║██╔══██╗██╔════╝ ████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██║██╔════╝
██║  ██║██║███████║██║  ███╗██╔██╗ ██║██║   ██║███████╗   ██║   ██║██║     
██║  ██║██║██╔══██║██║   ██║██║╚██╗██║██║   ██║╚════██║   ██║   ██║██║     
██████╔╝██║██║  ██║╚██████╔╝██║ ╚████║╚██████╔╝███████║   ██║   ██║╚██████╗
╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝ ╚═════╝
EOF
echo -e "${NC}"

print_header "POSTGRESQL DEPLOYMENT DIAGNOSTIC"

# 1. Check PostgreSQL Service Status
print_info "Step 1: Checking PostgreSQL Service Status"
echo

if docker service ls | grep -q "db_postgres"; then
    POSTGRES_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_postgres" | awk '{print $2}')
    print_info "PostgreSQL service status: $POSTGRES_STATUS"
    
    if [[ "$POSTGRES_STATUS" == "0/1" ]]; then
        print_error "PostgreSQL is failing to start (0/1 replicas)"
    elif [[ "$POSTGRES_STATUS" == "1/1" ]]; then
        print_success "PostgreSQL service is running"
    else
        print_warning "PostgreSQL status unclear: $POSTGRES_STATUS"
    fi
else
    print_error "PostgreSQL service not found"
    exit 1
fi

# 2. Get Detailed Service Information
print_info "Step 2: Detailed PostgreSQL Service Analysis"
echo

print_info "Service tasks and their states:"
docker service ps db_postgres --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}\t{{.Error}}"

echo
print_info "Recent PostgreSQL service logs:"
docker service logs --tail 30 db_postgres 2>/dev/null || print_warning "Could not fetch service logs"

# 3. Check PostgreSQL Container Status
print_info "Step 3: Container-Level Analysis"
echo

POSTGRES_CONTAINER=$(docker ps -q -f name=db_postgres 2>/dev/null)
if [ -n "$POSTGRES_CONTAINER" ]; then
    print_success "PostgreSQL container found: $POSTGRES_CONTAINER"
    
    print_info "Container status:"
    docker ps -f name=db_postgres --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo
    print_info "Container logs (last 20 lines):"
    docker logs --tail 20 "$POSTGRES_CONTAINER" 2>/dev/null || print_warning "Could not fetch container logs"
    
    # Test PostgreSQL readiness
    echo
    print_info "Testing PostgreSQL readiness:"
    if docker exec "$POSTGRES_CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then
        print_success "PostgreSQL is ready for connections"
    else
        print_error "PostgreSQL is not ready for connections"
    fi
    
    # Test database connection
    print_info "Testing database connection:"
    if docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "SELECT version();" >/dev/null 2>&1; then
        print_success "Database connection successful"
        
        # Show database info
        print_info "PostgreSQL version:"
        docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "SELECT version();" 2>/dev/null | head -3
        
        print_info "Existing databases:"
        docker exec "$POSTGRES_CONTAINER" psql -U postgres -c "\l" 2>/dev/null | grep -E "(Name|main_db|evolution_db|template)"
    else
        print_error "Database connection failed"
    fi
    
else
    print_error "No PostgreSQL container found"
fi

# 4. Check Data Directory and Permissions
print_info "Step 4: Data Directory Analysis"
echo

if [ -d "/data/postgres" ]; then
    print_success "PostgreSQL data directory exists"
    
    # Check permissions
    POSTGRES_PERMS=$(stat -c "%a %U:%G" /data/postgres 2>/dev/null)
    print_info "Data directory permissions: $POSTGRES_PERMS"
    
    # Check directory size
    POSTGRES_SIZE=$(du -sh /data/postgres 2>/dev/null | awk '{print $1}')
    print_info "Data directory size: $POSTGRES_SIZE"
    
    # Check if directory has content
    POSTGRES_FILES=$(ls -la /data/postgres 2>/dev/null | wc -l)
    if [ "$POSTGRES_FILES" -gt 3 ]; then
        print_success "Data directory has content ($((POSTGRES_FILES-2)) items)"
    else
        print_warning "Data directory appears empty"
    fi
else
    print_error "PostgreSQL data directory missing: /data/postgres"
    print_fix "Run: mkdir -p /data/postgres && chown -R 999:999 /data/postgres"
fi

# 5. Check Network Connectivity
print_info "Step 5: Network Connectivity Analysis"
echo

if docker network ls | grep -q "internal-net"; then
    print_success "internal-net network exists"
    
    # Check if PostgreSQL is connected to the network
    NETWORK_INFO=$(docker network inspect internal-net --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null)
    if echo "$NETWORK_INFO" | grep -q "postgres"; then
        print_success "PostgreSQL is connected to internal-net"
    else
        print_warning "PostgreSQL may not be connected to internal-net"
    fi
else
    print_error "internal-net network missing"
fi

# 6. System Resources Check
print_info "Step 6: System Resources Analysis"
echo

# Check memory
MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.0f", $2}')
MEMORY_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
MEMORY_PERCENT=$(( MEMORY_USED * 100 / MEMORY_TOTAL ))

print_info "Memory usage: ${MEMORY_USED}MB / ${MEMORY_TOTAL}MB (${MEMORY_PERCENT}%)"

if [ "$MEMORY_PERCENT" -gt 90 ]; then
    print_error "High memory usage may be causing PostgreSQL failures"
elif [ "$MEMORY_PERCENT" -gt 80 ]; then
    print_warning "Memory usage is high"
else
    print_success "Memory usage is acceptable"
fi

# Check disk space
DISK_USAGE=$(df /data 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")
print_info "Disk usage (/data): ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 90 ]; then
    print_error "Low disk space may be causing PostgreSQL issues"
elif [ "$DISK_USAGE" -gt 80 ]; then
    print_warning "Disk space is getting low"
else
    print_success "Disk space is sufficient"
fi

# 7. PostgreSQL Configuration Analysis
print_info "Step 7: PostgreSQL Configuration Analysis"
echo

if [ -n "$POSTGRES_CONTAINER" ]; then
    print_info "PostgreSQL environment variables:"
    docker exec "$POSTGRES_CONTAINER" env | grep -E "(POSTGRES|PGDATA)" 2>/dev/null || print_warning "Could not fetch environment variables"
    
    echo
    print_info "PostgreSQL configuration:"
    docker exec "$POSTGRES_CONTAINER" cat /var/lib/postgresql/data/postgresql.conf 2>/dev/null | grep -E "(max_connections|shared_buffers|effective_cache_size)" || print_warning "Could not fetch configuration"
fi

# 8. Check for Common Issues
print_info "Step 8: Common Issues Analysis"
echo

# Check for port conflicts
if netstat -tlnp 2>/dev/null | grep -q ":5432 "; then
    PROCESS_5432=$(netstat -tlnp 2>/dev/null | grep ":5432 " | head -1)
    print_warning "Port 5432 is occupied: $PROCESS_5432"
    
    # Check if it's a system PostgreSQL
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        print_error "System PostgreSQL is running and may conflict"
        print_fix "Run: systemctl stop postgresql && systemctl disable postgresql"
    fi
else
    print_success "Port 5432 is available"
fi

# Check for Docker Swarm issues
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)
if [ "$SWARM_STATUS" = "active" ]; then
    print_success "Docker Swarm is active"
else
    print_error "Docker Swarm is not active: $SWARM_STATUS"
fi

# 9. Recommended Fixes
print_info "Step 9: Recommended Fixes"
echo

print_header "RECOMMENDED ACTIONS"

echo -e "${PURPLE}${BOLD}Immediate Fixes:${NC}"
echo

print_fix "1. Stop conflicting PostgreSQL services:"
echo "   systemctl stop postgresql"
echo "   systemctl disable postgresql"
echo

print_fix "2. Fix data directory permissions:"
echo "   mkdir -p /data/postgres"
echo "   chown -R 999:999 /data/postgres"
echo "   chmod 755 /data/postgres"
echo

print_fix "3. Restart PostgreSQL service:"
echo "   docker service update --force db_postgres"
echo

print_fix "4. If still failing, recreate the service:"
echo "   docker service rm db_postgres"
echo "   # Wait 10 seconds, then re-run the installation script"
echo

print_fix "5. Check system resources:"
echo "   free -h  # Check memory"
echo "   df -h    # Check disk space"
echo

print_fix "6. For persistent issues, try PostgreSQL 14:"
echo "   # Edit the deployment script to use postgres:14-alpine instead of postgres:15-alpine"
echo

print_header "DIAGNOSTIC COMPLETE"
print_info "Run the recommended fixes above and then restart the deployment"
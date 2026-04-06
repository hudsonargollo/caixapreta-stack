#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - COMPREHENSIVE DIAGNOSTIC TOOL
# Complete analysis of all services and infrastructure
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Language-specific messages
msg() {
    local key="$1"
    case "$key" in
        "welcome_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "DIAGNOSTICO COMPLETO - CAIXA PRETA STACK"
            else
                echo "COMPREHENSIVE DIAGNOSTIC - CAIXA PRETA STACK"
            fi
            ;;
        "analyzing_all")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Analisando todos os servicos da stack..."
            else
                echo "Analyzing all stack services..."
            fi
            ;;
        "system_overview")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Visao Geral do Sistema"
            else
                echo "System Overview"
            fi
            ;;
        "docker_status")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Status do Docker e Swarm"
            else
                echo "Docker and Swarm Status"
            fi
            ;;
        "network_analysis")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Analise de Redes"
            else
                echo "Network Analysis"
            fi
            ;;
        "services_status")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Status dos Servicos"
            else
                echo "Services Status"
            fi
            ;;
        "database_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Camada de Banco de Dados"
            else
                echo "Database Layer"
            fi
            ;;
        "core_services")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos Principais"
            else
                echo "Core Services"
            fi
            ;;
        "automation_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Camada de Automacao"
            else
                echo "Automation Layer"
            fi
            ;;
        "monitoring_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Camada de Monitoramento"
            else
                echo "Monitoring Layer"
            fi
            ;;
        "resource_usage")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Uso de Recursos"
            else
                echo "Resource Usage"
            fi
            ;;
        "recommendations")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "RECOMENDACOES"
            else
                echo "RECOMMENDATIONS"
            fi
            ;;
        *)
            echo "$key"
            ;;
    esac
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

print_section() {
    echo -e "${PURPLE}${BOLD}🔍 ${1}${NC}"
    echo "=================================================================="
}

print_subsection() {
    echo -e "${CYAN}${BOLD}📋 ${1}${NC}"
    echo "------------------------------------------------------------------"
}

check_service_status() {
    local service_name="$1"
    local expected_replicas="$2"
    
    if docker service ls --format "{{.Name}}" | grep -q "^${service_name}$"; then
        local status=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "^${service_name} " | awk '{print $2}')
        if [ "$status" = "$expected_replicas" ]; then
            print_success "$service_name: $status (Running)"
            return 0
        else
            print_error "$service_name: $status (Failed)"
            return 1
        fi
    else
        print_warning "$service_name: Service not found"
        return 1
    fi
}

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
 ██████╗ █████╗ ██╗██╗  ██╗ █████╗ ██████╗ ██████╗ ███████╗████████╗ █████╗ 
██╔════╝██╔══██╗██║╚██╗██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
██║     ███████║██║ ╚███╔╝ ███████║██████╔╝██████╔╝█████╗     ██║   ███████║
██║     ██╔══██║██║ ██╔██╗ ██╔══██║██╔═══╝ ██╔══██╗██╔══╝     ██║   ██╔══██║
╚██████╗██║  ██║██║██╔╝ ██╗██║  ██║██║     ██║  ██║███████╗   ██║   ██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
                                                                              
██████╗ ██╗ █████╗  ██████╗ ███╗   ██╗ ██████╗ ███████╗████████╗██╗ ██████╗ 
██╔══██╗██║██╔══██╗██╔════╝ ████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██║██╔════╝ 
██║  ██║██║███████║██║  ███╗██╔██╗ ██║██║   ██║███████╗   ██║   ██║██║      
██║  ██║██║██╔══██║██║   ██║██║╚██╗██║██║   ██║╚════██║   ██║   ██║██║      
██████╔╝██║██║  ██║╚██████╔╝██║ ╚████║╚██████╔╝███████║   ██║   ██║╚██████╗ 
╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝ ╚═════╝ 
EOF
echo -e "${NC}"

# Language Selection
echo -e "${WHITE}${BOLD}Welcome! / Bem-vindos!${NC}"
echo
echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│                    LANGUAGE SELECTION                       │${NC}"
echo -e "${CYAN}${BOLD}│                 SELECAO DE IDIOMA                           │${NC}"
echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo
echo -e "${GREEN}${BOLD}[1]${NC} ${GREEN}🇺🇸 English${NC}"
echo -e "${GREEN}${BOLD}[2]${NC} ${GREEN}🇧🇷 Português${NC}"
echo
echo -ne "${GREEN}${BOLD}language@caixapreta:~$ ${NC}"
read LANGUAGE_CHOICE

# Set language
if [ "$LANGUAGE_CHOICE" = "2" ]; then
    LANG_MODE="pt"
else
    LANG_MODE="en"
fi

echo
echo -e "${CYAN}${BOLD}$(msg "welcome_title")${NC}"
echo "=================================================================="
echo

print_info "$(msg "analyzing_all")"
echo

# 1. System Overview
print_section "$(msg "system_overview")"

print_info "System Information:"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Kernel: $(uname -r)"
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"

echo
print_info "Resource Summary:"
MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.0f", $2}')
MEMORY_USED=$(free -m | awk 'NR==2{printf "%.0f", $3}')
MEMORY_PERCENT=$(( MEMORY_USED * 100 / MEMORY_TOTAL ))
DISK_USAGE=$(df / 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")

echo "Memory: ${MEMORY_USED}MB / ${MEMORY_TOTAL}MB (${MEMORY_PERCENT}%)"
echo "Disk: ${DISK_USAGE}% used"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"

echo

# 2. Docker and Swarm Status
print_section "$(msg "docker_status")"

if command -v docker >/dev/null 2>&1; then
    print_success "Docker is installed"
    
    if docker info >/dev/null 2>&1; then
        print_success "Docker daemon is running"
        
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
        print_info "Docker version: $DOCKER_VERSION"
        
        # Swarm status
        SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)
        if [ "$SWARM_STATUS" = "active" ]; then
            print_success "Docker Swarm is active"
            
            SWARM_ROLE=$(docker info --format '{{.Swarm.ControlAvailable}}' 2>/dev/null)
            if [ "$SWARM_ROLE" = "true" ]; then
                print_info "Node role: Manager"
            else
                print_info "Node role: Worker"
            fi
        else
            print_error "Docker Swarm is not active: $SWARM_STATUS"
        fi
    else
        print_error "Docker daemon is not accessible"
    fi
else
    print_error "Docker is not installed"
fi

echo

# 3. Network Analysis
print_section "$(msg "network_analysis")"

print_info "Docker Networks:"
if docker network ls >/dev/null 2>&1; then
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
    
    echo
    print_info "Checking critical networks:"
    
    if docker network ls | grep -q "internal-net.*overlay"; then
        print_success "internal-net (overlay) - OK"
    elif docker network ls | grep -q "internal-net"; then
        print_warning "internal-net exists but not overlay type"
    else
        print_error "internal-net network missing"
    fi
    
    if docker network ls | grep -q "traefik-public.*overlay"; then
        print_success "traefik-public (overlay) - OK"
    elif docker network ls | grep -q "traefik-public"; then
        print_warning "traefik-public exists but not overlay type"
    else
        print_error "traefik-public network missing"
    fi
else
    print_error "Cannot access Docker networks"
fi

echo

# 4. Services Status Overview
print_section "$(msg "services_status")"

if docker service ls >/dev/null 2>&1; then
    print_info "All Docker Services:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"
    
    echo
    print_info "Service Health Summary:"
    
    TOTAL_SERVICES=$(docker service ls --format "{{.Name}}" | wc -l)
    HEALTHY_SERVICES=$(docker service ls --format "{{.Replicas}}" | grep -c "/1$" || echo "0")
    FAILED_SERVICES=$(docker service ls --format "{{.Replicas}}" | grep -c "0/" || echo "0")
    
    print_info "Total services: $TOTAL_SERVICES"
    print_success "Healthy services: $HEALTHY_SERVICES"
    if [ "$FAILED_SERVICES" -gt 0 ]; then
        print_error "Failed services: $FAILED_SERVICES"
    else
        print_success "Failed services: 0"
    fi
else
    print_error "Cannot access Docker services"
fi

echo

# 5. Database Layer Analysis
print_section "$(msg "database_layer")"

print_subsection "PostgreSQL"
check_service_status "db_postgres" "1/1"

if docker service ls | grep -q "db_postgres"; then
    print_info "PostgreSQL logs (last 5 lines):"
    docker service logs --tail 5 db_postgres 2>/dev/null || print_warning "Could not fetch logs"
    
    # Test PostgreSQL connectivity
    POSTGRES_CONTAINER=$(docker ps -q -f name=db_postgres 2>/dev/null | head -1)
    if [ -n "$POSTGRES_CONTAINER" ]; then
        if docker exec "$POSTGRES_CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then
            print_success "PostgreSQL is ready for connections"
        else
            print_error "PostgreSQL is not ready"
        fi
    fi
fi

echo
print_subsection "Redis Services"
check_service_status "db_redis-n8n" "1/1"
check_service_status "db_redis-mega" "1/1"

# Test Redis connectivity
for redis_service in "db_redis-n8n" "db_redis-mega"; do
    if docker service ls | grep -q "$redis_service"; then
        REDIS_TEST=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h "$redis_service" ping 2>/dev/null || echo "FAILED")
        if [ "$REDIS_TEST" = "PONG" ]; then
            print_success "$redis_service: Connection successful"
        else
            print_error "$redis_service: Connection failed"
        fi
    fi
done

echo

# 6. Core Services Analysis
print_section "$(msg "core_services")"

print_subsection "Traefik (Proxy & SSL)"
check_service_status "core_traefik" "1/1"

print_subsection "Portainer (Management)"
check_service_status "core_portainer" "1/1"

print_subsection "MinIO (Storage)"
check_service_status "storage_minio" "1/1"

echo

# 7. Automation Layer Analysis
print_section "$(msg "automation_layer")"

print_subsection "n8n Services"
check_service_status "automation_n8n" "1/1"
check_service_status "automation_n8n-worker" "2/2"

print_subsection "MEGA (Chatwoot)"
check_service_status "communication_mega" "1/1"
check_service_status "communication_mega-worker" "1/1"

print_subsection "Evolution API"
check_service_status "communication_evolution" "1/1"

echo

# 8. Monitoring Layer Analysis
print_section "$(msg "monitoring_layer")"

print_subsection "Grafana"
check_service_status "monitoring_grafana" "1/1"

print_subsection "Prometheus"
check_service_status "monitoring_prometheus" "1/1"

echo

# 9. Resource Usage Analysis
print_section "$(msg "resource_usage")"

print_info "Memory Usage by Service:"
if docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null; then
    echo "Resource usage displayed above"
else
    print_warning "Could not fetch container resource usage"
fi

echo
print_info "Disk Usage:"
df -h | grep -E "(Filesystem|/dev/)"

echo
print_info "Docker System Usage:"
docker system df 2>/dev/null || print_warning "Could not get Docker system info"

echo

# 10. Data Directories Check
print_section "Data Directories"

print_info "Checking data directories:"
for dir in "/data/postgres" "/data/redis_n8n" "/data/redis_mega" "/data/minio" "/data/grafana"; do
    if [ -d "$dir" ]; then
        SIZE=$(du -sh "$dir" 2>/dev/null | cut -f1)
        PERMS=$(ls -ld "$dir" 2>/dev/null | awk '{print $1 " " $3 ":" $4}')
        print_success "$dir - Size: $SIZE, Permissions: $PERMS"
    else
        print_warning "$dir - Directory does not exist"
    fi
done

echo

# 11. Recommendations
print_section "$(msg "recommendations")"

ISSUES_FOUND=0
CRITICAL_ISSUES=0

# Check for critical issues
if [ "$MEMORY_PERCENT" -gt 90 ]; then
    print_error "CRITICAL: Memory usage is very high (${MEMORY_PERCENT}%)"
    echo "  • Consider upgrading server RAM"
    echo "  • Check for memory leaks in applications"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
elif [ "$MEMORY_PERCENT" -gt 80 ]; then
    print_warning "Memory usage is high (${MEMORY_PERCENT}%)"
    echo "  • Monitor memory usage closely"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ "$DISK_USAGE" -gt 90 ]; then
    print_error "CRITICAL: Disk usage is very high (${DISK_USAGE}%)"
    echo "  • Clean up old Docker images: docker system prune -a"
    echo "  • Consider expanding disk space"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
elif [ "$DISK_USAGE" -gt 80 ]; then
    print_warning "Disk usage is high (${DISK_USAGE}%)"
    echo "  • Monitor disk usage closely"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ "$SWARM_STATUS" != "active" ]; then
    print_error "CRITICAL: Docker Swarm is not active"
    echo "  • Initialize swarm: docker swarm init"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_error "Services are failing ($FAILED_SERVICES failed)"
    echo "  • Run specific diagnostic scripts for failed services"
    echo "  • Check service logs: docker service logs [service_name]"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Network issues
if ! docker network ls | grep -q "internal-net.*overlay"; then
    print_error "internal-net network issue"
    echo "  • Run: ./fix-network-conflict.sh"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo
if [ $CRITICAL_ISSUES -eq 0 ] && [ $ISSUES_FOUND -eq 0 ]; then
    print_success "No critical issues found! Stack appears healthy."
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Todos os servicos estao funcionando corretamente"
        echo "  • Continue monitorando via Grafana"
        echo "  • Mantenha backups regulares"
    else
        echo "  • All services are working correctly"
        echo "  • Continue monitoring via Grafana"
        echo "  • Maintain regular backups"
    fi
elif [ $CRITICAL_ISSUES -gt 0 ]; then
    print_error "$CRITICAL_ISSUES critical issues found that need immediate attention!"
    echo "  • Address critical issues first"
    echo "  • Run: sudo ./fix-and-redeploy.sh for comprehensive fix"
else
    print_warning "$ISSUES_FOUND issues found that should be addressed"
    echo "  • Monitor the warnings above"
    echo "  • Run specific diagnostic scripts for detailed analysis"
fi

echo
if [ "$LANG_MODE" = "pt" ]; then
    print_info "Diagnostico completo concluido!"
    echo "Para problemas especificos, execute os scripts de diagnostico individuais:"
    echo "  • ./diagnose-redis.sh (problemas Redis)"
    echo "  • ./diagnose-postgres.sh (problemas PostgreSQL)"
    echo "  • ./diagnose-mega.sh (problemas MEGA)"
    echo "  • ./diagnose-traefik.sh (problemas SSL/Proxy)"
else
    print_info "Comprehensive diagnostic completed!"
    echo "For specific issues, run individual diagnostic scripts:"
    echo "  • ./diagnose-redis.sh (Redis issues)"
    echo "  • ./diagnose-postgres.sh (PostgreSQL issues)"
    echo "  • ./diagnose-mega.sh (MEGA issues)"
    echo "  • ./diagnose-traefik.sh (SSL/Proxy issues)"
fi
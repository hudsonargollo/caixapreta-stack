#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - REDIS DIAGNOSTIC TOOL
# Comprehensive Redis services analysis and troubleshooting
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
                echo "DIAGNOSTICO REDIS - CAIXA PRETA STACK"
            else
                echo "REDIS DIAGNOSTIC - CAIXA PRETA STACK"
            fi
            ;;
        "analyzing_redis")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Analisando servicos Redis..."
            else
                echo "Analyzing Redis services..."
            fi
            ;;
        "redis_services_status")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Status dos Servicos Redis:"
            else
                echo "Redis Services Status:"
            fi
            ;;
        "checking_containers")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando containers Redis..."
            else
                echo "Checking Redis containers..."
            fi
            ;;
        "redis_containers")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Containers Redis:"
            else
                echo "Redis Containers:"
            fi
            ;;
        "checking_logs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando logs dos servicos Redis..."
            else
                echo "Checking Redis service logs..."
            fi
            ;;
        "redis_connectivity")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Testando conectividade Redis..."
            else
                echo "Testing Redis connectivity..."
            fi
            ;;
        "data_directories")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando diretorios de dados Redis..."
            else
                echo "Checking Redis data directories..."
            fi
            ;;
        "network_analysis")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Analisando conectividade de rede..."
            else
                echo "Analyzing network connectivity..."
            fi
            ;;
        "resource_usage")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando uso de recursos..."
            else
                echo "Checking resource usage..."
            fi
            ;;
        "recommendations")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "RECOMENDACOES"
            else
                echo "RECOMMENDATIONS"
            fi
            ;;
        "language_selection")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "SELECAO DE IDIOMA"
            else
                echo "LANGUAGE SELECTION"
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
}

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
██████╗ ███████╗██████╗ ██╗███████╗    ██████╗ ██╗ █████╗  ██████╗ 
██╔══██╗██╔════╝██╔══██╗██║██╔════╝    ██╔══██╗██║██╔══██╗██╔════╝ 
██████╔╝█████╗  ██║  ██║██║███████╗    ██║  ██║██║███████║██║  ███╗
██╔══██╗██╔══╝  ██║  ██║██║╚════██║    ██║  ██║██║██╔══██║██║   ██║
██║  ██║███████╗██████╔╝██║███████║    ██████╔╝██║██║  ██║╚██████╔╝
╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝    ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ 
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

print_info "$(msg "analyzing_redis")"
echo

# 1. Check Redis services status
print_section "$(msg "redis_services_status")"
echo

if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        # Check if services exist
        REDIS_N8N_EXISTS=$(docker service ls --format "{{.Name}}" | grep "^db_redis-n8n$" || echo "")
        REDIS_MEGA_EXISTS=$(docker service ls --format "{{.Name}}" | grep "^db_redis-mega$" || echo "")
        
        if [ -n "$REDIS_N8N_EXISTS" ]; then
            REDIS_N8N_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_redis-n8n" | awk '{print $2}')
            if [ "$REDIS_N8N_STATUS" = "1/1" ]; then
                print_success "db_redis-n8n: $REDIS_N8N_STATUS (Running)"
            else
                print_error "db_redis-n8n: $REDIS_N8N_STATUS (Failed)"
            fi
        else
            print_warning "db_redis-n8n: Service not found"
        fi
        
        if [ -n "$REDIS_MEGA_EXISTS" ]; then
            REDIS_MEGA_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_redis-mega" | awk '{print $2}')
            if [ "$REDIS_MEGA_STATUS" = "1/1" ]; then
                print_success "db_redis-mega: $REDIS_MEGA_STATUS (Running)"
            else
                print_error "db_redis-mega: $REDIS_MEGA_STATUS (Failed)"
            fi
        else
            print_warning "db_redis-mega: Service not found"
        fi
        
        echo
        print_info "All Redis services:"
        docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep -E "(NAME|redis)" || echo "No Redis services found"
    else
        print_error "Docker daemon not accessible"
        exit 1
    fi
else
    print_error "Docker not installed"
    exit 1
fi

echo

# 2. Check Redis containers
print_section "$(msg "checking_containers")"
echo

REDIS_CONTAINERS=$(docker ps -a --format "{{.Names}} {{.Status}} {{.Image}}" | grep redis || echo "")
if [ -n "$REDIS_CONTAINERS" ]; then
    print_info "$(msg "redis_containers")"
    echo "$REDIS_CONTAINERS" | while read line; do
        if echo "$line" | grep -q "Up"; then
            print_success "$line"
        else
            print_error "$line"
        fi
    done
else
    print_warning "No Redis containers found"
fi

echo

# 3. Check Redis service logs
print_section "$(msg "checking_logs")"
echo

if [ -n "$REDIS_N8N_EXISTS" ]; then
    print_info "db_redis-n8n logs (last 10 lines):"
    echo "----------------------------------------"
    docker service logs --tail 10 db_redis-n8n 2>/dev/null || print_warning "Could not retrieve db_redis-n8n logs"
    echo
fi

if [ -n "$REDIS_MEGA_EXISTS" ]; then
    print_info "db_redis-mega logs (last 10 lines):"
    echo "----------------------------------------"
    docker service logs --tail 10 db_redis-mega 2>/dev/null || print_warning "Could not retrieve db_redis-mega logs"
    echo
fi

# 4. Check data directories
print_section "$(msg "data_directories")"
echo

print_info "Redis data directories:"
for dir in "/data/redis_n8n" "/data/redis_mega"; do
    if [ -d "$dir" ]; then
        SIZE=$(du -sh "$dir" 2>/dev/null | cut -f1)
        PERMS=$(ls -ld "$dir" 2>/dev/null | awk '{print $1 " " $3 ":" $4}')
        print_success "$dir - Size: $SIZE, Permissions: $PERMS"
    else
        print_warning "$dir - Directory does not exist"
    fi
done

echo

# 5. Test Redis connectivity
print_section "$(msg "redis_connectivity")"
echo

# Test Redis n8n connectivity
if [ -n "$REDIS_N8N_EXISTS" ] && [ "$REDIS_N8N_STATUS" = "1/1" ]; then
    print_info "Testing db_redis-n8n connectivity..."
    REDIS_N8N_TEST=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h db_redis-n8n ping 2>/dev/null || echo "FAILED")
    if [ "$REDIS_N8N_TEST" = "PONG" ]; then
        print_success "db_redis-n8n: Connection successful (PONG)"
    else
        print_error "db_redis-n8n: Connection failed ($REDIS_N8N_TEST)"
    fi
else
    print_warning "db_redis-n8n: Service not running, skipping connectivity test"
fi

# Test Redis mega connectivity
if [ -n "$REDIS_MEGA_EXISTS" ] && [ "$REDIS_MEGA_STATUS" = "1/1" ]; then
    print_info "Testing db_redis-mega connectivity..."
    REDIS_MEGA_TEST=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h db_redis-mega ping 2>/dev/null || echo "FAILED")
    if [ "$REDIS_MEGA_TEST" = "PONG" ]; then
        print_success "db_redis-mega: Connection successful (PONG)"
    else
        print_error "db_redis-mega: Connection failed ($REDIS_MEGA_TEST)"
    fi
else
    print_warning "db_redis-mega: Service not running, skipping connectivity test"
fi

echo

# 6. Network analysis
print_section "$(msg "network_analysis")"
echo

print_info "Checking internal-net network:"
if docker network ls | grep -q "internal-net"; then
    print_success "internal-net network exists"
    
    # Check if Redis services are connected to the network
    NETWORK_CONTAINERS=$(docker network inspect internal-net --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null || echo "")
    if echo "$NETWORK_CONTAINERS" | grep -q "redis"; then
        print_success "Redis containers connected to internal-net"
        print_info "Connected containers: $NETWORK_CONTAINERS"
    else
        print_warning "No Redis containers found in internal-net"
        print_info "Connected containers: $NETWORK_CONTAINERS"
    fi
else
    print_error "internal-net network not found"
fi

echo

# 7. Resource usage
print_section "$(msg "resource_usage")"
echo

print_info "System memory usage:"
free -h

echo
print_info "Docker system info:"
docker system df 2>/dev/null || print_warning "Could not get Docker system info"

echo

# 8. Recommendations
print_section "$(msg "recommendations")"
echo

ISSUES_FOUND=0

if [ -z "$REDIS_N8N_EXISTS" ] || [ "$REDIS_N8N_STATUS" != "1/1" ]; then
    print_error "Issue: db_redis-n8n service not running properly"
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Execute: ./fix-redis-deployment.sh"
        echo "  • Ou reinicie o servico: docker service update --force db_redis-n8n"
    else
        echo "  • Run: ./fix-redis-deployment.sh"
        echo "  • Or restart service: docker service update --force db_redis-n8n"
    fi
    ISSUES_FOUND=1
fi

if [ -z "$REDIS_MEGA_EXISTS" ] || [ "$REDIS_MEGA_STATUS" != "1/1" ]; then
    print_error "Issue: db_redis-mega service not running properly"
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Execute: ./fix-redis-deployment.sh"
        echo "  • Ou reinicie o servico: docker service update --force db_redis-mega"
    else
        echo "  • Run: ./fix-redis-deployment.sh"
        echo "  • Or restart service: docker service update --force db_redis-mega"
    fi
    ISSUES_FOUND=1
fi

if ! docker network ls | grep -q "internal-net"; then
    print_error "Issue: internal-net network missing"
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Execute: ./fix-network-conflict.sh"
    else
        echo "  • Run: ./fix-network-conflict.sh"
    fi
    ISSUES_FOUND=1
fi

if [ ! -d "/data/redis_n8n" ] || [ ! -d "/data/redis_mega" ]; then
    print_error "Issue: Redis data directories missing"
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Crie os diretorios: mkdir -p /data/redis_n8n /data/redis_mega"
        echo "  • Defina permissoes: chmod 755 /data/redis_n8n /data/redis_mega"
    else
        echo "  • Create directories: mkdir -p /data/redis_n8n /data/redis_mega"
        echo "  • Set permissions: chmod 755 /data/redis_n8n /data/redis_mega"
    fi
    ISSUES_FOUND=1
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    print_success "No critical issues found with Redis services"
    if [ "$LANG_MODE" = "pt" ]; then
        echo "  • Todos os servicos Redis estao funcionando corretamente"
        echo "  • Se ainda houver problemas, verifique os logs dos servicos"
    else
        echo "  • All Redis services are working correctly"
        echo "  • If issues persist, check service logs for details"
    fi
fi

echo
if [ "$LANG_MODE" = "pt" ]; then
    print_info "Diagnostico Redis concluido!"
    echo "Para corrigir problemas encontrados, execute: ./fix-redis-deployment.sh"
else
    print_info "Redis diagnostic completed!"
    echo "To fix found issues, run: ./fix-redis-deployment.sh"
fi
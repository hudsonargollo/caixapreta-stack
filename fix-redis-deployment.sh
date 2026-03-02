#!/bin/bash

# ==============================================================================
# INFRA CAIXA PRETA v2 - REDIS DEPLOYMENT FIX
# Fix Redis services deployment issues
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
                echo "CORRECAO IMPLANTACAO REDIS"
            else
                echo "REDIS DEPLOYMENT FIX"
            fi
            ;;
        "fixing_redis")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Corrigindo problemas de implantacao Redis..."
            else
                echo "Fixing Redis deployment issues..."
            fi
            ;;
        "checking_status")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando status atual dos servicos Redis..."
            else
                echo "Checking current Redis services status..."
            fi
            ;;
        "stopping_services")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Parando servicos Redis existentes..."
            else
                echo "Stopping existing Redis services..."
            fi
            ;;
        "preparing_directories")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Preparando diretorios de dados..."
            else
                echo "Preparing data directories..."
            fi
            ;;
        "creating_redis_stack")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Criando nova configuracao Redis..."
            else
                echo "Creating new Redis configuration..."
            fi
            ;;
        "deploying_redis")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando servicos Redis..."
            else
                echo "Deploying Redis services..."
            fi
            ;;
        "verifying_deployment")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando implantacao..."
            else
                echo "Verifying deployment..."
            fi
            ;;
        "testing_connectivity")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Testando conectividade Redis..."
            else
                echo "Testing Redis connectivity..."
            fi
            ;;
        "fix_complete")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CORRECAO REDIS CONCLUIDA"
            else
                echo "REDIS FIX COMPLETE"
            fi
            ;;
        "redis_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos Redis estao agora funcionando corretamente!"
            else
                echo "Redis services are now working correctly!"
            fi
            ;;
        "next_steps")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Proximos passos:"
            else
                echo "Next steps:"
            fi
            ;;
        "continue_installation")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "1. Continue com a instalacao principal: sudo ./caixapreta-stack.sh"
            else
                echo "1. Continue with main installation: sudo ./caixapreta-stack.sh"
            fi
            ;;
        "monitor_services")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "2. Monitore os servicos: docker service ls"
            else
                echo "2. Monitor services: docker service ls"
            fi
            ;;
        "check_logs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "3. Verifique logs se necessario: docker service logs db_redis-n8n"
            else
                echo "3. Check logs if needed: docker service logs db_redis-n8n"
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

print_fix() {
    echo -e "${PURPLE}🔧 ${1}${NC}"
}

verify_service() {
    local service_name="$1"
    local expected_replicas="$2"
    local max_attempts=30
    local attempt=1
    
    print_info "Verifying service: $service_name (expecting $expected_replicas replicas)"
    
    while [ $attempt -le $max_attempts ]; do
        local current_replicas=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "^$service_name " | awk '{print $2}' || echo "0/0")
        
        if [ "$current_replicas" = "$expected_replicas" ]; then
            print_success "Service $service_name is ready ($current_replicas)"
            return 0
        fi
        
        print_info "Attempt $attempt/$max_attempts: $service_name is $current_replicas, waiting..."
        sleep 3
        ((attempt++))
    done
    
    print_error "Service $service_name failed to reach expected state $expected_replicas"
    return 1
}

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
██████╗ ███████╗██████╗ ██╗███████╗    ███████╗██╗██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██║██╔════╝    ██╔════╝██║╚██╗██╔╝
██████╔╝█████╗  ██║  ██║██║███████╗    █████╗  ██║ ╚███╔╝ 
██╔══██╗██╔══╝  ██║  ██║██║╚════██║    ██╔══╝  ██║ ██╔██╗ 
██║  ██║███████╗██████╔╝██║███████║    ██║     ██║██╔╝ ██╗
╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝
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
echo "=================================="
echo

print_info "$(msg "fixing_redis")"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Root access required. Please run as root or with sudo."
    exit 1
fi

# 1. Check current status
print_fix "Step 1: $(msg "checking_status")"

if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker not installed"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon not accessible"
    exit 1
fi

# Check existing Redis services
REDIS_N8N_EXISTS=$(docker service ls --format "{{.Name}}" | grep "^db_redis-n8n$" || echo "")
REDIS_MEGA_EXISTS=$(docker service ls --format "{{.Name}}" | grep "^db_redis-mega$" || echo "")

if [ -n "$REDIS_N8N_EXISTS" ]; then
    REDIS_N8N_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_redis-n8n" | awk '{print $2}')
    print_info "db_redis-n8n: $REDIS_N8N_STATUS"
else
    print_warning "db_redis-n8n: Service not found"
fi

if [ -n "$REDIS_MEGA_EXISTS" ]; then
    REDIS_MEGA_STATUS=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_redis-mega" | awk '{print $2}')
    print_info "db_redis-mega: $REDIS_MEGA_STATUS"
else
    print_warning "db_redis-mega: Service not found"
fi

echo

# 2. Stop existing Redis services
print_fix "Step 2: $(msg "stopping_services")"

if [ -n "$REDIS_N8N_EXISTS" ]; then
    print_info "Stopping db_redis-n8n..."
    docker service rm db_redis-n8n 2>/dev/null || true
fi

if [ -n "$REDIS_MEGA_EXISTS" ]; then
    print_info "Stopping db_redis-mega..."
    docker service rm db_redis-mega 2>/dev/null || true
fi

# Wait for services to fully stop
print_info "Waiting for services to stop..."
sleep 10

print_success "Redis services stopped"

# 3. Prepare data directories
print_fix "Step 3: $(msg "preparing_directories")"

print_info "Creating Redis data directories..."
mkdir -p /data/redis_n8n /data/redis_mega

print_info "Setting directory permissions..."
chmod 755 /data/redis_n8n /data/redis_mega
chown -R root:root /data/redis_n8n /data/redis_mega

print_success "Data directories prepared"

# 4. Ensure network exists
print_fix "Step 4: Checking internal-net network..."

if ! docker network ls | grep -q "internal-net.*overlay"; then
    print_warning "internal-net network missing or incorrect type"
    print_info "Creating internal-net network..."
    docker network create --driver overlay --attachable --subnet=10.0.2.0/24 internal-net 2>/dev/null || true
fi

if docker network ls | grep -q "internal-net.*overlay"; then
    print_success "internal-net network ready"
else
    print_error "Failed to create internal-net network"
    exit 1
fi

# 5. Create Redis stack configuration
print_fix "Step 5: $(msg "creating_redis_stack")"

cat <<EOF > /tmp/redis-stack.yml
version: '3.8'
services:
  redis-n8n:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru --save 60 1000
    volumes:
      - /data/redis_n8n:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 30s
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 5
        window: 60s
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  redis-mega:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru --save 60 1000
    volumes:
      - /data/redis_mega:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 30s
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 5
        window: 60s
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

networks:
  internal-net:
    external: true
EOF

print_success "Redis stack configuration created"

# 6. Deploy Redis services
print_fix "Step 6: $(msg "deploying_redis")"

print_info "Deploying Redis services..."
docker stack deploy -c /tmp/redis-stack.yml db

print_success "Redis services deployed"

# 7. Verify deployment
print_fix "Step 7: $(msg "verifying_deployment")"

# Verify services
verify_service "db_redis-n8n" "1/1"
verify_service "db_redis-mega" "1/1"

# 8. Test connectivity
print_fix "Step 8: $(msg "testing_connectivity")"

# Wait a bit for services to be fully ready
sleep 10

# Test Redis n8n connectivity
print_info "Testing db_redis-n8n connectivity..."
REDIS_N8N_TEST=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h db_redis-n8n ping 2>/dev/null || echo "FAILED")
if [ "$REDIS_N8N_TEST" = "PONG" ]; then
    print_success "db_redis-n8n: Connection successful (PONG)"
else
    print_warning "db_redis-n8n: Connection test failed, but service may still be starting"
fi

# Test Redis mega connectivity
print_info "Testing db_redis-mega connectivity..."
REDIS_MEGA_TEST=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h db_redis-mega ping 2>/dev/null || echo "FAILED")
if [ "$REDIS_MEGA_TEST" = "PONG" ]; then
    print_success "db_redis-mega: Connection successful (PONG)"
else
    print_warning "db_redis-mega: Connection test failed, but service may still be starting"
fi

# Cleanup
rm -f /tmp/redis-stack.yml

echo
echo -e "${CYAN}${BOLD}$(msg "fix_complete")${NC}"
echo "=================================="

print_success "$(msg "redis_ready")"
echo

print_info "$(msg "next_steps")"
echo "$(msg "continue_installation")"
echo "$(msg "monitor_services")"
echo "$(msg "check_logs")"

echo
print_info "Current Redis services status:"
docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep -E "(NAME|redis)" || echo "No Redis services found"
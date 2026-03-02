#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK v2.0
# Enhanced Docker Swarm deployment with robust error handling
# Author: Hudson Argollo
# System: Debian/Ubuntu
# Stack: n8n + MEGA (Chatwoot V4) + Evolution API + Traefik + Monitoring
# ==============================================================================

set -e

# Set UTF-8 locale for proper character handling
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Terminal Colors & Effects
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Terminal Effects
BOLD='\033[1m'
DIM='\033[2m'

# Enhanced logging functions
log_info() {
    echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$1${NC}"
}

log_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} ${GREEN}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} ${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$1${NC}"
}

log_step() {
    echo -e "${PURPLE}${BOLD}>>> ${NC}${PURPLE}$1${NC}"
}

# Progress indicator
show_progress() {
    local message="$1"
    local duration="${2:-3}"
    
    echo -ne "${BLUE}${message}${NC}"
    for i in $(seq 1 $duration); do
        echo -ne "${BLUE}.${NC}"
        sleep 1
    done
    echo -e " ${GREEN}✓${NC}"
}

# Enhanced error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Script failed at line $line_number with exit code $exit_code"
    log_error "Last command: $BASH_COMMAND"
    exit $exit_code
}

trap 'handle_error $LINENO' ERR

# Verification functions
verify_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 command not found"
        return 1
    fi
    return 0
}

verify_service() {
    local service_name="$1"
    local expected_replicas="$2"
    local max_attempts=30
    local attempt=1
    
    log_info "Verifying service: $service_name (expecting $expected_replicas replicas)"
    
    while [ $attempt -le $max_attempts ]; do
        local current_replicas=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "^$service_name " | awk '{print $2}' || echo "0/0")
        
        if [ "$current_replicas" = "$expected_replicas" ]; then
            log_success "Service $service_name is ready ($current_replicas)"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: $service_name is $current_replicas, waiting..."
        sleep 5
        ((attempt++))
    done
    
    log_error "Service $service_name failed to reach expected state $expected_replicas"
    return 1
}

verify_port_binding() {
    local port="$1"
    local max_attempts=12
    local attempt=1
    
    log_info "Verifying port $port is bound..."
    
    while [ $attempt -le $max_attempts ]; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            log_success "Port $port is bound"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: Port $port not bound yet, waiting..."
        sleep 5
        ((attempt++))
    done
    
    log_error "Port $port failed to bind after $max_attempts attempts"
    return 1
}
# Language-specific messages
msg() {
    local key="$1"
    case "$key" in
        "welcome_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "BEM-VINDOS AO CAIXA PRETA STACK v2.0"
            else
                echo "WELCOME TO CAIXA PRETA STACK v2.0"
            fi
            ;;
        "enhanced_version")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Versao aprimorada com correcoes robustas"
            else
                echo "Enhanced version with robust fixes"
            fi
            ;;
        "root_check")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando privilegios do sistema..."
            else
                echo "Checking system privileges..."
            fi
            ;;
        "root_error")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Acesso root necessario. Execute como root ou com sudo."
            else
                echo "Root access required. Please run as root or with sudo."
            fi
            ;;
        "root_confirmed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Privilegios root confirmados"
            else
                echo "Root privileges confirmed"
            fi
            ;;
        "config_setup")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CONFIGURACAO DO SISTEMA"
            else
                echo "CONFIGURATION SETUP"
            fi
            ;;
        "domain_config")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CONFIGURACAO DE DOMINIO"
            else
                echo "DOMAIN CONFIGURATION"
            fi
            ;;
        "enter_domain")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Digite seu dominio (ex: meudominio.com): "
            else
                echo "Enter your domain (e.g., mydomain.com): "
            fi
            ;;
        "enter_email")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Digite seu email para SSL: "
            else
                echo "Enter your email for SSL: "
            fi
            ;;
        "config_accepted")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Configuracao aceita"
            else
                echo "Configuration accepted"
            fi
            ;;
        "system_prep")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "PREPARACAO DO SISTEMA"
            else
                echo "SYSTEM PREPARATION"
            fi
            ;;
        "updating_system")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Atualizando pacotes do sistema..."
            else
                echo "Updating system packages..."
            fi
            ;;
        "installing_deps")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Instalando dependencias..."
            else
                echo "Installing dependencies..."
            fi
            ;;
        "setup_dirs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Configurando diretorios de dados..."
            else
                echo "Setting up data directories..."
            fi
            ;;
        "system_prep_complete")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Preparacao do sistema concluida"
            else
                echo "System preparation completed"
            fi
            ;;
        "docker_installing")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Instalando e configurando Docker..."
            else
                echo "Installing and configuring Docker..."
            fi
            ;;
        "docker_already_installed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker ja instalado"
            else
                echo "Docker already installed"
            fi
            ;;
        "docker_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker daemon esta pronto"
            else
                echo "Docker daemon is ready"
            fi
            ;;
        "swarm_initializing")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Inicializando Docker Swarm..."
            else
                echo "Initializing Docker Swarm..."
            fi
            ;;
        "swarm_active")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker Swarm ja ativo"
            else
                echo "Docker Swarm already active"
            fi
            ;;
        "detecting_ip")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Detectando enderecos IP do servidor..."
            else
                echo "Detecting server IP addresses..."
            fi
            ;;
        "using_ipv4")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Usando IPv4:"
            else
                echo "Using IPv4:"
            fi
            ;;
        "using_ipv6")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Usando IPv6:"
            else
                echo "Using IPv6:"
            fi
            ;;
        "swarm_initialized")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker Swarm inicializado com IP:"
            else
                echo "Docker Swarm initialized with IP:"
            fi
            ;;
        "creating_networks")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Criando redes Docker com verificacao..."
            else
                echo "Creating Docker networks with verification..."
            fi
            ;;
        "networks_created")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Redes criadas com sucesso"
            else
                echo "Networks created successfully"
            fi
            ;;
        "deploying_traefik")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando Traefik com vinculacao de porta aprimorada..."
            else
                echo "Deploying Traefik with enhanced port binding..."
            fi
            ;;
        "traefik_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Traefik implantado com sucesso com vinculacao de porta verificada"
            else
                echo "Traefik deployed successfully with verified port binding"
            fi
            ;;
        "deploying_databases")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando servicos de banco de dados com verificacoes de saude..."
            else
                echo "Deploying database services with health checks..."
            fi
            ;;
        "databases_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos de banco de dados implantados e verificados"
            else
                echo "Database services deployed and verified"
            fi
            ;;
        "initializing_databases")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Inicializando bancos de dados da aplicacao..."
            else
                echo "Initializing application databases..."
            fi
            ;;
        "databases_initialized")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Inicializacao do banco de dados concluida"
            else
                echo "Database initialization completed"
            fi
            ;;
        "deploying_apps")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando servicos de aplicacao..."
            else
                echo "Deploying application services..."
            fi
            ;;
        "apps_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos de automacao implantados com sucesso"
            else
                echo "Automation services deployed successfully"
            fi
            ;;
        "deploying_mega")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando MEGA (Chatwoot) e servicos adicionais..."
            else
                echo "Deploying MEGA (Chatwoot) and additional services..."
            fi
            ;;
        "mega_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "MEGA e servicos adicionais implantados com sucesso"
            else
                echo "MEGA and additional services deployed successfully"
            fi
            ;;
        "final_verification")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "VERIFICACAO FINAL DO SISTEMA"
            else
                echo "FINAL SYSTEM VERIFICATION"
            fi
            ;;
        "deployment_success")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantacao aprimorada concluida com sucesso!"
            else
                echo "Enhanced deployment completed successfully!"
            fi
            ;;
        "access_endpoints")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "PONTOS DE ACESSO"
            else
                echo "ACCESS ENDPOINTS"
            fi
            ;;
        "important_notes")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "NOTAS IMPORTANTES"
            else
                echo "IMPORTANT NOTES"
            fi
            ;;
        "dns_config_required")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Configuracao DNS Necessaria:"
            else
                echo "DNS Configuration Required:"
            fi
            ;;
        "dns_instructions")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Crie registros AAAA para todos os subdominios apontando para o IPv6 do servidor"
            else
                echo "Create AAAA records for all subdomains pointing to your server IPv6"
            fi
            ;;
        "ssl_certificates")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Certificados SSL:"
            else
                echo "SSL Certificates:"
            fi
            ;;
        "ssl_auto_generate")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Certificados Let's Encrypt serao gerados automaticamente (5-15 minutos)"
            else
                echo "Let's Encrypt certificates will generate automatically (5-15 minutes)"
            fi
            ;;
        "monitor_progress")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Monitorar progresso: docker service logs core_traefik"
            else
                echo "Monitor progress: docker service logs core_traefik"
            fi
            ;;
        "default_credentials")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Credenciais Padrao:"
            else
                echo "Default Credentials:"
            fi
            ;;
        "password_info")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Todos os servicos usam senha: caixapretastack2626"
            else
                echo "All services use password: caixapretastack2626"
            fi
            ;;
        "change_passwords")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Altere as senhas apos o primeiro login para seguranca"
            else
                echo "Change passwords after first login for security"
            fi
            ;;
        "deployment_complete")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantacao concluida! Seu CaixaPreta Stack esta pronto!"
            else
                echo "Deployment completed! Your CaixaPreta Stack is ready!"
            fi
            ;;
        "waiting_postgresql")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Aguardando PostgreSQL ficar pronto para conexoes..."
            else
                echo "Waiting for PostgreSQL to be ready for connections..."
            fi
            ;;
        "postgresql_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "PostgreSQL esta pronto para conexoes"
            else
                echo "PostgreSQL is ready for connections"
            fi
            ;;
        *)
            echo "$key"
            ;;
    esac
}

# Network cleanup and creation with verification
create_networks() {
    log_step "$(msg "creating_networks")"
    
    # Remove existing networks if they exist
    docker network rm traefik-public internal-net 2>/dev/null || true
    sleep 2
    
    # Create networks with explicit configuration
    log_info "Creating traefik-public network..."
    docker network create \
        --driver overlay \
        --attachable \
        --subnet=10.0.1.0/24 \
        traefik-public
    
    log_info "Creating internal-net network..."
    docker network create \
        --driver overlay \
        --attachable \
        --subnet=10.0.2.0/24 \
        internal-net
    
    # Verify networks exist
    if docker network ls | grep -q "traefik-public" && docker network ls | grep -q "internal-net"; then
        log_success "$(msg "networks_created")"
    else
        log_error "Failed to create networks"
        exit 1
    fi
}

# Enhanced Docker installation with verification
install_docker() {
    log_step "$(msg "docker_installing")"
    
    if ! verify_command docker; then
        log_info "Installing Docker Engine..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        # Start and enable Docker
        systemctl start docker
        systemctl enable docker
        
        # Wait for Docker to be ready
        sleep 10
    else
        log_success "$(msg "docker_already_installed")"
    fi
    
    # Verify Docker is working
    if ! docker --version >/dev/null 2>&1; then
        log_error "Docker installation failed"
        exit 1
    fi
    
    # Test Docker daemon
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker info >/dev/null 2>&1; then
            log_success "$(msg "docker_ready")"
            break
        fi
        
        log_info "Attempt $attempt/$max_attempts: Waiting for Docker daemon..."
        sleep 2
        ((attempt++))
        
        if [ $attempt -gt $max_attempts ]; then
            log_error "Docker daemon failed to start"
            exit 1
        fi
    done
    
    # Fix Docker socket permissions
    chmod 666 /var/run/docker.sock 2>/dev/null || true
}

# Enhanced Swarm initialization with better IP detection
initialize_swarm() {
    log_step "$(msg "swarm_initializing")"
    
    if docker info | grep -q "Swarm: active"; then
        log_success "$(msg "swarm_active")"
        return 0
    fi
    
    # Enhanced IP detection with fallbacks
    log_info "$(msg "detecting_ip")"
    
    # Try multiple methods to get IP
    PUBLIC_IPV4=$(timeout 10 curl -s -4 ifconfig.me 2>/dev/null || \
                  timeout 10 curl -s -4 ipinfo.io/ip 2>/dev/null || \
                  timeout 10 curl -s -4 icanhazip.com 2>/dev/null || echo "")
    
    PUBLIC_IPV6=$(timeout 10 curl -s -6 ifconfig.me 2>/dev/null || \
                  timeout 10 curl -s -6 ipinfo.io/ip 2>/dev/null || echo "")
    
    LOCAL_IPV6=$(ip -6 addr show | grep 'inet6.*global' | head -1 | awk '{print $2}' | cut -d'/' -f1 2>/dev/null || echo "")
    
    # Determine best IP to use
    ADVERTISE_ADDR=""
    
    if [ -n "$PUBLIC_IPV4" ] && [[ "$PUBLIC_IPV4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        ADVERTISE_ADDR="$PUBLIC_IPV4"
        log_info "$(msg "using_ipv4") $PUBLIC_IPV4"
    elif [ -n "$LOCAL_IPV6" ]; then
        ADVERTISE_ADDR="[$LOCAL_IPV6]"
        log_info "$(msg "using_ipv6") $LOCAL_IPV6"
    else
        log_warning "Could not detect IP, using default configuration"
    fi
    
    # Initialize Swarm with retries
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Swarm initialization attempt $attempt/$max_attempts..."
        
        if [ -n "$ADVERTISE_ADDR" ]; then
            if docker swarm init --advertise-addr "$ADVERTISE_ADDR" >/dev/null 2>&1; then
                log_success "$(msg "swarm_initialized") $ADVERTISE_ADDR"
                return 0
            fi
        else
            if docker swarm init >/dev/null 2>&1; then
                log_success "$(msg "swarm_initialized") default settings"
                return 0
            fi
        fi
        
        log_warning "Swarm initialization attempt $attempt failed"
        ((attempt++))
        sleep 5
    done
    
    log_error "Failed to initialize Docker Swarm after $max_attempts attempts"
    exit 1
}
# Enhanced Traefik deployment with robust port binding
deploy_traefik() {
    local domain="$1"
    local email="$2"
    
    log_step "$(msg "deploying_traefik")"
    
    # Create Traefik configuration
    cat <<EOF > /data/traefik/traefik.yml
api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true
  websecure:
    address: :443

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    swarmMode: true
    exposedByDefault: false
    network: traefik-public
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: $email
      storage: acme.json
      httpChallenge:
        entryPoint: web
      caServer: https://acme-v02.api.letsencrypt.org/directory

log:
  level: INFO
  format: common

accessLog: {}
EOF

    # Deploy Traefik with explicit host mode port binding
    cat <<EOF > /tmp/traefik-stack.yml
version: '3.8'
services:
  traefik:
    image: traefik:v2.10
    command:
      - "--configfile=/etc/traefik/traefik.yml"
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
      - target: 443
        published: 443
        protocol: tcp
        mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /data/traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - /data/traefik/acme.json:/etc/traefik/acme.json
    networks:
      - traefik-public
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
        window: 60s
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.traefik.rule=Host(\`traefik.$domain\`)"
        - "traefik.http.routers.traefik.service=api@internal"
        - "traefik.http.routers.traefik.entrypoints=websecure"
        - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
        - "traefik.http.services.traefik.loadbalancer.server.port=8080"

  portainer:
    image: portainer/portainer-ce:latest
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /data/portainer:/data
    networks:
      - traefik-public
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.portainer.rule=Host(\`portainer.$domain\`)"
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik-public:
    external: true
EOF

    # Deploy the stack
    docker stack deploy -c /tmp/traefik-stack.yml core
    
    # Verify Traefik deployment
    verify_service "core_traefik" "1/1"
    verify_service "core_portainer" "1/1"
    
    # Verify port binding with retries
    verify_port_binding "80"
    verify_port_binding "443"
    
    # Test basic connectivity
    log_info "Testing Traefik connectivity..."
    sleep 10
    
    local test_url="http://localhost"
    local response=$(timeout 10 curl -s -o /dev/null -w "%{http_code}" "$test_url" 2>/dev/null || echo "000")
    
    if [ "$response" = "301" ] || [ "$response" = "302" ] || [ "$response" = "404" ]; then
        log_success "Traefik is responding (HTTP $response)"
    else
        log_warning "Traefik response: HTTP $response"
    fi
    
    # Cleanup
    rm -f /tmp/traefik-stack.yml
    
    log_success "$(msg "traefik_deployed")"
    
    log_success "Traefik deployed successfully with verified port binding"
}

# Enhanced database deployment with health checks
deploy_databases() {
    log_step "$(msg "deploying_databases")"
    
    cat <<EOF > /tmp/database-stack.yml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: caixapretastack2626
      POSTGRES_DB: main_db
      POSTGRES_USER: postgres
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d main_db"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  redis-n8n:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - /data/redis_n8n:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          memory: 256M

  redis-mega:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - /data/redis_mega:/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          memory: 256M

networks:
  internal-net:
    external: true
EOF

    docker stack deploy -c /tmp/database-stack.yml db
    
    # Verify database services
    verify_service "db_postgres" "1/1"
    verify_service "db_redis-n8n" "1/1"
    verify_service "db_redis-mega" "1/1"
    
    # Wait for PostgreSQL to be fully ready
    log_info "$(msg "waiting_postgresql")"
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec $(docker ps -q -f name=db_postgres) pg_isready -U postgres >/dev/null 2>&1; then
            log_success "$(msg "postgresql_ready")"
            break
        fi
        
        log_info "Attempt $attempt/$max_attempts: Waiting for PostgreSQL..."
        sleep 5
        ((attempt++))
        
        if [ $attempt -gt $max_attempts ]; then
            log_error "PostgreSQL failed to become ready"
            exit 1
        fi
    done
    
    rm -f /tmp/database-stack.yml
    log_success "$(msg "databases_deployed")"
}
# Initialize databases with proper error handling
initialize_databases() {
    log_step "$(msg "initializing_databases")"
    
    # Wait a bit more for PostgreSQL to be fully stable
    sleep 15
    
    # Create Evolution API database
    log_info "Creating Evolution API database..."
    docker run --rm --network internal-net \
        -e PGPASSWORD=caixapretastack2626 \
        postgres:15-alpine \
        psql -h db_postgres -U postgres -c "CREATE DATABASE evolution_db;" 2>/dev/null || \
        log_info "Evolution database already exists"
    
    # Initialize Chatwoot database
    log_info "Initializing Chatwoot database schema..."
    docker run --rm --network internal-net \
        -e DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db \
        -e RAILS_ENV=production \
        -e PGPASSWORD=caixapretastack2626 \
        sendingtk/chatwoot:v4.11.2 \
        bundle exec rails db:chatwoot_prepare >/dev/null 2>&1 || \
        log_info "Chatwoot database already initialized"
    
    log_success "$(msg "databases_initialized")"
}

# Deploy applications with enhanced configuration
deploy_applications() {
    local domain="$1"
    
    log_step "$(msg "deploying_apps")"
    
    cat <<EOF > /tmp/apps-stack.yml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_HOST=n8n.$domain
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://n8n.$domain/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - N8N_ENCRYPTION_KEY=caixapretastack2626
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=db_redis-n8n
      - N8N_METRICS=true
    volumes:
      - /data/n8n:/home/node/.n8n
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      resources:
        limits:
          memory: 512M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.n8n.rule=Host(\`n8n.$domain\`)"
        - "traefik.http.routers.n8n.entrypoints=websecure"
        - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
        - "traefik.http.services.n8n.loadbalancer.server.port=5678"

  n8n-worker:
    image: n8nio/n8n:latest
    command: worker
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - QUEUE_BULL_REDIS_HOST=db_redis-n8n
      - N8N_ENCRYPTION_KEY=caixapretastack2626
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      replicas: 2
      resources:
        limits:
          memory: 256M

  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evolution.$domain
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/evolution_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - WEBHOOK_GLOBAL_URL=https://evolution.$domain
      - CONFIG_SESSION_SECRET=caixapretastack2626
      - QRCODE_LIMIT=30
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
      - LOG_LEVEL=ERROR
      - LOG_COLOR=false
    volumes:
      - /data/evolution:/evolution/instances
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/manager/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 20s
        max_attempts: 5
      resources:
        limits:
          memory: 512M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.evolution.rule=Host(\`evolution.$domain\`)"
        - "traefik.http.routers.evolution.entrypoints=websecure"
        - "traefik.http.routers.evolution.tls.certresolver=letsencrypt"
        - "traefik.http.services.evolution.loadbalancer.server.port=8080"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

    docker stack deploy -c /tmp/apps-stack.yml automation
    
    # Verify automation services
    verify_service "automation_n8n" "1/1"
    verify_service "automation_evolution" "1/1"
    verify_service "automation_n8n-worker" "2/2"
    
    rm -f /tmp/apps-stack.yml
    log_success "$(msg "apps_deployed")"
}
# Deploy MEGA and additional services
deploy_mega_services() {
    local domain="$1"
    
    log_step "$(msg "deploying_mega")"
    
    cat <<EOF > /tmp/mega-stack.yml
version: '3.8'
services:
  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - FRONTEND_URL=https://mega.$domain
      - FORCE_SSL=true
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true
      - INSTALLATION_ENV=docker
      - MAILER_SENDER_EMAIL=noreply@$domain
      - SMTP_DOMAIN=$domain
    volumes:
      - /data/mega/storage:/app/storage
      - /data/mega/public:/app/public
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 60s
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 30s
        max_attempts: 5
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.mega.rule=Host(\`mega.$domain\`)"
        - "traefik.http.routers.mega.entrypoints=websecure"
        - "traefik.http.routers.mega.tls.certresolver=letsencrypt"
        - "traefik.http.services.mega.loadbalancer.server.port=3000"

  mega-sidekiq:
    image: sendingtk/chatwoot:v4.11.2
    command: bundle exec sidekiq -c 5 -q default -q mailers -q medium -q low -q realtime -q push_notifications -q webhooks -q presence -q analytics
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - INSTALLATION_ENV=docker
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep sidekiq | grep -v grep || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 20s
        max_attempts: 5
      resources:
        limits:
          memory: 512M

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001" --address ":9000"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
      - MINIO_SERVER_URL=https://s3.$domain
      - MINIO_BROWSER_REDIRECT_URL=https://minio.$domain
    volumes:
      - /data/minio:/data
    networks:
      - traefik-public
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      resources:
        limits:
          memory: 512M
      labels:
        - "traefik.enable=true"
        # S3 API endpoint
        - "traefik.http.routers.minio-api.rule=Host(\`s3.$domain\`)"
        - "traefik.http.routers.minio-api.entrypoints=websecure"
        - "traefik.http.routers.minio-api.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-api.service=minio-api"
        - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
        # Console endpoint
        - "traefik.http.routers.minio-console.rule=Host(\`minio.$domain\`)"
        - "traefik.http.routers.minio-console.entrypoints=websecure"
        - "traefik.http.routers.minio-console.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-console.service=minio-console"
        - "traefik.http.services.minio-console.loadbalancer.server.port=9001"

  grafana:
    image: grafana/grafana:latest
    user: "472:472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://grafana.$domain
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
      resources:
        limits:
          memory: 256M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana.rule=Host(\`grafana.$domain\`)"
        - "traefik.http.routers.grafana.entrypoints=websecure"
        - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
        - "traefik.http.services.grafana.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

    docker stack deploy -c /tmp/mega-stack.yml apps
    
    # Verify services with more patience for MEGA
    verify_service "apps_minio" "1/1"
    verify_service "apps_grafana" "1/1"
    
    # MEGA services may take longer to start
    log_info "Waiting for MEGA services (may take up to 3 minutes)..."
    sleep 60
    
    verify_service "apps_mega-rails" "1/1"
    verify_service "apps_mega-sidekiq" "1/1"
    
    rm -f /tmp/mega-stack.yml
    log_success "$(msg "mega_deployed")"
}
# Main execution flow
main() {
    # Clear screen and show banner
    clear
    
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
 ██████╗ █████╗ ██╗██╗  ██╗ █████╗     ██████╗ ██████╗ ███████╗████████╗ █████╗ 
██╔════╝██╔══██╗██║╚██╗██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
██║     ███████║██║ ╚███╔╝ ███████║    ██████╔╝██████╔╝█████╗     ██║   ███████║
██║     ██╔══██║██║ ██╔██╗ ██╔══██║    ██╔═══╝ ██╔══██╗██╔══╝     ██║   ██╔══██║
╚██████╗██║  ██║██║██╔╝ ██╗██║  ██║    ██║     ██║  ██║███████╗   ██║   ██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
                                                                                  
███████╗████████╗ █████╗  ██████╗██╗  ██╗    ██╗   ██╗██████╗     ██████╗ 
██╔════╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝    ██║   ██║╚════██╗   ██╔═████╗
███████╗   ██║   ███████║██║     █████╔╝     ██║   ██║ █████╔╝   ██║██╔██║
╚════██║   ██║   ██╔══██║██║     ██╔═██╗     ╚██╗ ██╔╝██╔═══╝    ████╔╝██║
███████║   ██║   ██║  ██║╚██████╗██║  ██╗     ╚████╔╝ ███████╗██╗╚██████╔╝
╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝      ╚═══╝  ╚══════╝╚═╝ ╚═════╝ 
EOF
    echo -e "${NC}"
    
    echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                    ENHANCED AUTOMATED DEPLOYMENT SYSTEM v2.0${NC}"
    echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Language Selection with enhanced visuals
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
    
    # Set language and show initialization
    if [ "$LANGUAGE_CHOICE" = "2" ]; then
        LANG_MODE="pt"
        echo
        log_step "$(msg "welcome_title")"
        log_info "$(msg "enhanced_version")"
    else
        LANG_MODE="en"
        echo
        log_step "$(msg "welcome_title")"
        log_info "$(msg "enhanced_version")"
    fi
    
    # Root check
    log_info "$(msg "root_check")"
    if [ "$EUID" -ne 0 ]; then 
        log_error "$(msg "root_error")"
        exit 1
    fi
    log_success "$(msg "root_confirmed")"
    
    # Configuration
    echo
    log_step "$(msg "config_setup")"
    echo
    echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}│                    $(msg "domain_config")                     │${NC}"
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    echo -ne "${GREEN}${BOLD}$(msg "enter_domain")${NC}"
    read DOMAIN
    
    echo -ne "${GREEN}${BOLD}$(msg "enter_email")${NC}"
    read EMAIL
    
    if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
        log_error "Domain and email are required"
        exit 1
    fi
    
    log_success "$(msg "config_accepted")"
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    
    # System preparation
    echo
    log_step "$(msg "system_prep")"
    
    # Update system
    log_info "$(msg "updating_system")"
    apt update >/dev/null 2>&1 && apt upgrade -y >/dev/null 2>&1
    
    # Install dependencies
    log_info "$(msg "installing_deps")"
    apt install -y curl wget git jq ufw unzip net-tools >/dev/null 2>&1
    
    # Setup data directories with proper permissions
    log_info "$(msg "setup_dirs")"
    mkdir -p /data/{traefik,portainer,n8n,redis_n8n,redis_mega,postgres,minio,mega,evolution,grafana}
    
    # Set specific permissions
    chown -R 472:472 /data/grafana
    chown -R 1001:1001 /data/minio
    chown -R 1000:1000 /data/{n8n,evolution}
    chmod -R 755 /data
    
    # Create and secure Traefik SSL file
    touch /data/traefik/acme.json
    chmod 600 /data/traefik/acme.json
    
    log_success "$(msg "system_prep_complete")"
    
    # Docker installation and setup
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    DOCKER SETUP                             │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    install_docker
    
    # Swarm initialization
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    SWARM CLUSTER                            │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    initialize_swarm
    
    # Network creation
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    NETWORK SETUP                            │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    create_networks
    
    # Deploy core services (Traefik + Portainer)
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    CORE SERVICES                            │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_traefik "$DOMAIN" "$EMAIL"
    
    # Deploy databases
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    DATABASE LAYER                           │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_databases
    
    # Initialize databases
    initialize_databases
    
    # Deploy automation services (n8n + Evolution)
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    AUTOMATION LAYER                         │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_applications "$DOMAIN"
    
    # Deploy MEGA and additional services
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    APPLICATION LAYER                        │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_mega_services "$DOMAIN"
    
    # Final verification
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│                    FINAL VERIFICATION                       │${NC}"
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    log_step "$(msg "final_verification")"
    
    echo
    echo "Final service status:"
    docker service ls
    
    # Check for any failed services
    FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)
    
    if [ "$FAILED_SERVICES" -gt 0 ]; then
        log_warning "Some services may still be starting up:"
        docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/" || true
        log_info "This is normal - services may take 2-5 minutes to fully start"
    else
        log_success "All services are operational!"
    fi
    
    # Success message with enhanced visuals
    echo
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    🚀 CAIXA PRETA STACK v2.0 DEPLOYED! 🚀                   ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log_success "$(msg "deployment_success")"
    echo
    
    # Access information with enhanced visuals
    echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}│                    $(msg "access_endpoints")                         │${NC}"
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    log_info "🐳 Portainer: https://portainer.$DOMAIN"
    log_info "🔄 n8n: https://n8n.$DOMAIN"
    log_info "📱 Evolution API: https://evolution.$DOMAIN"
    log_info "💬 MEGA (Chatwoot): https://mega.$DOMAIN"
    log_info "📊 Grafana: https://grafana.$DOMAIN"
    log_info "💾 MinIO Console: https://minio.$DOMAIN"
    log_info "🌐 MinIO S3 API: https://s3.$DOMAIN"
    log_info "🔧 Traefik Dashboard: https://traefik.$DOMAIN"
    
    echo
    echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}${BOLD}│                    $(msg "important_notes")                          │${NC}"
    echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    log_warning "$(msg "dns_config_required")"
    log_info "$(msg "dns_instructions")"
    
    log_warning "$(msg "ssl_certificates")"
    log_info "$(msg "ssl_auto_generate")"
    log_info "$(msg "monitor_progress")"
    
    log_warning "$(msg "default_credentials")"
    log_info "$(msg "password_info")"
    log_info "$(msg "change_passwords")"
    
    echo
    log_success "🎉 $(msg "deployment_complete")"
}

# Execute main function
main "$@"
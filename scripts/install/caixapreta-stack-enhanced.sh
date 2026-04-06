#!/bin/bash

# ==============================================================================
# INFRA CAIXA PRETA v2 - ENHANCED FRESH INSTALL
# Ultra-robust Docker Swarm deployment with comprehensive error handling
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

# Global variables
DOMAIN=""
EMAIL=""
LANG_MODE="en"
INSTALL_LOG="/tmp/caixapreta-install.log"
FAILED_SERVICES=()
RETRY_COUNT=0
MAX_RETRIES=3

# Enhanced logging functions with file logging
log_info() {
    local message="$1"
    echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $message" >> "$INSTALL_LOG"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} ${GREEN}$message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $message" >> "$INSTALL_LOG"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} ${YELLOW}$message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $message" >> "$INSTALL_LOG"
}

log_error() {
    local message="$1"
    echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $message" >> "$INSTALL_LOG"
}

log_step() {
    local message="$1"
    echo -e "${PURPLE}${BOLD}>>> ${NC}${PURPLE}$message${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [STEP] $message" >> "$INSTALL_LOG"
}
# Enhanced error handling with recovery mechanisms
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Script failed at line $line_number with exit code $exit_code"
    log_error "Last command: $BASH_COMMAND"
    
    # Save current state for recovery
    save_installation_state
    
    # Show recovery options
    show_recovery_options
    
    exit $exit_code
}

trap 'handle_error $LINENO' ERR

# Language-specific messages
msg() {
    local key="$1"
    case "$key" in
        "welcome_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "BEM-VINDOS AO INFRA CAIXA PRETA v2"
            else
                echo "WELCOME TO INFRA CAIXA PRETA v2"
            fi
            ;;
        "enhanced_version")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Sistema de infraestrutura aprimorado com verificacoes robustas"
            else
                echo "Enhanced infrastructure system with robust checks"
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
        "system_requirements")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "VERIFICACAO DE REQUISITOS DO SISTEMA"
            else
                echo "SYSTEM REQUIREMENTS CHECK"
            fi
            ;;
        "checking_memory")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando memoria disponivel..."
            else
                echo "Checking available memory..."
            fi
            ;;
        "checking_disk")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando espaco em disco..."
            else
                echo "Checking disk space..."
            fi
            ;;
        "checking_os")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando compatibilidade do sistema operacional..."
            else
                echo "Checking operating system compatibility..."
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
        "docker_installing")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Instalando e configurando Docker..."
            else
                echo "Installing and configuring Docker..."
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
        "domain_email_required")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Dominio e email sao obrigatorios"
            else
                echo "Domain and email are required"
            fi
            ;;
        "setup_dirs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Configurando diretorios de dados..."
            else
                echo "Setting up data directories..."
            fi
            ;;
        "directories_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Diretorios de dados configurados"
            else
                echo "Data directories configured"
            fi
            ;;
        "docker_verification")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "VERIFICACAO DO DOCKER"
            else
                echo "DOCKER VERIFICATION"
            fi
            ;;
        "docker_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker daemon esta pronto"
            else
                echo "Docker daemon is ready"
            fi
            ;;
        "swarm_cluster")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CLUSTER SWARM"
            else
                echo "SWARM CLUSTER"
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
        "swarm_initialized")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker Swarm inicializado com IP:"
            else
                echo "Docker Swarm initialized with IP:"
            fi
            ;;
        "network_setup")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CONFIGURACAO DE REDE"
            else
                echo "NETWORK SETUP"
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
        "core_services")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "SERVICOS PRINCIPAIS"
            else
                echo "CORE SERVICES"
            fi
            ;;
        "deploying_traefik")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando Traefik com configuracao aprimorada..."
            else
                echo "Deploying Traefik with enhanced configuration..."
            fi
            ;;
        "traefik_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Traefik implantado com sucesso"
            else
                echo "Traefik deployed successfully"
            fi
            ;;
        "database_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CAMADA DE BANCO DE DADOS"
            else
                echo "DATABASE LAYER"
            fi
            ;;
        "deploying_databases")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando servicos de banco de dados..."
            else
                echo "Deploying database services..."
            fi
            ;;
        "databases_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos de banco de dados implantados"
            else
                echo "Database services deployed"
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
        "automation_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CAMADA DE AUTOMACAO"
            else
                echo "AUTOMATION LAYER"
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
                echo "Servicos de automacao implantados"
            else
                echo "Automation services deployed"
            fi
            ;;
        "application_layer")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "CAMADA DE APLICACAO"
            else
                echo "APPLICATION LAYER"
            fi
            ;;
        "deploying_mega")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantando MEGA e servicos adicionais..."
            else
                echo "Deploying MEGA and additional services..."
            fi
            ;;
        "mega_deployed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "MEGA e servicos adicionais implantados"
            else
                echo "MEGA and additional services deployed"
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
                echo "Implantacao do Infra Caixa Preta concluida com sucesso!"
            else
                echo "Infra Caixa Preta deployment completed successfully!"
            fi
            ;;
        "deployment_complete")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Implantacao concluida! Seu Infra Caixa Preta esta pronto!"
            else
                echo "Deployment completed! Your Infra Caixa Preta is ready!"
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
        *)
            echo "$key"
            ;;
    esac
}

# Save installation state for recovery
save_installation_state() {
    cat > /tmp/caixapreta-state.json << EOF
{
    "domain": "$DOMAIN",
    "email": "$EMAIL",
    "language": "$LANG_MODE",
    "failed_services": [$(printf '"%s",' "${FAILED_SERVICES[@]}" | sed 's/,$//')]
}
EOF
}

# Show recovery options
show_recovery_options() {
    echo
    log_error "Installation failed. Recovery options:"
    echo "1. Check logs: cat $INSTALL_LOG"
    echo "2. Run diagnostics: ./diagnose-all-services.sh"
    echo "3. Clean and retry: ./wipe-vps.sh && ./caixapreta-stack-enhanced.sh"
    echo "4. Manual recovery: Use individual fix scripts"
}

# Progress indicator with timeout
show_progress() {
    local message="$1"
    local duration="${2:-3}"
    local timeout="${3:-30}"
    
    echo -ne "${BLUE}${message}${NC}"
    for i in $(seq 1 $duration); do
        echo -ne "${BLUE}.${NC}"
        sleep 1
    done
    echo -e " ${GREEN}✓${NC}"
}

# Enhanced verification functions
verify_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "$cmd command not found"
        return 1
    fi
    log_success "$cmd is available"
    return 0
}

# Enhanced service verification with health checks
verify_service() {
    local service_name="$1"
    local expected_replicas="$2"
    local max_attempts="${3:-60}"
    local attempt=1
    
    log_info "Verifying service: $service_name (expecting $expected_replicas replicas)"
    
    while [ $attempt -le $max_attempts ]; do
        local current_replicas=$(docker_safe service ls --format "{{.Name}} {{.Replicas}}" 2>/dev/null | grep "^$service_name " | awk '{print $2}' || echo "0/0")
        
        if [ "$current_replicas" = "$expected_replicas" ]; then
            log_success "Service $service_name is ready ($current_replicas)"
            
            # Additional health check
            if verify_service_health "$service_name"; then
                return 0
            else
                log_warning "Service $service_name is running but health check failed"
            fi
        fi
        
        # Show progress every 10 attempts
        if [ $((attempt % 10)) -eq 0 ]; then
            log_info "Attempt $attempt/$max_attempts: $service_name is $current_replicas, waiting..."
        fi
        
        sleep 5
        ((attempt++))
    done
    
    log_error "Service $service_name failed to reach expected state $expected_replicas"
    FAILED_SERVICES+=("$service_name")
    return 1
}

# Service health verification
verify_service_health() {
    local service_name="$1"
    
    local container_id=$(docker ps -q -f "label=com.docker.swarm.service.name=$service_name" 2>/dev/null | head -1)
    
    if [ -z "$container_id" ]; then
        return 1
    fi
    
    # Check container health status
    local health_status=$(docker_safe inspect "$container_id" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    
    if [ "$health_status" = "healthy" ] || [ "$health_status" = "none" ]; then
        return 0
    else
        log_warning "Container health status: $health_status"
        return 1
    fi
}
# Enhanced port verification
verify_port_binding() {
    local port="$1"
    local max_attempts="${2:-24}"
    local attempt=1
    
    log_info "Verifying port $port is bound"
    
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

# System requirements check
check_system_requirements() {
    log_step "Checking system requirements"
    
    # Check OS
    if ! grep -E "(Ubuntu|Debian)" /etc/os-release >/dev/null 2>&1; then
        log_error "This script requires Ubuntu or Debian"
        exit 1
    fi
    
    # Check memory
    local memory_gb=$(free -g | awk 'NR==2{print $2}')
    if [ "$memory_gb" -lt 2 ]; then
        log_warning "Low memory detected (${memory_gb}GB). Minimum 4GB recommended"
    else
        log_success "Memory check passed (${memory_gb}GB)"
    fi
    
    # Check disk space
    local disk_space=$(df / | awk 'NR==2 {print $4}')
    local disk_space_gb=$((disk_space / 1024 / 1024))
    if [ "$disk_space_gb" -lt 20 ]; then
        log_error "Insufficient disk space (${disk_space_gb}GB). Minimum 40GB required"
        exit 1
    else
        log_success "Disk space check passed (${disk_space_gb}GB available)"
    fi
    
    # Check architecture
    local arch=$(uname -m)
    if [ "$arch" != "x86_64" ]; then
        log_warning "Architecture $arch detected. x86_64 recommended"
    else
        log_success "Architecture check passed ($arch)"
    fi
}

# Clean previous installations
clean_previous_installation() {
    log_step "Cleaning previous installations"
    
    # Stop and remove existing services
    if docker service ls >/dev/null 2>&1; then
        log_info "Removing existing Docker services..."
        docker service ls --format "{{.Name}}" | xargs -r docker service rm >/dev/null 2>&1 || true
    fi
    
    # Remove existing stacks
    if docker stack ls >/dev/null 2>&1; then
        log_info "Removing existing Docker stacks..."
        docker stack ls --format "{{.Name}}" | xargs -r docker stack rm >/dev/null 2>&1 || true
    fi
    
    # Wait for cleanup
    sleep 10
    
    # Clean networks (but preserve system ones)
    log_info "Cleaning Docker networks..."
    docker network ls --format "{{.Name}}" | grep -E "(traefik-public|internal-net)" | xargs -r docker network rm >/dev/null 2>&1 || true
    
    # Stop conflicting services
    systemctl stop postgresql >/dev/null 2>&1 || true
    systemctl disable postgresql >/dev/null 2>&1 || true
    
    log_success "Previous installation cleaned"
}

# Enhanced Docker installation with verification
install_docker() {
    log_step "Installing and configuring Docker"
    
    if command -v docker >/dev/null 2>&1; then
        log_info "Docker already installed"
        local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        log_info "Docker version: $docker_version"
    else
        log_info "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh >/dev/null 2>&1
        rm get-docker.sh
        
        # Ensure Docker is in PATH for current session
        export PATH="/usr/bin:/usr/local/bin:$PATH"
        hash -r  # Refresh command hash table
        
        # Start and enable Docker
        systemctl start docker
        systemctl enable docker
        
        # Wait for Docker service to be fully ready
        sleep 5
        
        log_success "Docker installed successfully"
    fi
    
    # Verify Docker daemon with full path fallback
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        # Try both docker command and full path
        if docker info >/dev/null 2>&1 || /usr/bin/docker info >/dev/null 2>&1; then
            log_success "Docker daemon is ready"
            break
        fi
        
        log_info "Attempt $attempt/$max_attempts: Waiting for Docker daemon..."
        sleep 2
        ((attempt++))
        
        # Try to restart Docker if it's taking too long
        if [ $attempt -eq 15 ]; then
            log_warning "Restarting Docker service..."
            systemctl restart docker
            sleep 5
        fi
        
        if [ $attempt -gt $max_attempts ]; then
            log_error "Docker daemon failed to start after $max_attempts attempts"
            log_error "Please check Docker installation manually: systemctl status docker"
            exit 1
        fi
    done
    
    # Fix Docker socket permissions
    chmod 666 /var/run/docker.sock 2>/dev/null || true
    
    # Create docker command wrapper function for reliability
    if ! command -v docker >/dev/null 2>&1; then
        # If docker is not in PATH, create an alias to the full path
        alias docker='/usr/bin/docker'
        export PATH="/usr/bin:$PATH"
    fi
    
    # Create a reliable docker function that always works
    docker_safe() {
        if command -v docker >/dev/null 2>&1; then
            docker "$@"
        elif [ -x "/usr/bin/docker" ]; then
            /usr/bin/docker "$@"
        else
            log_error "Docker command not found in PATH or /usr/bin/docker"
            return 1
        fi
    }
    
    # Export the function for subshells
    export -f docker_safe
}
# Enhanced Swarm initialization with multiple IP detection methods
initialize_swarm() {
    log_step "Initializing Docker Swarm"
    
    if docker info | grep -q "Swarm: active"; then
        log_success "Docker Swarm already active"
        return 0
    fi
    
    # Enhanced IP detection with multiple fallbacks
    log_info "Detecting server IP addresses..."
    
    # Try multiple methods to get public IPv4
    local public_ipv4=""
    for service in "ifconfig.me" "ipinfo.io/ip" "icanhazip.com" "checkip.amazonaws.com"; do
        public_ipv4=$(timeout 10 curl -s -4 "$service" 2>/dev/null | tr -d '\n' || echo "")
        if [[ "$public_ipv4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            log_info "Detected public IPv4: $public_ipv4"
            break
        fi
    done
    
    # Get local IP as fallback
    local local_ipv4=$(ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null || echo "")
    
    # Determine best IP to use
    local advertise_addr=""
    if [[ "$public_ipv4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        advertise_addr="$public_ipv4"
        log_info "Using public IPv4: $public_ipv4"
    elif [[ "$local_ipv4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        advertise_addr="$local_ipv4"
        log_info "Using local IPv4: $local_ipv4"
    else
        log_warning "Could not detect IP, using default configuration"
    fi
    
    # Initialize Swarm with retries
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Swarm initialization attempt $attempt/$max_attempts..."
        
        if [ -n "$advertise_addr" ]; then
            if docker swarm init --advertise-addr "$advertise_addr" >/dev/null 2>&1; then
                log_success "Docker Swarm initialized with IP: $advertise_addr"
                return 0
            fi
        else
            if docker swarm init >/dev/null 2>&1; then
                log_success "Docker Swarm initialized with default settings"
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

# Enhanced network creation with comprehensive conflict resolution
create_networks() {
    log_step "Creating Docker networks with enhanced conflict resolution"
    
    # Function to safely create or recreate network
    create_network_safe() {
        local network_name="$1"
        local subnet="$2"
        local expected_driver="overlay"
        
        log_info "Processing network: $network_name"
        
        # Check if network exists
        if docker network ls --format "{{.Name}} {{.Driver}}" | grep -q "^$network_name "; then
            local current_driver=$(docker network ls --format "{{.Name}} {{.Driver}}" | grep "^$network_name " | awk '{print $2}')
            
            if [ "$current_driver" = "$expected_driver" ]; then
                log_info "Network $network_name already exists with correct driver ($expected_driver)"
                return 0
            else
                log_warning "Network $network_name exists but has wrong driver ($current_driver), recreating..."
                
                # Stop services that might be using the network
                docker service ls --format "{{.Name}}" | xargs -r docker service rm >/dev/null 2>&1 || true
                sleep 10
                
                # Remove the network
                docker network rm "$network_name" >/dev/null 2>&1 || true
                sleep 5
            fi
        fi
        
        # Create the network
        log_info "Creating network: $network_name"
        if docker network create --driver overlay --attachable --subnet="$subnet" "$network_name" >/dev/null 2>&1; then
            log_success "Network $network_name created successfully"
        else
            log_error "Failed to create network $network_name"
            return 1
        fi
    }
    
    # Create networks
    create_network_safe "traefik-public" "10.0.1.0/24"
    create_network_safe "internal-net" "10.0.2.0/24"
    
    # Final verification
    if docker network ls | grep -q "traefik-public.*overlay" && docker network ls | grep -q "internal-net.*overlay"; then
        log_success "All networks created successfully"
    else
        log_error "Network creation failed"
        log_info "Current networks:"
        docker network ls
        exit 1
    fi
}
# Enhanced data directory setup with proper permissions
setup_data_directories() {
    local evolution_instances="${1:-1}"
    local install_openclaw="${2:-n}"
    
    log_step "Setting up data directories with proper permissions"
    
    # Create all required directories
    local directories=(
        "/data/traefik"
        "/data/portainer"
        "/data/n8n"
        "/data/redis_n8n"
        "/data/redis_mega"
        "/data/postgres"
        "/data/minio"
        "/data/mega/storage"
        "/data/mega/public"
        "/data/evolution"
        "/data/gowa"
        "/data/painel"
        "/data/grafana"
    )
    
    # Add OpenClaw directory if requested
    if [[ "$install_openclaw" =~ ^[Yy]$ ]]; then
        directories+=("/data/openclaw")
    fi
    
    # Add directories for additional Evolution instances
    for i in $(seq 2 $evolution_instances); do
        directories+=("/data/evolution$i")
    done
    
    for dir in "${directories[@]}"; do
        if mkdir -p "$dir" 2>/dev/null; then
            log_success "Created directory: $dir"
        else
            log_error "Failed to create directory: $dir"
            exit 1
        fi
    done
    
    # Set specific ownership and permissions
    log_info "Setting directory permissions..."
    
    # Grafana (UID 472)
    chown -R 472:472 /data/grafana
    chmod -R 755 /data/grafana
    
    # MinIO (UID 1001)
    chown -R 1001:1001 /data/minio
    chmod -R 755 /data/minio
    
    # n8n, Evolution, Gowa (UID 1000)
    chown -R 1000:1000 /data/{n8n,evolution,gowa}
    chmod -R 755 /data/{n8n,evolution,gowa}
    
    # OpenClaw (UID 1000)
    if [[ "$install_openclaw" =~ ^[Yy]$ ]]; then
        chown -R 1000:1000 /data/openclaw
        chmod -R 755 /data/openclaw
    fi
    
    # Additional Evolution instances
    for i in $(seq 2 $evolution_instances); do
        chown -R 1000:1000 /data/evolution$i
        chmod -R 755 /data/evolution$i
    done
    
    # PostgreSQL (UID 999)
    chown -R 999:999 /data/postgres
    chmod 755 /data/postgres
    
    # Redis directories (root with proper permissions)
    chown -R 999:999 /data/redis_*
    chmod -R 755 /data/redis_*
    
    # MEGA directories
    chown -R 1000:1000 /data/mega
    chmod -R 755 /data/mega
    
    # Traefik SSL file
    touch /data/traefik/acme.json
    chmod 600 /data/traefik/acme.json
    chown root:root /data/traefik/acme.json
    
    # Painel (UID 1000)
    chown -R 1000:1000 /data/painel
    chmod -R 755 /data/painel
    
    # General permissions
    chmod -R 755 /data
    
    log_success "Data directories configured with proper permissions"
}

# Enhanced Traefik deployment with comprehensive configuration
deploy_traefik() {
    local domain="$1"
    local email="$2"
    
    log_step "Deploying Traefik with enhanced configuration"
    
    # Create ACME file with proper permissions
    touch /data/traefik/acme.json
    chmod 600 /data/traefik/acme.json
    
    # Deploy Traefik v3.1 with correct configuration (no config file, direct command args)
    log_info "Deploying Traefik v3.1 with Docker API compatibility..."
    
    docker service create \
      --name core_traefik \
      --constraint 'node.role==manager' \
      --publish mode=host,target=80,published=80 \
      --publish mode=host,target=443,published=443 \
      --publish mode=host,target=8080,published=8080 \
      --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
      --mount type=bind,source=/data/traefik,target=/data \
      --network traefik-public \
      --label traefik.enable=true \
      --label "traefik.http.routers.traefik.rule=Host(\`traefik.$domain\`)" \
      --label traefik.http.routers.traefik.service=api@internal \
      --label traefik.http.routers.traefik.entrypoints=websecure \
      --label traefik.http.routers.traefik.tls.certresolver=letsencrypt \
      --label traefik.http.services.traefik.loadbalancer.server.port=8080 \
      traefik:v2.11 \
      --api.dashboard=true \
      --api.insecure=false \
      --providers.docker=true \
      --providers.docker.exposedbydefault=false \
      --providers.docker.swarmmode=true \
      --entrypoints.web.address=:80 \
      --entrypoints.websecure.address=:443 \
      --certificatesresolvers.letsencrypt.acme.email=$email \
      --certificatesresolvers.letsencrypt.acme.storage=/data/acme.json \
      --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web \
      --entrypoints.web.http.redirections.entrypoint.to=websecure \
      --entrypoints.web.http.redirections.entrypoint.scheme=https \
      --log.level=INFO
    
    # Deploy Portainer
    log_info "Deploying Portainer..."
    
    docker service create \
      --name core_portainer \
      --constraint 'node.role==manager' \
      --publish mode=host,target=9000,published=9000 \
      --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
      --mount type=bind,source=/data/portainer,target=/data \
      --network traefik-public \
      --label traefik.enable=true \
      --label "traefik.http.routers.portainer.rule=Host(\`portainer.$domain\`)" \
      --label traefik.http.routers.portainer.entrypoints=websecure \
      --label traefik.http.routers.portainer.tls.certresolver=letsencrypt \
      --label traefik.http.services.portainer.loadbalancer.server.port=9000 \
      portainer/portainer-ce:latest \
      -H unix:///var/run/docker.sock
    
    # Verify deployment
    verify_service "core_traefik" "1/1" 60
    verify_service "core_portainer" "1/1" 60
    
    # Verify port binding
    verify_port_binding "80" 24
    verify_port_binding "443" 24
    
    # Test basic connectivity
    log_info "Testing Traefik connectivity..."
    sleep 15
    
    local test_response=$(timeout 10 curl -s -o /dev/null -w "%{http_code}" "http://localhost" 2>/dev/null || echo "000")
    
    if [[ "$test_response" =~ ^(301|302|404)$ ]]; then
        log_success "Traefik is responding (HTTP $test_response)"
    else
        log_warning "Traefik response: HTTP $test_response (may be normal during startup)"
    fi
    
    log_success "Traefik deployed successfully with verified port binding"
}
# Enhanced database deployment with comprehensive health checks
deploy_databases() {
    log_step "Deploying database services with enhanced health checks"
    
    # Check system resources and adjust PostgreSQL configuration
    local memory_available=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    local postgres_memory_limit="512M"
    local postgres_memory_reservation="256M"
    
    if [ "$memory_available" -lt 512 ]; then
        log_warning "Low available memory (${memory_available}MB). Using optimized PostgreSQL configuration."
        postgres_memory_limit="256M"
        postgres_memory_reservation="128M"
    else
        log_info "Sufficient memory available (${memory_available}MB). Using standard PostgreSQL configuration."
    fi
    
    # Ensure proper data directory permissions before deployment
    chown -R 999:999 /data/postgres /data/redis_* 2>/dev/null || true
    chmod 755 /data/postgres /data/redis_* 2>/dev/null || true
    
    # Create enhanced database stack
    cat > /tmp/database-stack.yml << EOF
version: '3.8'
services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_PASSWORD: caixapretastack2626
      POSTGRES_DB: main_db
      POSTGRES_USER: postgres
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
      POSTGRES_SHARED_PRELOAD_LIBRARIES: ""
      POSTGRES_MAX_CONNECTIONS: "100"
      POSTGRES_SHARED_BUFFERS: "128MB"
      POSTGRES_EFFECTIVE_CACHE_SIZE: "256MB"
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d main_db"]
      interval: 15s
      timeout: 10s
      retries: 5
      start_period: 60s
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 15s
        max_attempts: 5
        window: 120s
      resources:
        limits:
          memory: $postgres_memory_limit
        reservations:
          memory: $postgres_memory_reservation

  redis-n8n:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru --save 60 1000 --tcp-keepalive 60
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
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru --save 60 1000 --tcp-keepalive 60
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

    # Deploy database stack
    log_info "Deploying database stack..."
    docker stack deploy -c /tmp/database-stack.yml db
    
    # Verify database services with extended timeout
    verify_service "db_postgres" "1/1" 120
    verify_service "db_redis-n8n" "1/1" 60
    verify_service "db_redis-mega" "1/1" 60
    
    # Enhanced PostgreSQL readiness check
    log_info "Waiting for PostgreSQL to be fully ready for connections..."
    local max_attempts=120
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local postgres_container=$(docker ps -q -f name=db_postgres 2>/dev/null | head -1)
        
        if [ -n "$postgres_container" ]; then
            # Check if PostgreSQL is ready
            if docker exec "$postgres_container" pg_isready -U postgres >/dev/null 2>&1; then
                # Additional connection test
                if docker exec "$postgres_container" psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
                    log_success "PostgreSQL is ready and accepting connections"
                    break
                else
                    log_info "PostgreSQL ready but connection test failed, retrying..."
                fi
            fi
        else
            log_info "Waiting for PostgreSQL container to start..."
        fi
        
        # Show progress every 10 attempts
        if [ $((attempt % 10)) -eq 0 ]; then
            log_info "Attempt $attempt/$max_attempts: Waiting for PostgreSQL..."
        fi
        
        sleep 5
        ((attempt++))
        
        if [ $attempt -gt $max_attempts ]; then
            log_error "PostgreSQL failed to become ready after $max_attempts attempts"
            log_info "Run diagnostic: ./diagnose-postgres.sh"
            FAILED_SERVICES+=("db_postgres")
            return 1
        fi
    done
    
    # Test Redis connectivity
    log_info "Testing Redis connectivity..."
    for redis_service in "db_redis-n8n" "db_redis-mega"; do
        local redis_test=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h "$redis_service" ping 2>/dev/null || echo "FAILED")
        if [ "$redis_test" = "PONG" ]; then
            log_success "$redis_service: Connection successful (PONG)"
        else
            log_error "$redis_service: Connection failed ($redis_test)"
            FAILED_SERVICES+=("$redis_service")
        fi
    done
    
    # Cleanup
    rm -f /tmp/database-stack.yml
    
    log_success "Database services deployed and verified"
}
# Enhanced database initialization with comprehensive error handling
initialize_databases() {
    log_step "Initializing application databases with enhanced error handling"
    
    # Wait for PostgreSQL to be fully stable
    log_info "Allowing PostgreSQL additional stabilization time..."
    sleep 20
    
    # Create Evolution API databases with retry logic
    log_info "Creating Evolution API databases (instances: $EVOLUTION_INSTANCES)..."
    local max_attempts=5
    
    for i in $(seq 1 $EVOLUTION_INSTANCES); do
        local db_name="evolution_db_$i"
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if docker run --rm --network internal-net \
                -e PGPASSWORD=caixapretastack2626 \
                postgres:14-alpine \
                psql -h db_postgres -U postgres -c "CREATE DATABASE $db_name;" >/dev/null 2>&1; then
                log_success "Evolution database $db_name created successfully"
                break
            elif [ $attempt -eq $max_attempts ]; then
                # Check if database already exists
                if docker run --rm --network internal-net \
                    -e PGPASSWORD=caixapretastack2626 \
                    postgres:14-alpine \
                    psql -h db_postgres -U postgres -l | grep -q "$db_name"; then
                    log_info "Evolution database $db_name already exists"
                    break
                else
                    log_error "Failed to create Evolution database $db_name after $max_attempts attempts"
                    FAILED_SERVICES+=("$db_name")
                    return 1
                fi
            else
                log_info "Attempt $attempt/$max_attempts: Retrying Evolution database $db_name creation..."
                sleep 5
                ((attempt++))
            fi
        done
    done
    
    # Create Gowa WhatsApp API database with retry logic
    log_info "Creating Gowa WhatsApp API database..."
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker run --rm --network internal-net \
            -e PGPASSWORD=caixapretastack2626 \
            postgres:14-alpine \
            psql -h db_postgres -U postgres -c "CREATE DATABASE gowa_db;" >/dev/null 2>&1; then
            log_success "Gowa database created successfully"
            break
        elif [ $attempt -eq $max_attempts ]; then
            # Check if database already exists
            if docker run --rm --network internal-net \
                -e PGPASSWORD=caixapretastack2626 \
                postgres:14-alpine \
                psql -h db_postgres -U postgres -l | grep -q "gowa_db"; then
                log_info "Gowa database already exists"
                break
            else
                log_error "Failed to create Gowa database after $max_attempts attempts"
                FAILED_SERVICES+=("gowa_db")
                return 1
            fi
        else
            log_info "Attempt $attempt/$max_attempts: Retrying Gowa database creation..."
            sleep 5
            ((attempt++))
        fi
    done
    
    # Create OpenClaw database if requested
    if [[ "$INSTALL_OPENCLAW" =~ ^[Yy]$ ]]; then
        log_info "Creating OpenClaw database..."
        attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if docker run --rm --network internal-net \
                -e PGPASSWORD=caixapretastack2626 \
                postgres:14-alpine \
                psql -h db_postgres -U postgres -c "CREATE DATABASE openclaw_db;" >/dev/null 2>&1; then
                log_success "OpenClaw database created successfully"
                break
            elif [ $attempt -eq $max_attempts ]; then
                # Check if database already exists
                if docker run --rm --network internal-net \
                    -e PGPASSWORD=caixapretastack2626 \
                    postgres:14-alpine \
                    psql -h db_postgres -U postgres -l | grep -q "openclaw_db"; then
                    log_info "OpenClaw database already exists"
                    break
                else
                    log_error "Failed to create OpenClaw database after $max_attempts attempts"
                    FAILED_SERVICES+=("openclaw_db")
                    return 1
                fi
            else
                log_info "Attempt $attempt/$max_attempts: Retrying OpenClaw database creation..."
                sleep 5
                ((attempt++))
            fi
        done
    fi
    # Initialize Chatwoot database with retry logic
    log_info "Initializing Chatwoot database schema..."
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker run --rm --network internal-net \
            -e DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db \
            -e RAILS_ENV=production \
            -e PGPASSWORD=caixapretastack2626 \
            sendingtk/chatwoot:v4.11.2 \
            bundle exec rails db:chatwoot_prepare >/dev/null 2>&1; then
            log_success "Chatwoot database initialized successfully"
            break
        elif [ $attempt -eq $max_attempts ]; then
            log_warning "Chatwoot database initialization may have failed, but continuing..."
            break
        else
            log_info "Attempt $attempt/$max_attempts: Retrying Chatwoot database initialization..."
            sleep 10
            ((attempt++))
        fi
    done
    
    log_success "Database initialization completed"
}

# Enhanced application deployment with comprehensive configuration
deploy_applications() {
    local domain="$1"
    local evolution_instances="${2:-1}"
    local install_openclaw="${3:-n}"
    
    log_step "Deploying automation applications with enhanced configuration"
    
    # Create comprehensive application stack
    cat > /tmp/apps-stack.yml << 'EOFBASE'
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
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
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
      start_period: 60s
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
        reservations:
          memory: 256M
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
      - N8N_LOG_LEVEL=info
    networks:
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep n8n | grep -v grep || exit 1"]
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
      replicas: 2
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

EOFBASE

    # Generate Evolution API services dynamically
    for i in $(seq 1 $evolution_instances); do
        local db_name="evolution_db_$i"
        local service_name="evolution$i"
        local subdomain="evolution$i"
        
        if [ $i -eq 1 ]; then
            # First instance also gets the base subdomain for backward compatibility
            cat >> /tmp/apps-stack.yml << EOFEVO
  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evolution.$domain
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/$db_name
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
      - DEL_INSTANCE=false
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
      start_period: 60s
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
        reservations:
          memory: 256M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.evolution.rule=Host(\`evolution.$domain\`)"
        - "traefik.http.routers.evolution.entrypoints=websecure"
        - "traefik.http.routers.evolution.tls.certresolver=letsencrypt"
        - "traefik.http.services.evolution.loadbalancer.server.port=8080"

EOFEVO
        else
            # Additional instances with numbered subdomains
            cat >> /tmp/apps-stack.yml << EOFEVO
  $service_name:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://$subdomain.$domain
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/$db_name
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - WEBHOOK_GLOBAL_URL=https://$subdomain.$domain
      - CONFIG_SESSION_SECRET=caixapretastack2626
      - QRCODE_LIMIT=30
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
      - LOG_LEVEL=ERROR
      - LOG_COLOR=false
      - DEL_INSTANCE=false
    volumes:
      - /data/evolution$i:/evolution/instances
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/manager/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
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
        reservations:
          memory: 256M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.$service_name.rule=Host(\`$subdomain.$domain\`)"
        - "traefik.http.routers.$service_name.entrypoints=websecure"
        - "traefik.http.routers.$service_name.tls.certresolver=letsencrypt"
        - "traefik.http.services.$service_name.loadbalancer.server.port=8080"

EOFEVO
        fi
    done
    
    # Add Gowa service
    cat >> /tmp/apps-stack.yml << 'EOFGOWA'
  gowa:
    image: gowa/whatsapp-api:latest
    environment:
      - SERVER_URL=https://gowa.$domain
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/gowa_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - WEBHOOK_GLOBAL_URL=https://gowa.$domain
      - CONFIG_SESSION_SECRET=caixapretastack2626
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
      - LOG_LEVEL=ERROR
      - LOG_COLOR=false
    volumes:
      - /data/gowa:/gowa/instances
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
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
        reservations:
          memory: 256M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.gowa.rule=Host(\`gowa.$domain\`)"
        - "traefik.http.routers.gowa.entrypoints=websecure"
        - "traefik.http.routers.gowa.tls.certresolver=letsencrypt"
        - "traefik.http.services.gowa.loadbalancer.server.port=8080"

EOFGOWA

    # Add OpenClaw service if requested
    if [[ "$install_openclaw" =~ ^[Yy]$ ]]; then
        cat >> /tmp/apps-stack.yml << 'EOFOPENCLAW'
  openclaw:
    image: openclaw/openclaw:latest
    environment:
      - OPENCLAW_HOST=openclaw.$domain
      - OPENCLAW_PORT=3000
      - OPENCLAW_PROTOCOL=https
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/openclaw_db
      - REDIS_URL=redis://db_redis-n8n:6379/2
      - API_KEY=caixapretastack2626
      - WEBHOOK_URL=https://openclaw.$domain
      - LOG_LEVEL=info
    volumes:
      - /data/openclaw:/app/data
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
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
        reservations:
          memory: 256M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.openclaw.rule=Host(\`openclaw.$domain\`)"
        - "traefik.http.routers.openclaw.entrypoints=websecure"
        - "traefik.http.routers.openclaw.tls.certresolver=letsencrypt"
        - "traefik.http.services.openclaw.loadbalancer.server.port=3000"

EOFOPENCLAW
    fi

    cat >> /tmp/apps-stack.yml << 'EOFNETWORKS'
networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOFNETWORKS

    # Deploy automation stack
    log_info "Deploying automation stack..."
    docker stack deploy -c /tmp/apps-stack.yml automation
    
    # Verify automation services with extended timeouts
    verify_service "automation_n8n" "1/1" 90
    verify_service "automation_evolution" "1/1" 90
    
    # Verify additional Evolution instances
    for i in $(seq 2 $evolution_instances); do
        local service_name="evolution$i"
        verify_service "automation_$service_name" "1/1" 90
    done
    
    verify_service "automation_gowa" "1/1" 90
    verify_service "automation_n8n-worker" "2/2" 90
    
    # Verify OpenClaw if deployed
    if [[ "$install_openclaw" =~ ^[Yy]$ ]]; then
        verify_service "automation_openclaw" "1/1" 90
    fi
    
    # Cleanup
    rm -f /tmp/apps-stack.yml
    
    log_success "Automation applications deployed successfully"
}
# Enhanced MEGA and additional services deployment
deploy_mega_services() {
    local domain="$1"
    
    log_step "Deploying MEGA (Chatwoot) and additional services"
    
    # Create comprehensive MEGA stack
    cat > /tmp/mega-stack.yml << EOF
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
      - RAILS_MAX_THREADS=5
      - WEB_CONCURRENCY=2
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
      start_period: 90s
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
        - "traefik.http.routers.mega.rule=Host(\\`mega.$domain\\`)"
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
      start_period: 60s
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
        reservations:
          memory: 256M
EOF
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
      start_period: 30s
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
        reservations:
          memory: 256M
      labels:
        - "traefik.enable=true"
        # S3 API endpoint
        - "traefik.http.routers.minio-api.rule=Host(\\`s3.$domain\\`)"
        - "traefik.http.routers.minio-api.entrypoints=websecure"
        - "traefik.http.routers.minio-api.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-api.service=minio-api"
        - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
        # Console endpoint
        - "traefik.http.routers.minio-console.rule=Host(\\`minio.$domain\\`)"
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
      - GF_SECURITY_ALLOW_EMBEDDING=true
      - GF_AUTH_ANONYMOUS_ENABLED=false
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
      start_period: 30s
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
        reservations:
          memory: 128M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana.rule=Host(\\`grafana.$domain\\`)"
        - "traefik.http.routers.grafana.entrypoints=websecure"
        - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
        - "traefik.http.services.grafana.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

    # Deploy MEGA stack
    log_info "Deploying MEGA and additional services stack..."
    docker stack deploy -c /tmp/mega-stack.yml apps
    
    # Verify services with extended timeouts for MEGA
    verify_service "apps_minio" "1/1" 60
    verify_service "apps_grafana" "1/1" 60
    
    # MEGA services need more time to initialize
    log_info "Waiting for MEGA services to initialize (this may take up to 3 minutes)..."
    sleep 90
    
    verify_service "apps_mega-rails" "1/1" 120
    verify_service "apps_mega-sidekiq" "1/1" 90
    
    # Cleanup
    rm -f /tmp/mega-stack.yml
    
    log_success "MEGA and additional services deployed successfully"
}

# Deploy Admin Painel
deploy_painel() {
    local domain="$1"
    
    log_step "Deploying Admin Painel"
    
    # Setup painel files
    log_info "Setting up painel files..."
    bash /tmp/setup-painel.sh 2>/dev/null || true
    
    # Create painel stack
    cat > /tmp/painel-stack.yml << 'EOF'
version: '3.8'
services:
  painel:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - /data/painel/painel-admin.html:/app/painel-admin.html:ro
      - /data/painel/painel-server.js:/app/server.js:ro
      - /data/painel/design-tokens.css:/app/design-tokens.css:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - NODE_ENV=production
      - PORT=3000
    command: sh -c "npm install express --silent && node server.js"
    networks:
      - traefik-public
      - internal-net
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
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
        reservations:
          memory: 128M
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.painel.rule=PathPrefix(`/painel`) || PathPrefix(`/api`)"
        - "traefik.http.routers.painel.entrypoints=web,websecure"
        - "traefik.http.routers.painel.tls.certresolver=letsencrypt"
        - "traefik.http.services.painel.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

    # Deploy painel stack
    log_info "Deploying Admin Painel service..."
    docker stack deploy -c /tmp/painel-stack.yml painel
    
    # Verify painel service
    verify_service "painel_painel" "1/1" 60
    
    # Cleanup
    rm -f /tmp/painel-stack.yml
    
    log_success "Admin Painel deployed successfully"
}

# Comprehensive final verification
final_verification() {
    log_step "Performing comprehensive final verification"
    
    # Check all services
    log_info "Verifying all deployed services..."
    
    local all_services=(
        "core_traefik:1/1"
        "core_portainer:1/1"
        "db_postgres:1/1"
        "db_redis-n8n:1/1"
        "db_redis-mega:1/1"
        "automation_n8n:1/1"
        "automation_evolution:1/1"
        "automation_n8n-worker:2/2"
        "apps_mega-rails:1/1"
        "apps_mega-sidekiq:1/1"
        "apps_minio:1/1"
        "apps_grafana:1/1"
    )
    
    local failed_services=0
    
    for service_info in "${all_services[@]}"; do
        local service_name=$(echo "$service_info" | cut -d: -f1)
        local expected_replicas=$(echo "$service_info" | cut -d: -f2)
        local current_replicas=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "^$service_name " | awk '{print $2}' || echo "0/0")
        
        if [ "$current_replicas" = "$expected_replicas" ]; then
            log_success "$service_name: $current_replicas ✓"
        else
            log_error "$service_name: $current_replicas (expected $expected_replicas) ✗"
            ((failed_services++))
        fi
    done
    
    # Test connectivity
    log_info "Testing service connectivity..."
    
    # Test Traefik
    local traefik_response=$(timeout 10 curl -s -o /dev/null -w "%{http_code}" "http://localhost" 2>/dev/null || echo "000")
    if [[ "$traefik_response" =~ ^(301|302|404)$ ]]; then
        log_success "Traefik connectivity: HTTP $traefik_response ✓"
    else
        log_warning "Traefik connectivity: HTTP $traefik_response (may be normal)"
    fi
    
    # Test Redis connectivity
    for redis_service in "db_redis-n8n" "db_redis-mega"; do
        local redis_test=$(docker run --rm --network internal-net redis:7-alpine redis-cli -h "$redis_service" ping 2>/dev/null || echo "FAILED")
        if [ "$redis_test" = "PONG" ]; then
            log_success "$redis_service connectivity: PONG ✓"
        else
            log_error "$redis_service connectivity: $redis_test ✗"
            ((failed_services++))
        fi
    done
    
    # Test PostgreSQL connectivity
    local postgres_container=$(docker ps -q -f name=db_postgres 2>/dev/null | head -1)
    if [ -n "$postgres_container" ]; then
        if docker exec "$postgres_container" pg_isready -U postgres >/dev/null 2>&1; then
            log_success "PostgreSQL connectivity: Ready ✓"
        else
            log_error "PostgreSQL connectivity: Not ready ✗"
            ((failed_services++))
        fi
    else
        log_error "PostgreSQL container not found ✗"
        ((failed_services++))
    fi
    
    # Summary
    if [ $failed_services -eq 0 ]; then
        log_success "All services are operational! ✓"
        return 0
    else
        log_error "$failed_services services have issues"
        log_info "Run './diagnose-all-services.sh' for detailed analysis"
        return 1
    fi
}

# Enhanced main function with comprehensive error handling
main() {
    # Initialize logging
    echo "CaixaPreta Stack Enhanced Installation Log" > "$INSTALL_LOG"
    echo "Started at: $(date)" >> "$INSTALL_LOG"
    
    # Clear screen and show banner
    clear
    
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
██╗███╗   ██╗███████╗██████╗  █████╗      ██████╗ █████╗ ██╗██╗  ██╗ █████╗ 
██║████╗  ██║██╔════╝██╔══██╗██╔══██╗    ██╔════╝██╔══██╗██║╚██╗██╔╝██╔══██╗
██║██╔██╗ ██║█████╗  ██████╔╝███████║    ██║     ███████║██║ ╚███╔╝ ███████║
██║██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║    ██║     ██╔══██║██║ ██╔██╗ ██╔══██║
██║██║ ╚████║██║     ██║  ██║██║  ██║    ╚██████╗██║  ██║██║██╔╝ ██╗██║  ██║
╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
                                                                              
██████╗ ██████╗ ███████╗████████╗ █████╗     ██╗   ██╗██████╗ 
██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗    ██║   ██║╚════██╗
██████╔╝██████╔╝█████╗     ██║   ███████║    ██║   ██║ █████╔╝
██╔═══╝ ██╔══██╗██╔══╝     ██║   ██╔══██║    ╚██╗ ██╔╝██╔═══╝ 
██║     ██║  ██║███████╗   ██║   ██║  ██║     ╚████╔╝ ███████╗
╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝      ╚═══╝  ╚══════╝
EOF
    echo -e "${NC}"
    
    echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                    ENHANCED FRESH INSTALL SYSTEM v2${NC}"
    echo -e "${YELLOW}${BOLD}                      Created by Hudson Argollo (@getrules)${NC}"
    echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
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
    log_step "$(msg "welcome_title")"
    log_info "$(msg "enhanced_version")"
    
    # Root check
    log_info "$(msg "root_check")"
    if [ "$EUID" -ne 0 ]; then 
        log_error "$(msg "root_error")"
        exit 1
    fi
    log_success "$(msg "root_confirmed")"
    # System requirements check
    check_system_requirements
    
    # Configuration
    echo
    log_step "$(msg "config_setup")"
    echo
    echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${CYAN}${BOLD}│                 CONFIGURACAO DE DOMINIO                     │${NC}"
    else
        echo -e "${CYAN}${BOLD}│                    DOMAIN CONFIGURATION                     │${NC}"
    fi
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    echo
    
    echo -ne "${GREEN}${BOLD}$(msg "enter_domain")${NC}"
    read DOMAIN
    
    echo -ne "${GREEN}${BOLD}$(msg "enter_email")${NC}"
    read EMAIL
    
    echo -ne "${GREEN}${BOLD}How many Evolution API instances do you want to deploy? (default: 1): ${NC}"
    read EVOLUTION_INSTANCES
    EVOLUTION_INSTANCES=${EVOLUTION_INSTANCES:-1}
    
    # Validate Evolution instances input
    if ! [[ "$EVOLUTION_INSTANCES" =~ ^[0-9]+$ ]] || [ "$EVOLUTION_INSTANCES" -lt 1 ]; then
        log_warning "Invalid number of instances, using default: 1"
        EVOLUTION_INSTANCES=1
    fi
    
    echo -ne "${GREEN}${BOLD}Do you want to deploy OpenClaw (formerly Clawdbot/Moltbot)? (y/n, default: n): ${NC}"
    read INSTALL_OPENCLAW
    INSTALL_OPENCLAW=${INSTALL_OPENCLAW:-n}
    
    if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
        log_error "$(msg "domain_email_required")"
        exit 1
    fi
    
    log_success "$(msg "config_accepted")"
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    log_info "Evolution API instances: $EVOLUTION_INSTANCES"
    
    # Clean previous installations
    clean_previous_installation
    
    # System preparation
    echo
    log_step "$(msg "system_prep")"
    
    # Update system
    log_info "$(msg "updating_system")"
    apt update >/dev/null 2>&1 && apt upgrade -y >/dev/null 2>&1
    
    # Install dependencies
    log_info "$(msg "installing_deps")"
    apt install -y curl wget git jq ufw unzip net-tools htop >/dev/null 2>&1
    
    log_success "System preparation completed"
    
    # Docker installation and verification
    install_docker
    
    # Swarm initialization
    initialize_swarm
    
    # Network creation
    create_networks
    
    # Data directory setup
    setup_data_directories "$EVOLUTION_INSTANCES" "$INSTALL_OPENCLAW"
    
    # Deploy core services (Traefik + Portainer)
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    SERVICOS PRINCIPAIS                      │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    CORE SERVICES                            │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_traefik "$DOMAIN" "$EMAIL"
    
    # Deploy databases
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    CAMADA DE BANCO DE DADOS                 │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    DATABASE LAYER                           │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_databases
    
    # Initialize databases
    initialize_databases
    
    # Deploy automation services
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    CAMADA DE AUTOMACAO                      │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    AUTOMATION LAYER                         │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_applications "$DOMAIN" "$EVOLUTION_INSTANCES" "$INSTALL_OPENCLAW"
    
    # Deploy MEGA and additional services
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    CAMADA DE APLICACAO                      │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    APPLICATION LAYER                        │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_mega_services "$DOMAIN"
    
    # Deploy Admin Painel
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    PAINEL DE ADMINISTRACAO                  │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    ADMIN PAINEL                             │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    deploy_painel "$DOMAIN"
    
    # Final verification
    echo
    echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "${PURPLE}${BOLD}│                    VERIFICACAO FINAL                        │${NC}"
    else
        echo -e "${PURPLE}${BOLD}│                    FINAL VERIFICATION                       │${NC}"
    fi
    echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    
    if final_verification; then
        # Success message
        echo
        if [ "$LANG_MODE" = "pt" ]; then
            echo -e "${GREEN}${BOLD}🎉 IMPLANTACAO CONCLUIDA COM SUCESSO! 🎉${NC}"
        else
            echo -e "${GREEN}${BOLD}🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉${NC}"
        fi
        echo
        echo -e "${CYAN}${BOLD}$(msg "access_endpoints"):${NC}"
        echo -e "${GREEN}• n8n Automation:     ${WHITE}https://n8n.$DOMAIN${NC}"
        echo -e "${GREEN}• MEGA Chatwoot:      ${WHITE}https://mega.$DOMAIN${NC}"
        echo -e "${GREEN}• Evolution API:      ${WHITE}https://evolution.$DOMAIN${NC}"
        
        # Show additional Evolution instances if configured
        if [ "$EVOLUTION_INSTANCES" -gt 1 ]; then
            for i in $(seq 2 $EVOLUTION_INSTANCES); do
                echo -e "${GREEN}• Evolution API $i:    ${WHITE}https://evolution$i.$DOMAIN${NC}"
            done
        fi
        
        echo -e "${GREEN}• Gowa WhatsApp API:  ${WHITE}https://gowa.$DOMAIN${NC}"
        
        # Show OpenClaw if deployed
        if [[ "$INSTALL_OPENCLAW" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}• OpenClaw AI Agent:  ${WHITE}https://openclaw.$DOMAIN${NC}"
        fi
        
        echo -e "${GREEN}• Portainer:          ${WHITE}https://portainer.$DOMAIN${NC}"
        echo -e "${GREEN}• Traefik Dashboard:  ${WHITE}https://traefik.$DOMAIN${NC}"
        echo -e "${GREEN}• MinIO Console:      ${WHITE}https://minio.$DOMAIN${NC}"
        echo -e "${GREEN}• Grafana:            ${WHITE}https://grafana.$DOMAIN${NC}"
        echo -e "${GREEN}• Admin Painel:       ${WHITE}https://$DOMAIN/painel${NC}"
        echo
        echo -e "${YELLOW}${BOLD}$(msg "important_notes"):${NC}"
        if [ "$LANG_MODE" = "pt" ]; then
            echo -e "${YELLOW}• Configure registros DNS para todos os subdominios${NC}"
            echo -e "${YELLOW}• Certificados SSL serao gerados automaticamente (5-15 minutos)${NC}"
            echo -e "${YELLOW}• Senha padrao para todos os servicos: caixapretastack2626${NC}"
            echo -e "${YELLOW}• Altere as senhas apos o primeiro login para seguranca${NC}"
        else
            echo -e "${YELLOW}• Configure DNS records for all subdomains${NC}"
            echo -e "${YELLOW}• SSL certificates will generate automatically (5-15 minutes)${NC}"
            echo -e "${YELLOW}• Default password for all services: caixapretastack2626${NC}"
            echo -e "${YELLOW}• Change passwords after first login for security${NC}"
        fi
        echo
        log_success "$(msg "deployment_complete")"
    else
        echo
        if [ "$LANG_MODE" = "pt" ]; then
            echo -e "${RED}${BOLD}⚠️  IMPLANTACAO CONCLUIDA COM PROBLEMAS ⚠️${NC}"
            echo
            echo -e "${YELLOW}Alguns servicos podem precisar de tempo adicional para iniciar ou ter problemas.${NC}"
            echo -e "${YELLOW}Execute os seguintes comandos para diagnosticar e corrigir:${NC}"
        else
            echo -e "${RED}${BOLD}⚠️  DEPLOYMENT COMPLETED WITH ISSUES ⚠️${NC}"
            echo
            echo -e "${YELLOW}Some services may need additional time to start or have issues.${NC}"
            echo -e "${YELLOW}Run the following commands to diagnose and fix:${NC}"
        fi
        echo
        echo -e "${CYAN}• Full diagnostic: ${WHITE}./diagnose-all-services.sh${NC}"
        echo -e "${CYAN}• Fix all issues:  ${WHITE}sudo ./fix-and-redeploy.sh${NC}"
        echo -e "${CYAN}• Check logs:      ${WHITE}cat $INSTALL_LOG${NC}"
        echo
        log_warning "Installation completed with some issues"
    fi
    
    # Save final state
    save_installation_state
    
    echo "Installation completed at: $(date)" >> "$INSTALL_LOG"
}

# Execute main function
main "$@"
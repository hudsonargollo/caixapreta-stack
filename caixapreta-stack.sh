#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK v2.0
# Script de Automação de Infraestrutura Docker Swarm (Inspirado na Masterclass)
# Autor: Hudson Argollo e seus amiguinho Manus
# Sistema: Debian/Ubuntu
# Foco: n8n + MEGA (Chatwoot V4 mod Nestor/Valus) + Evolution API + Traefik
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
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'

# Hacker-style functions
print_slow() {
    local text="$1"
    local delay="${2:-0.03}"
    echo -e "$text"
    sleep "$delay"
}

print_matrix() {
    local text="$1"
    echo -e "${GREEN}${BOLD}$text${NC}"
}

print_error() {
    local text="$1"
    echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$text${NC}"
}

print_success() {
    local text="$1"
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} ${GREEN}$text${NC}"
}

print_warning() {
    local text="$1"
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} ${YELLOW}$text${NC}"
}

print_info() {
    local text="$1"
    echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$text${NC}"
}

print_hacker() {
    local text="$1"
    echo -e "${GREEN}${BOLD}>>> ${NC}${GREEN}$text${NC}"
}

# Language-specific messages
msg() {
    local key="$1"
    case "$key" in
        "root_check")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando privilegios do sistema..."
            else
                echo "Checking system privileges..."
            fi
            ;;
        "root_error")
            if [ "$LANG" = "pt" ]; then
                echo "Acesso root necessario. Execute como root ou com sudo."
            else
                echo "Root access required. Please run as root or with sudo."
            fi
            ;;
        "root_terminating")
            if [ "$LANG" = "pt" ]; then
                echo "TERMINANDO PROCESSO..."
            else
                echo "TERMINATING PROCESS..."
            fi
            ;;
        "root_success")
            if [ "$LANG" = "pt" ]; then
                echo "Privilegios root confirmados"
            else
                echo "Root privileges confirmed"
            fi
            ;;
        "config_mode")
            if [ "$LANG" = "pt" ]; then
                echo "ENTRANDO NO MODO DE CONFIGURACAO..."
            else
                echo "ENTERING CONFIGURATION MODE..."
            fi
            ;;
        "domain_config")
            if [ "$LANG" = "pt" ]; then
                echo "                    CONFIGURACAO DE DOMINIO                     "
            else
                echo "                    DOMAIN CONFIGURATION                     "
            fi
            ;;
        "enter_domain")
            if [ "$LANG" = "pt" ]; then
                echo "Digite seu dominio base (ex: seu-dominio.com):"
            else
                echo "Enter your base domain (e.g., your-domain.com):"
            fi
            ;;
        "enter_email")
            if [ "$LANG" = "pt" ]; then
                echo "Digite seu email para certificados SSL (Let's Encrypt):"
            else
                echo "Enter your email for SSL certificates (Let's Encrypt):"
            fi
            ;;
        "config_required")
            if [ "$LANG" = "pt" ]; then
                echo "Dominio e email sao obrigatorios para implantacao segura"
            else
                echo "Domain and email are required for secure deployment"
            fi
            ;;
        "aborting")
            if [ "$LANG" = "pt" ]; then
                echo "ABORTANDO MISSAO..."
            else
                echo "ABORTING MISSION..."
            fi
            ;;
        "config_accepted")
            if [ "$LANG" = "pt" ]; then
                echo "Configuracao aceita"
            else
                echo "Configuration accepted"
            fi
            ;;
        "validating_config")
            if [ "$LANG" = "pt" ]; then
                echo "Validando parametros de configuracao"
            else
                echo "Validating configuration parameters"
            fi
            ;;
        "system_upgrade")
            if [ "$LANG" = "pt" ]; then
                echo "INICIANDO SEQUÊNCIA DE ATUALIZAÇÃO DO SISTEMA..."
            else
                echo "INITIATING SYSTEM UPGRADE SEQUENCE..."
            fi
            ;;
        "updating_repos")
            if [ "$LANG" = "pt" ]; then
                echo "Atualizando repositórios do sistema..."
            else
                echo "Updating system repositories..."
            fi
            ;;
        "fetching_packages")
            if [ "$LANG" = "pt" ]; then
                echo "Buscando informações dos pacotes mais recentes"
            else
                echo "Fetching latest package information"
            fi
            ;;
        "installing_deps")
            if [ "$LANG" = "pt" ]; then
                echo "Instalando dependências principais..."
            else
                echo "Installing core dependencies..."
            fi
            ;;
        "deps_success")
            if [ "$LANG" = "pt" ]; then
                echo "Todas as dependências instaladas com sucesso"
            else
                echo "All dependencies installed successfully"
            fi
            ;;
        "docker_deploy")
            if [ "$LANG" = "pt" ]; then
                echo "IMPLANTACAO DO SISTEMA DE CONTAINERIZACAO DOCKER..."
            else
                echo "DOCKER CONTAINERIZATION SYSTEM DEPLOYMENT..."
            fi
            ;;
        "docker_installing")
            if [ "$LANG" = "pt" ]; then
                echo "Docker nao detectado. Instalando Docker Engine..."
            else
                echo "Docker not detected. Installing Docker Engine..."
            fi
            ;;
        "docker_downloading")
            if [ "$LANG" = "pt" ]; then
                echo "Baixando script de instalacao do Docker"
            else
                echo "Downloading Docker installation script"
            fi
            ;;
        "docker_executing")
            if [ "$LANG" = "pt" ]; then
                echo "Executando instalacao do Docker..."
            else
                echo "Executing Docker installation..."
            fi
            ;;
        "docker_success")
            if [ "$LANG" = "pt" ]; then
                echo "Docker Engine instalado com sucesso"
            else
                echo "Docker Engine installed successfully"
            fi
            ;;
        "docker_exists")
            if [ "$LANG" = "pt" ]; then
                echo "Docker Engine ja instalado"
            else
                echo "Docker Engine already installed"
            fi
            ;;
        "swarm_init")
            if [ "$LANG" = "pt" ]; then
                echo "INICIALIZANDO CLUSTER DOCKER SWARM..."
            else
                echo "INITIALIZING DOCKER SWARM CLUSTER..."
            fi
            ;;
        "swarm_configuring")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando orquestracao Docker Swarm..."
            else
                echo "Configuring Docker Swarm orchestration..."
            fi
            ;;
        "swarm_ip_detected")
            if [ "$LANG" = "pt" ]; then
                echo "IP publico detectado:"
            else
                echo "Public IP detected:"
            fi
            ;;
        "swarm_initializing")
            if [ "$LANG" = "pt" ]; then
                echo "Inicializando cluster Swarm"
            else
                echo "Initializing Swarm cluster"
            fi
            ;;
        "swarm_success")
            if [ "$LANG" = "pt" ]; then
                echo "Cluster Docker Swarm inicializado"
            else
                echo "Docker Swarm cluster initialized"
            fi
            ;;
        "swarm_active")
            if [ "$LANG" = "pt" ]; then
                echo "Docker Swarm ja ativo"
            else
                echo "Docker Swarm already active"
            fi
            ;;
        "docker_verifying")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando instalacao do Docker..."
            else
                echo "Verifying Docker installation..."
            fi
            ;;
        "docker_daemon_check")
            if [ "$LANG" = "pt" ]; then
                echo "Testando conexao com daemon do Docker..."
            else
                echo "Testing Docker daemon connection..."
            fi
            ;;
        "docker_ready")
            if [ "$LANG" = "pt" ]; then
                echo "Docker esta pronto e respondendo"
            else
                echo "Docker is ready and responding"
            fi
            ;;
        "swarm_failed")
            if [ "$LANG" = "pt" ]; then
                echo "Falha ao inicializar Docker Swarm"
            else
                echo "Failed to initialize Docker Swarm"
            fi
            ;;
        "swarm_issues")
            if [ "$LANG" = "pt" ]; then
                echo "Isso pode ser devido a:"
            else
                echo "This could be due to:"
            fi
            ;;
        "swarm_alternative")
            if [ "$LANG" = "pt" ]; then
                echo "Tentando inicializacao alternativa..."
            else
                echo "Attempting alternative initialization..."
            fi
            ;;
        "swarm_default_success")
            if [ "$LANG" = "pt" ]; then
                echo "Docker Swarm inicializado com configuracoes padrao"
            else
                echo "Docker Swarm initialized with default settings"
            fi
            ;;
        "swarm_complete_failure")
            if [ "$LANG" = "pt" ]; then
                echo "Falha completa na inicializacao do Docker Swarm"
            else
                echo "Docker Swarm initialization failed completely"
            fi
            ;;
        "swarm_manual_fix")
            if [ "$LANG" = "pt" ]; then
                echo "Correcao manual: docker swarm init --advertise-addr SEU_IP_DO_SERVIDOR"
            else
                echo "Manual fix: docker swarm init --advertise-addr YOUR_SERVER_IP"
            fi
            ;;
        "docker_waiting")
            if [ "$LANG" = "pt" ]; then
                echo "Aguardando inicializacao do Docker..."
            else
                echo "Waiting for Docker to initialize..."
            fi
            ;;
        "docker_daemon_error")
            if [ "$LANG" = "pt" ]; then
                echo "Nao foi possivel conectar ao daemon do Docker"
            else
                echo "Cannot connect to Docker daemon"
            fi
            ;;
        "docker_daemon_info")
            if [ "$LANG" = "pt" ]; then
                echo "Isso geralmente significa que o servico Docker nao esta rodando ou as permissoes do socket estao erradas"
            else
                echo "This usually means Docker service is not running or socket permissions are wrong"
            fi
            ;;
        "docker_quick_fix")
            if [ "$LANG" = "pt" ]; then
                echo "Opcoes de correcao rapida:"
            else
                echo "Quick fix options:"
            fi
            ;;
        "security_applying")
            if [ "$LANG" = "pt" ]; then
                echo "Aplicando configuracoes de seguranca"
            else
                echo "Applying security configurations"
            fi
            ;;
        "security_success")
            if [ "$LANG" = "pt" ]; then
                echo "Seguranca do Docker configurada"
            else
                echo "Docker security configured"
            fi
            ;;
        "docker_security")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando permissoes de seguranca do Docker..."
            else
                echo "Configuring Docker security permissions..."
            fi
            ;;
        "network_infra")
            if [ "$LANG" = "pt" ]; then
                echo "ESTABELECENDO INFRAESTRUTURA DE REDE..."
            else
                echo "ESTABLISHING NETWORK INFRASTRUCTURE..."
            fi
            ;;
        "network_cleaning")
            if [ "$LANG" = "pt" ]; then
                echo "Limpando configurações de rede existentes..."
            else
                echo "Cleaning existing network configurations..."
            fi
            ;;
        "network_creating")
            if [ "$LANG" = "pt" ]; then
                echo "Criando topologia de rede overlay..."
            else
                echo "Creating overlay network topology..."
            fi
            ;;
        "network_traefik")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando rede traefik-public"
            else
                echo "Configuring traefik-public network"
            fi
            ;;
        "network_internal")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando rede internal-net"
            else
                echo "Configuring internal-net network"
            fi
            ;;
        "network_success")
            if [ "$LANG" = "pt" ]; then
                echo "Infraestrutura de rede estabelecida"
            else
                echo "Network infrastructure established"
            fi
            ;;
        "data_persistence")
            if [ "$LANG" = "pt" ]; then
                echo "PREPARANDO CAMADA DE PERSISTÊNCIA DE DADOS..."
            else
                echo "PREPARING DATA PERSISTENCE LAYER..."
            fi
            ;;
        "data_creating")
            if [ "$LANG" = "pt" ]; then
                echo "Criando estrutura de diretórios de dados..."
            else
                echo "Creating data directory structure..."
            fi
            ;;
        "ssl_config")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando armazenamento de certificados SSL..."
            else
                echo "Configuring SSL certificate storage..."
            fi
            ;;
        "permissions_setting")
            if [ "$LANG" = "pt" ]; then
                echo "Definindo permissões de diretório..."
            else
                echo "Setting directory permissions..."
            fi
            ;;
        "permissions_applying")
            if [ "$LANG" = "pt" ]; then
                echo "Aplicando permissões de segurança"
            else
                echo "Applying security permissions"
            fi
            ;;
        "data_success")
            if [ "$LANG" = "pt" ]; then
                echo "Camada de persistência de dados configurada"
            else
                echo "Data persistence layer configured"
            fi
            ;;
        "traefik_config")
            if [ "$LANG" = "pt" ]; then
                echo "CONFIGURANDO PROXY REVERSO E TERMINAÇÃO SSL..."
            else
                echo "CONFIGURING REVERSE PROXY & SSL TERMINATION..."
            fi
            ;;
        "traefik_generating")
            if [ "$LANG" = "pt" ]; then
                echo "Gerando configuração do Traefik..."
            else
                echo "Generating Traefik configuration..."
            fi
            ;;
        "ssl_automation")
            if [ "$LANG" = "pt" ]; then
                echo "Criando regras de automação SSL"
            else
                echo "Creating SSL automation rules"
            fi
            ;;
        "traefik_success")
            if [ "$LANG" = "pt" ]; then
                echo "Proxy reverso Traefik configurado"
            else
                echo "Traefik reverse proxy configured"
            fi
            ;;
        "deployment_sequence")
            if [ "$LANG" = "pt" ]; then
                echo "INICIANDO SEQUÊNCIA DE IMPLANTAÇÃO DE STACKS..."
            else
                echo "INITIATING STACK DEPLOYMENT SEQUENCE..."
            fi
            ;;
        "deployment_preparing")
            if [ "$LANG" = "pt" ]; then
                echo "Preparando ambiente de implantação"
            else
                echo "Preparing deployment environment"
            fi
            ;;
        "core_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando Infraestrutura Principal (Traefik + Portainer)..."
            else
                echo "Deploying Core Infrastructure (Traefik + Portainer)..."
            fi
            ;;
        "traefik_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando proxy reverso Traefik"
            else
                echo "Deploying Traefik reverse proxy"
            fi
            ;;
        "portainer_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando interface de gerenciamento Portainer"
            else
                echo "Deploying Portainer management interface"
            fi
            ;;
        "core_success")
            if [ "$LANG" = "pt" ]; then
                echo "Infraestrutura principal implantada"
            else
                echo "Core infrastructure deployed"
            fi
            ;;
        "verifying_core")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando status dos serviços principais..."
            else
                echo "Verifying core services status..."
            fi
            ;;
        "mission_complete")
            if [ "$LANG" = "pt" ]; then
                echo "MISSÃO CUMPRIDA - TODOS OS SISTEMAS OPERACIONAIS"
            else
                echo "MISSION ACCOMPLISHED - ALL SYSTEMS OPERATIONAL"
            fi
            ;;
        "deployment_complete")
            if [ "$LANG" = "pt" ]; then
                echo "Implantação da infraestrutura concluída com sucesso!"
            else
                echo "Infrastructure deployment completed successfully!"
            fi
            ;;
        "access_endpoints")
            if [ "$LANG" = "pt" ]; then
                echo "                    PONTOS DE ACESSO                         "
            else
                echo "                    ACCESS ENDPOINTS                         "
            fi
            ;;
        "verifying_core")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando status dos serviços principais..."
            else
                echo "Verifying core services status..."
            fi
            ;;
        "db_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando cluster de banco PostgreSQL"
            else
                echo "Deploying PostgreSQL database cluster"
            fi
            ;;
        "redis_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando servidores de cache Redis"
            else
                echo "Deploying Redis cache servers"
            fi
            ;;
        "data_persistence_config")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando persistência de dados"
            else
                echo "Configuring data persistence"
            fi
            ;;
        "db_success")
            if [ "$LANG" = "pt" ]; then
                echo "Infraestrutura de banco implantada"
            else
                echo "Database infrastructure deployed"
            fi
            ;;
        "db_status_check")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando status dos serviços de banco..."
            else
                echo "Verifying database services status..."
            fi
            ;;
        "automation_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando motor de automação n8n"
            else
                echo "Deploying n8n automation engine"
            fi
            ;;
        "workflow_workers")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando workers de workflow"
            else
                echo "Configuring workflow workers"
            fi
            ;;
        "queue_system")
            if [ "$LANG" = "pt" ]; then
                echo "Estabelecendo sistema de filas"
            else
                echo "Establishing queue system"
            fi
            ;;
        "automation_success")
            if [ "$LANG" = "pt" ]; then
                echo "Infraestrutura de automação implantada"
            else
                echo "Automation infrastructure deployed"
            fi
            ;;
        "automation_status_check")
            if [ "$LANG" = "pt" ]; then
                echo "Verificando status dos serviços de automação..."
            else
                echo "Verifying automation services status..."
            fi
            ;;
        "mega_db_prep")
            if [ "$LANG" = "pt" ]; then
                echo "PREPARANDO BANCO DE DADOS MEGA (CHATWOOT)..."
            else
                echo "PREPARING MEGA (CHATWOOT) DATABASE..."
            fi
            ;;
        "postgres_waiting")
            if [ "$LANG" = "pt" ]; then
                echo "Aguardando cluster PostgreSQL ficar pronto..."
            else
                echo "Waiting for PostgreSQL cluster to be ready..."
            fi
            ;;
        "db_connections")
            if [ "$LANG" = "pt" ]; then
                echo "Estabelecendo conexões de banco"
            else
                echo "Establishing database connections"
            fi
            ;;
        "chatwoot_init")
            if [ "$LANG" = "pt" ]; then
                echo "Inicializando esquema de banco Chatwoot..."
            else
                echo "Initializing Chatwoot database schema..."
            fi
            ;;
        "db_init_prep")
            if [ "$LANG" = "pt" ]; then
                echo "Preparando inicialização do banco"
            else
                echo "Preparing database initialization"
            fi
            ;;
        "chatwoot_db_success")
            if [ "$LANG" = "pt" ]; then
                echo "Banco Chatwoot preparado"
            else
                echo "Chatwoot database prepared"
            fi
            ;;
        "evolution_db_create")
            if [ "$LANG" = "pt" ]; then
                echo "Criando banco Evolution API..."
            else
                echo "Creating Evolution API database..."
            fi
            ;;
        "db_schemas_success")
            if [ "$LANG" = "pt" ]; then
                echo "Esquemas de banco preparados"
            else
                echo "Database schemas prepared"
            fi
            ;;
        "postgres_test")
            if [ "$LANG" = "pt" ]; then
                echo "Testando conexão PostgreSQL..."
            else
                echo "Testing PostgreSQL connection..."
            fi
            ;;
        "postgres_ready")
            if [ "$LANG" = "pt" ]; then
                echo "PostgreSQL está pronto"
            else
                echo "PostgreSQL is ready"
            fi
            ;;
        "postgres_failed")
            if [ "$LANG" = "pt" ]; then
                echo "PostgreSQL falhou ao iniciar corretamente"
            else
                echo "PostgreSQL failed to start properly"
            fi
            ;;
        "app_layer_deploy")
            if [ "$LANG" = "pt" ]; then
                echo "IMPLANTANDO CAMADA DE APLICAÇÃO..."
            else
                echo "DEPLOYING APPLICATION LAYER..."
            fi
            ;;
        "apps_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando MEGA (Chatwoot V4), Evolution API, MinIO e Grafana..."
            else
                echo "Deploying MEGA (Chatwoot V4), Evolution API, MinIO & Grafana..."
            fi
            ;;
        "evolution_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando Evolution API (Integração WhatsApp)"
            else
                echo "Deploying Evolution API (WhatsApp Integration)"
            fi
            ;;
        "mega_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando MEGA (Chatwoot V4 Atendimento)"
            else
                echo "Deploying MEGA (Chatwoot V4 Customer Service)"
            fi
            ;;
        "minio_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando MinIO Armazenamento de Objetos"
            else
                echo "Deploying MinIO Object Storage"
            fi
            ;;
        "grafana_deploying")
            if [ "$LANG" = "pt" ]; then
                echo "Implantando Dashboard de Monitoramento Grafana"
            else
                echo "Deploying Grafana Monitoring Dashboard"
            fi
            ;;
        "service_mesh")
            if [ "$LANG" = "pt" ]; then
                echo "Configurando malha de serviços"
            else
                echo "Configuring service mesh"
            fi
            ;;
        "app_layer_success")
            if [ "$LANG" = "pt" ]; then
                echo "Camada de aplicação implantada com sucesso"
            else
                echo "Application layer deployed successfully"
            fi
            ;;
        "final_verification")
            if [ "$LANG" = "pt" ]; then
                echo "REALIZANDO VERIFICAÇÃO FINAL DO SISTEMA..."
            else
                echo "PERFORMING FINAL SYSTEM VERIFICATION..."
            fi
            ;;
        "scanning_services")
            if [ "$LANG" = "pt" ]; then
                echo "Escaneando todos os serviços implantados..."
            else
                echo "Scanning all deployed services..."
            fi
            ;;
        "collecting_status")
            if [ "$LANG" = "pt" ]; then
                echo "Coletando informações de status dos serviços"
            else
                echo "Collecting service status information"
            fi
            ;;
        "identifying_issues")
            if [ "$LANG" = "pt" ]; then
                echo "Identificando serviços com problemas de implantação..."
            else
                echo "Identifying services with deployment issues..."
            fi
            ;;
        "services_initializing")
            if [ "$LANG" = "pt" ]; then
                echo "Alguns serviços ainda estão inicializando:"
            else
                echo "Some services are still initializing:"
            fi
            ;;
        "all_operational")
            if [ "$LANG" = "pt" ]; then
                echo "Todos os serviços estão operacionais"
            else
                echo "All services are operational"
            fi
            ;;
        "docker_daemon_start")
            if [ "$LANG" = "pt" ]; then
                echo "Aguardando daemon Docker iniciar..."
            else
                echo "Waiting for Docker daemon to start..."
            fi
            ;;
        "evolution_db_ensure")
            if [ "$LANG" = "pt" ]; then
                echo "Garantindo que banco Evolution API existe..."
            else
                echo "Ensuring Evolution API database exists..."
            fi
            ;;
        "ipv6_detected")
            if [ "$LANG" = "pt" ]; then
                echo "Não foi possível detectar IP público, usando configuração padrão"
            else
                echo "Could not detect public IP, using default configuration"
            fi
            ;;
        "ipv6_local_use")
            if [ "$LANG" = "pt" ]; then
                echo "Usando endereço IPv6 local:"
            else
                echo "Using local IPv6 address:"
            fi
            ;;
        *)
            echo "$key"
            ;;
    esac
}

# Loading animation
loading_animation() {
    local duration="$1"
    local message="$2"
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        for (( i=0; i<${#chars}; i++ )); do
            printf "\r${CYAN}${BOLD}[${chars:$i:1}]${NC} ${CYAN}$message${NC}"
            sleep 0.1
        done
    done
    printf "\r${GREEN}${BOLD}[✓]${NC} ${GREEN}$message - Complete${NC}\n"
}

# Progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${CYAN}${BOLD}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)${NC}" "$percentage" "$current" "$total"
    
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

# Clear screen and show banner
clear

# ASCII Art Banner
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
echo -e "${CYAN}${BOLD}                    AUTOMATED INFRASTRUCTURE DEPLOYMENT SYSTEM${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo

# Language Selection
echo -e "${WHITE}${BOLD}Welcome! / Bem-vindos!${NC}"
echo
echo -e "${CYAN}Please choose your language / Por favor, escolha seu idioma:${NC}"
echo -e "${GREEN}${BOLD}[1]${NC} ${GREEN}English${NC}"
echo -e "${GREEN}${BOLD}[2]${NC} ${GREEN}Português${NC}"
echo
echo -ne "${GREEN}${BOLD}language@caixapreta:~$ ${NC}"
read LANGUAGE_CHOICE

# Set language variables
if [ "$LANGUAGE_CHOICE" = "2" ]; then
    LANG="pt"
    print_matrix "INICIALIZANDO CAIXA PRETA STACK v2.0..."
    sleep 1
    print_hacker "Autor: Hudson Argollo aka getrules aka neverdie"
    print_hacker "Sistema: Orquestração Docker Swarm"
    print_hacker "Stack: n8n + MEGA + Evolution API + Traefik + Monitoramento"
    echo
    print_hacker "Executando verificações de segurança e compatibilidade..."
    loading_animation 2 "Executando diagnósticos do sistema"
else
    LANG="en"
    print_matrix "INITIALIZING CAIXA PRETA STACK v2.0..."
    sleep 1
    print_hacker "Author: Hudson Argollo aka getrules aka neverdie"
    print_hacker "System: Docker Swarm Orchestration"
    print_hacker "Stack: n8n + MEGA + Evolution API + Traefik + Monitoring"
    echo
    print_hacker "Performing security and compatibility checks..."
    loading_animation 2 "Running system diagnostics"
fi

# 1. Verificação de Requisitos
print_info "$(msg "root_check")"
if [ "$EUID" -ne 0 ]; then 
  print_error "$(msg "root_error")"
  echo -e "${RED}${BOLD}$(msg "root_terminating")${NC}"
  exit 1
fi
print_success "$(msg "root_success")"

echo
print_matrix "$(msg "config_mode")"
echo

# Solicitar domínio base
echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│$(msg "domain_config")│${NC}"
echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo
print_hacker "$(msg "enter_domain")"
echo -ne "${GREEN}${BOLD}domain@caixapreta:~$ ${NC}"
read DOMAIN

print_hacker "$(msg "enter_email")"
echo -ne "${GREEN}${BOLD}ssl@caixapreta:~$ ${NC}"
read EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    print_error "$(msg "config_required")"
    echo -e "${RED}${BOLD}$(msg "aborting")${NC}"
    exit 1
fi

print_success "$(msg "config_accepted")"
if [ "$LANG" = "pt" ]; then
    print_info "Domínio: $DOMAIN"
    print_info "Email SSL: $EMAIL"
else
    print_info "Domain: $DOMAIN"
    print_info "SSL Email: $EMAIL"
fi
echo

loading_animation 2 "$(msg "validating_config")"

# 2. Atualização do Sistema e Instalação de Dependências
echo
print_matrix "$(msg "system_upgrade")"
echo

print_hacker "$(msg "updating_repos")"
loading_animation 1 "$(msg "fetching_packages")"

print_hacker "$(msg "installing_deps")"
apt update >/dev/null 2>&1 && apt upgrade -y >/dev/null 2>&1

# Progress bar simulation for package installation
packages=("curl" "wget" "git" "jq" "ufw" "unzip")
total_packages=${#packages[@]}

for i in "${!packages[@]}"; do
    progress_bar $((i+1)) $total_packages
    apt install -y "${packages[$i]}" >/dev/null 2>&1
    sleep 0.5
done

print_success "$(msg "deps_success")"

# 3. Instalação do Docker
echo
print_matrix "$(msg "docker_deploy")"
echo

if ! command -v docker &> /dev/null; then
    print_hacker "$(msg "docker_installing")"
    loading_animation 2 "$(msg "docker_downloading")"
    
    curl -fsSL https://get.docker.com -o get-docker.sh >/dev/null 2>&1
    print_hacker "$(msg "docker_executing")"
    sh get-docker.sh >/dev/null 2>&1
    rm get-docker.sh
    
    print_success "$(msg "docker_success")"
    
    # Start Docker service after installation
    systemctl start docker >/dev/null 2>&1
    systemctl enable docker >/dev/null 2>&1
    
    # Wait for Docker to be ready
    print_info "$(msg "docker_waiting")"
    sleep 5
    
else
    print_success "$(msg "docker_exists")"
fi

# Verify Docker is working
print_info "$(msg "docker_verifying")"
if ! docker --version >/dev/null 2>&1; then
    print_error "Docker command not found after installation"
    exit 1
fi

# Test Docker daemon connection
print_info "$(msg "docker_daemon_check")"
if ! docker info >/dev/null 2>&1; then
    print_warning "Docker daemon not responding, attempting to start..."
    systemctl start docker >/dev/null 2>&1
    sleep 5
    
    if ! docker info >/dev/null 2>&1; then
        print_error "$(msg "docker_daemon_error")"
        print_info "$(msg "docker_daemon_info")"
        echo
        print_info "$(msg "docker_quick_fix")"
        echo "1. Run the Docker fix script:"
        echo "   wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-docker.sh"
        echo "   chmod +x fix-docker.sh && sudo ./fix-docker.sh"
        echo
        echo "2. Manual fix:"
        echo "   sudo systemctl start docker"
        echo "   sudo chmod 666 /var/run/docker.sock"
        echo
        exit 1
    fi
fi

print_success "$(msg "docker_ready")"

# 4. Inicialização do Docker Swarm
echo
print_matrix "$(msg "swarm_init")"
echo

if ! docker info | grep -q "Swarm: active"; then
    print_hacker "$(msg "swarm_configuring")"
    
    # Detect both IPv4 and IPv6 addresses
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)
    PUBLIC_IPV6=$(curl -s -6 ifconfig.me 2>/dev/null || curl -s -6 ipinfo.io/ip 2>/dev/null)
    
    # Try IPv4 first, then IPv6, then default
    if [ -n "$PUBLIC_IP" ] && [[ "$PUBLIC_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_info "$(msg "swarm_ip_detected") $PUBLIC_IP (IPv4)"
        ADVERTISE_ADDR="$PUBLIC_IP"
    elif [ -n "$PUBLIC_IPV6" ]; then
        print_info "$(msg "swarm_ip_detected") $PUBLIC_IPV6 (IPv6)"
        # For IPv6, we need to use the interface IP instead of public IP
        # Get the main network interface IPv6 address
        LOCAL_IPV6=$(ip -6 addr show | grep 'inet6.*global' | head -1 | awk '{print $2}' | cut -d'/' -f1)
        if [ -n "$LOCAL_IPV6" ]; then
            ADVERTISE_ADDR="[$LOCAL_IPV6]"
            print_info "$(msg "ipv6_local_use") $LOCAL_IPV6"
        else
            ADVERTISE_ADDR=""
            print_warning "$(msg "ipv6_detected")"
        fi
    else
        print_warning "$(msg "ipv6_detected")"
        ADVERTISE_ADDR=""
    fi
    
    loading_animation 2 "$(msg "swarm_initializing")"
    
    if [ -n "$ADVERTISE_ADDR" ]; then
        if docker swarm init --advertise-addr "$ADVERTISE_ADDR" >/dev/null 2>&1; then
            print_success "$(msg "swarm_success")"
        else
            print_error "$(msg "swarm_failed")"
            print_info "$(msg "swarm_issues")"
            print_info "  → Network connectivity issues"
            print_info "  → Firewall blocking Docker ports"
            print_info "  → IP address detection problems"
            echo
            print_info "$(msg "swarm_alternative")"
            
            # Try without specific IP
            if docker swarm init >/dev/null 2>&1; then
                print_success "$(msg "swarm_default_success")"
            else
                print_error "$(msg "swarm_complete_failure")"
                print_info "$(msg "swarm_manual_fix")"
                exit 1
            fi
        fi
    else
        # Try without specific IP
        if docker swarm init >/dev/null 2>&1; then
            print_success "$(msg "swarm_default_success")"
        else
            print_error "$(msg "swarm_complete_failure")"
            print_info "$(msg "swarm_manual_fix")"
            exit 1
        fi
    fi
else
    print_success "$(msg "swarm_active")"
fi

# 4.1. Configuração de permissões do Docker
print_hacker "$(msg "docker_security")"

# Ensure Docker service is running
systemctl start docker >/dev/null 2>&1
systemctl enable docker >/dev/null 2>&1

# Wait for Docker daemon to be ready
print_info "$(msg "docker_daemon_start")"
for i in {1..30}; do
    if docker info >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Check if Docker is responding
if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon failed to start properly"
    print_info "Attempting to fix Docker socket permissions..."
    
    # Fix socket permissions
    chmod 666 /var/run/docker.sock 2>/dev/null || true
    
    # Restart Docker service
    systemctl restart docker
    
    # Wait again
    sleep 10
    
    # Final check
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is still not responding. Please check Docker installation."
        print_info "Try running: systemctl status docker"
        exit 1
    fi
fi

chmod 666 /var/run/docker.sock 2>/dev/null || true

loading_animation 3 "$(msg "security_applying")"
print_success "$(msg "security_success")"

# 5. Criação de Redes do Swarm
echo
print_matrix "$(msg "network_infra")"
echo

print_hacker "$(msg "network_cleaning")"
# Remove networks if they exist to avoid conflicts
docker network rm traefik-public internal-net 2>/dev/null || true
sleep 1

print_hacker "$(msg "network_creating")"
loading_animation 1 "$(msg "network_traefik")"
docker network create --driver overlay traefik-public >/dev/null 2>&1

loading_animation 1 "$(msg "network_internal")"
docker network create --driver overlay internal-net >/dev/null 2>&1

print_success "$(msg "network_success")"

# 6. Preparação de Diretórios de Dados
echo
print_matrix "$(msg "data_persistence")"
echo

print_hacker "$(msg "data_creating")"
directories=("traefik" "portainer" "n8n" "redis_n8n" "redis_mega" "postgres" "minio" "mega" "evolution" "grafana")

for i in "${!directories[@]}"; do
    mkdir -p "/data/${directories[$i]}" 2>/dev/null
    progress_bar $((i+1)) ${#directories[@]}
    sleep 0.2
done

print_hacker "$(msg "ssl_config")"
touch /data/traefik/acme.json
chmod 600 /data/traefik/acme.json

print_hacker "$(msg "permissions_setting")"
loading_animation 1 "$(msg "permissions_applying")"

# Set proper permissions for specific services
print_info "$(msg "permissions_setting")"

# Create and set Grafana permissions properly
mkdir -p /data/grafana
chown -R 472:472 /data/grafana
chmod -R 755 /data/grafana

# Create and set MinIO permissions
mkdir -p /data/minio
chown -R 1001:1001 /data/minio
chmod -R 755 /data/minio

# Create and set n8n permissions
mkdir -p /data/n8n
chown -R 1000:1000 /data/n8n
chmod -R 755 /data/n8n

# Create and set Evolution API permissions
mkdir -p /data/evolution
chown -R 1000:1000 /data/evolution
chmod -R 755 /data/evolution

# Set general permissions
chmod -R 755 /data
chown -R root:root /data/traefik /data/portainer >/dev/null 2>&1
chmod 600 /data/traefik/acme.json

print_success "$(msg "data_success")"

# 7. Configuração do Traefik (Proxy Reverso com SSL)
echo
print_matrix "$(msg "traefik_config")"
echo

print_hacker "$(msg "traefik_generating")"
loading_animation 2 "$(msg "ssl_automation")"

cat <<EOF > /data/traefik/traefik.yml
api:
  dashboard: true
entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: :443
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    swarmMode: true
    exposedByDefault: false
    network: traefik-public
certificatesResolvers:
  letsencrypt:
    acme:
      email: $EMAIL
      storage: acme.json
      httpChallenge:
        entryPoint: web
EOF

print_success "$(msg "traefik_success")"

# 8. Deploy das Stacks
echo
print_matrix "$(msg "deployment_sequence")"
echo

# Wait for Docker to be fully ready
loading_animation 3 "$(msg "deployment_preparing")"

print_hacker "$(msg "core_deploying")"
cat <<EOF > swarm-core.yml
version: '3.8'
services:
  traefik:
    image: traefik:v2.10
    command:
      - "--configfile=/etc/traefik/traefik.yml"
    ports:
      - "80:80"
      - "443:443"
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
        delay: 5s
        max_attempts: 3
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.traefik.rule=Host(\`traefik.$DOMAIN\`)"
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
        delay: 5s
        max_attempts: 3
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.portainer.rule=Host(\`portainer.$DOMAIN\`)"
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik-public:
    external: true
EOF

docker stack deploy -c swarm-core.yml core >/dev/null 2>&1

loading_animation 8 "$(msg "traefik_deploying")"
loading_animation 7 "$(msg "portainer_deploying")"

print_success "$(msg "core_success")"

# Verificar se os serviços estão rodando
print_info "$(msg "verifying_core")"
docker service ls | grep core

# STACK 2: Redis Dedicados e Banco de Dados (Postgres 15 para suporte a V4/pgvector)
cat <<EOF > swarm-db.yml
version: '3.8'
services:
  redis-n8n:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - /data/redis_n8n:/data
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      replicas: 1

  redis-mega:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - /data/redis_mega:/data
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      replicas: 1

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: caixapretastack2626
      POSTGRES_DB: main_db
      POSTGRES_USER: postgres
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      replicas: 1

networks:
  internal-net:
    external: true
EOF

docker stack deploy -c swarm-db.yml db >/dev/null 2>&1

loading_animation 10 "$(msg "db_deploying")"
loading_animation 8 "$(msg "redis_deploying")"
loading_animation 5 "$(msg "data_persistence_config")"

print_success "$(msg "db_success")"

# Verificar se os serviços de banco estão rodando
print_info "$(msg "db_status_check")"
docker service ls | grep db

# STACK 3: Automação (n8n em modo Queue)
cat <<EOF > swarm-automation.yml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_HOST=n8n.$DOMAIN
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://n8n.$DOMAIN/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=main_db
      - DB_POSTGRESDB_HOST=db_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - N8N_ENCRYPTION_KEY=caixapretastack2626
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=db_redis-n8n
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.n8n.rule=Host(\`n8n.$DOMAIN\`)"
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
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      replicas: 2

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

docker stack deploy -c swarm-automation.yml automation >/dev/null 2>&1

loading_animation 8 "$(msg "automation_deploying")"
loading_animation 6 "$(msg "workflow_workers")"
loading_animation 4 "$(msg "queue_system")"

print_success "$(msg "automation_success")"

# Verificar se os serviços de automação estão rodando
print_info "$(msg "automation_status_check")"
docker service ls | grep automation

echo
print_matrix "$(msg "mega_db_prep")"
echo

# Wait for PostgreSQL to be ready
print_hacker "$(msg "postgres_waiting")"
loading_animation 5 "$(msg "db_connections")"

# Wait for PostgreSQL service to be fully ready
sleep 15

# Check if PostgreSQL is responding
print_info "$(msg "postgres_test")"
for i in {1..30}; do
    # Check if PostgreSQL service is running with correct replicas
    if docker service ls --format "{{.Name}} {{.Replicas}}" | grep "db_postgres" | grep -q "1/1"; then
        print_success "$(msg "postgres_ready")"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "$(msg "postgres_failed")"
        # Don't exit, continue with deployment as PostgreSQL might still work
        print_warning "Continuing deployment - PostgreSQL service appears to be running"
        break
    fi
    sleep 2
done

# Initialize Chatwoot database
print_hacker "$(msg "chatwoot_init")"
loading_animation 3 "$(msg "db_init_prep")"

# Wait a bit more for PostgreSQL to be fully ready
sleep 10

docker run --rm --network internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db \
  -e RAILS_ENV=production \
  -e PGPASSWORD=caixapretastack2626 \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare >/dev/null 2>&1 || print_warning "Database already initialized or initialization failed - continuing..."

# Create Evolution API database
print_hacker "$(msg "evolution_db_create")"
docker run --rm --network internal-net \
  -e PGPASSWORD=caixapretastack2626 \
  postgres:15-alpine \
  psql -h db_postgres -U postgres -c "CREATE DATABASE evolution_db;" 2>/dev/null || print_warning "Evolution database already exists - continuing..."

print_success "$(msg "db_schemas_success")"

echo
print_matrix "$(msg "app_layer_deploy")"
echo

print_hacker "$(msg "apps_deploying")"

# First, ensure Evolution database exists
print_info "$(msg "evolution_db_ensure")"
docker run --rm --network internal-net \
  -e PGPASSWORD=caixapretastack2626 \
  postgres:15-alpine \
  psql -h db_postgres -U postgres -c "SELECT 1 FROM pg_database WHERE datname='evolution_db';" | grep -q 1 || \
docker run --rm --network internal-net \
  -e PGPASSWORD=caixapretastack2626 \
  postgres:15-alpine \
  psql -h db_postgres -U postgres -c "CREATE DATABASE evolution_db;" 2>/dev/null || true

cat <<EOF > swarm-apps.yml
version: '3.8'
services:
  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evolution.$DOMAIN
      - DATABASE_PROVIDER=postgresql
      - DATABASE_ENABLED=true
      - DATABASE_CONNECTION_URI=postgresql://postgres:caixapretastack2626@db_postgres:5432/evolution_db
      - DATABASE_CONNECTION_STRING=postgresql://postgres:caixapretastack2626@db_postgres:5432/evolution_db
      - REDIS_ENABLED=true
      - REDIS_URI=redis://db_redis-n8n:6379
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - WEBHOOK_GLOBAL_URL=https://evolution.$DOMAIN
      - CONFIG_SESSION_SECRET=caixapretastack2626
      - QRCODE_LIMIT=30
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
    volumes:
      - /data/evolution:/evolution/instances
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.evolution.rule=Host(\`evolution.$DOMAIN\`)"
        - "traefik.http.routers.evolution.entrypoints=websecure"
        - "traefik.http.routers.evolution.tls.certresolver=letsencrypt"
        - "traefik.http.services.evolution.loadbalancer.server.port=8080"

  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db
      - REDIS_URL=redis://db_redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - FRONTEND_URL=https://mega.$DOMAIN
      - FORCE_SSL=true
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true
      - WOO_REDIS_URL=redis://db_redis-mega:6379/1
      - WOO_REDIS_HOST=db_redis-mega
      - WOO_REDIS_PORT=6379
      - WOO_REDIS_DB=1
      - INSTALLATION_ENV=docker
    volumes:
      - /data/mega/storage:/app/storage
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.mega.rule=Host(\`mega.$DOMAIN\`)"
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
      - WOO_REDIS_URL=redis://db_redis-mega:6379/1
      - WOO_REDIS_HOST=db_redis-mega
      - WOO_REDIS_PORT=6379
      - WOO_REDIS_DB=1
    networks:
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001" --address ":9000"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
      - MINIO_SERVER_URL=https://s3.$DOMAIN
      - MINIO_BROWSER_REDIRECT_URL=https://minio.$DOMAIN
    volumes:
      - /data/minio:/data
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
        # S3 API endpoint
        - "traefik.http.routers.minio-api.rule=Host(\`s3.$DOMAIN\`)"
        - "traefik.http.routers.minio-api.entrypoints=websecure"
        - "traefik.http.routers.minio-api.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-api.service=minio-api"
        - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
        # Console endpoint
        - "traefik.http.routers.minio-console.rule=Host(\`minio.$DOMAIN\`)"
        - "traefik.http.routers.minio-console.entrypoints=websecure"
        - "traefik.http.routers.minio-console.tls.certresolver=letsencrypt"
        - "traefik.http.routers.minio-console.service=minio-console"
        - "traefik.http.services.minio-console.loadbalancer.server.port=9001"

  grafana:
    image: grafana/grafana:latest
    user: "472:472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=caixapretastack2626
      - GF_SERVER_ROOT_URL=https://grafana.$DOMAIN
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
      - GF_PATHS_DATA=/var/lib/grafana
      - GF_PATHS_LOGS=/var/log/grafana
      - GF_PATHS_PLUGINS=/var/lib/grafana/plugins
      - GF_PATHS_PROVISIONING=/etc/grafana/provisioning
    volumes:
      - /data/grafana:/var/lib/grafana
    networks:
      - traefik-public
      - internal-net
    deploy:
      placement:
        constraints: [node.role == manager]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 5
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana.rule=Host(\`grafana.$DOMAIN\`)"
        - "traefik.http.routers.grafana.entrypoints=websecure"
        - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
        - "traefik.http.services.grafana.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
  internal-net:
    external: true
EOF

docker stack deploy -c swarm-apps.yml apps >/dev/null 2>&1

loading_animation 10 "$(msg "evolution_deploying")"
loading_animation 12 "$(msg "mega_deploying")"
loading_animation 8 "$(msg "minio_deploying")"
loading_animation 6 "$(msg "grafana_deploying")"
loading_animation 4 "$(msg "service_mesh")"

print_success "$(msg "app_layer_success")"

# Verificar se todos os serviços estão rodando
echo
print_matrix "$(msg "final_verification")"
echo

print_hacker "$(msg "scanning_services")"
loading_animation 3 "$(msg "collecting_status")"

docker service ls

print_hacker "$(msg "identifying_issues")"
FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)

if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_warning "$(msg "services_initializing")"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/" || true
else
    print_success "$(msg "all_operational")"
fi

# 9. Finalização
echo
echo -e "${GREEN}${BOLD}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    🚀 CAIXA PRETA STACK DEPLOYMENT COMPLETE! 🚀              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_matrix "MISSION ACCOMPLISHED - ALL SYSTEMS OPERATIONAL"
echo

print_success "Infrastructure deployment completed successfully!"
echo

echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│                    ACCESS ENDPOINTS                         │${NC}"
echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo

print_hacker "Portainer (Container Management): https://portainer.$DOMAIN"
print_hacker "Traefik Dashboard (Proxy Status): https://traefik.$DOMAIN"
print_hacker "n8n (Automation Engine): https://n8n.$DOMAIN"
print_hacker "Evolution API (WhatsApp): https://evolution.$DOMAIN"
print_hacker "MinIO Console (File Storage): https://minio.$DOMAIN"
print_hacker "MEGA (Customer Service): https://mega.$DOMAIN"
print_hacker "Grafana (Monitoring): https://grafana.$DOMAIN"

echo
echo -e "${YELLOW}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}${BOLD}│                    CRITICAL REMINDERS                       │${NC}"
echo -e "${YELLOW}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo

print_warning "DNS Configuration Required:"
print_info "  → Create DNS records for all subdomains pointing to this server"

# Show both IPv4 and IPv6 if available
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)
PUBLIC_IPV6=$(curl -s -6 ifconfig.me 2>/dev/null || curl -s -6 ipinfo.io/ip 2>/dev/null)

if [ -n "$PUBLIC_IP" ]; then
    print_info "  → Server IPv4: $PUBLIC_IP (create A records)"
fi

if [ -n "$PUBLIC_IPV6" ]; then
    print_info "  → Server IPv6: $PUBLIC_IPV6 (create AAAA records)"
fi

print_info "  → Required DNS records:"
print_info "    * portainer.$DOMAIN"
print_info "    * traefik.$DOMAIN"
print_info "    * n8n.$DOMAIN"
print_info "    * evolution.$DOMAIN"
print_info "    * minio.$DOMAIN"
print_info "    * s3.$DOMAIN"
print_info "    * mega.$DOMAIN"
print_info "    * grafana.$DOMAIN"

print_warning "SSL Certificate Generation:"
print_info "  → Let's Encrypt certificates will auto-generate (5-15 minutes)"
print_info "  → Monitor progress: docker service logs core_traefik"

print_warning "Security Notice:"
print_info "  → Change default passwords immediately after first login"
print_info "  → Configure firewall rules for production use"

echo
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}                           SYSTEM STATUS OVERVIEW${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"

docker service ls

echo
echo -e "${PURPLE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│                  TROUBLESHOOTING TOOLKIT                    │${NC}"
echo -e "${PURPLE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo

print_info "Service Status Check: docker service ls"
print_info "View Service Logs: docker service logs SERVICE_NAME"
print_info "Restart Service: docker service update --force SERVICE_NAME"
print_info "SSL Certificate Status: cat /data/traefik/acme.json"

echo
print_info "Validation Script: wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/validate-installation.sh"
print_info "MEGA Fix Script: wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-mega.sh"
print_info "Portainer Diagnostic: wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-portainer.sh"

# Verificar se há serviços com problemas
FAILED_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)
if [ "$FAILED_SERVICES" -gt 0 ]; then
    echo
    print_error "⚠️  ATTENTION: Some services failed to start properly:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/" || true
    echo
    print_warning "Execute troubleshooting commands above to investigate"
    print_warning "Wait 2-3 minutes and check again with: docker service ls"
else
    echo
    print_success "✅ ALL SYSTEMS OPERATIONAL - DEPLOYMENT SUCCESSFUL!"
fi

echo
echo -e "${GREEN}${BOLD}"
echo "CAIXA PRETA STACK v2.0 - READY FOR PRODUCTION"
echo -e "${NC}"

echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}                    Thank you for using CaixaPreta Stack!${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"

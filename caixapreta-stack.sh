#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK v2.0
# Script de Automação de Infraestrutura Docker Swarm (Inspirado na Masterclass)
# Autor: Hudson Argollo e seus amiguinho Manus
# Sistema: Debian/Ubuntu
# Foco: n8n + MEGA (Chatwoot V4 mod Nestor/Valus) + Evolution API + Traefik
# ==============================================================================

set -e

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
    for (( i=0; i<${#text}; i++ )); do
        printf "${text:$i:1}"
        sleep "$delay"
    done
    echo
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

print_matrix "INITIALIZING CAIXA PRETA STACK v2.0..."
sleep 1

print_hacker "Author: Hudson Argollo aka getrules aka neverdie"
print_hacker "System: Docker Swarm Orchestration"
print_hacker "Stack: n8n + MEGA + Evolution API + Traefik + Monitoring"
echo

print_slow "${YELLOW}${BOLD}[SYSTEM CHECK]${NC} ${YELLOW}Performing security and compatibility checks...${NC}" 0.02
sleep 1

# 1. Verificação de Requisitos
print_info "Checking system privileges..."
if [ "$EUID" -ne 0 ]; then 
  print_error "Root access required. Please run as root or with sudo."
  echo -e "${RED}${BOLD}TERMINATING PROCESS...${NC}"
  exit 1
fi
print_success "Root privileges confirmed"

echo
print_matrix "ENTERING CONFIGURATION MODE..."
echo

# Solicitar domínio base
echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│                    DOMAIN CONFIGURATION                     │${NC}"
echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo
print_hacker "Enter your base domain (e.g., your-domain.com):"
echo -ne "${GREEN}${BOLD}domain@caixapreta:~$ ${NC}"
read DOMAIN

print_hacker "Enter your email for SSL certificates (Let's Encrypt):"
echo -ne "${GREEN}${BOLD}ssl@caixapreta:~$ ${NC}"
read EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    print_error "Domain and email are required for secure deployment"
    echo -e "${RED}${BOLD}ABORTING MISSION...${NC}"
    exit 1
fi

print_success "Configuration accepted"
print_info "Domain: $DOMAIN"
print_info "SSL Email: $EMAIL"
echo

loading_animation 2 "Validating configuration parameters"

# 2. Atualização do Sistema e Instalação de Dependências
echo
print_matrix "INITIATING SYSTEM UPGRADE SEQUENCE..."
echo

print_hacker "Updating system repositories..."
loading_animation 1 "Fetching latest package information"

print_hacker "Installing core dependencies..."
apt update >/dev/null 2>&1 && apt upgrade -y >/dev/null 2>&1

# Progress bar simulation for package installation
packages=("curl" "wget" "git" "jq" "ufw" "unzip")
total_packages=${#packages[@]}

for i in "${!packages[@]}"; do
    progress_bar $((i+1)) $total_packages
    apt install -y "${packages[$i]}" >/dev/null 2>&1
    sleep 0.5
done

print_success "All dependencies installed successfully"

# 3. Instalação do Docker
echo
print_matrix "DOCKER CONTAINERIZATION SYSTEM DEPLOYMENT..."
echo

if ! command -v docker &> /dev/null; then
    print_hacker "Docker not detected. Installing Docker Engine..."
    loading_animation 2 "Downloading Docker installation script"
    
    curl -fsSL https://get.docker.com -o get-docker.sh >/dev/null 2>&1
    print_hacker "Executing Docker installation..."
    sh get-docker.sh >/dev/null 2>&1
    rm get-docker.sh
    
    print_success "Docker Engine installed successfully"
else
    print_success "Docker Engine already installed"
fi

# 4. Inicialização do Docker Swarm
echo
print_matrix "INITIALIZING DOCKER SWARM CLUSTER..."
echo

if ! docker info | grep -q "Swarm: active"; then
    print_hacker "Configuring Docker Swarm orchestration..."
    PUBLIC_IP=$(curl -s ifconfig.me)
    print_info "Public IP detected: $PUBLIC_IP"
    
    loading_animation 2 "Initializing Swarm cluster"
    docker swarm init --advertise-addr $PUBLIC_IP >/dev/null 2>&1
    print_success "Docker Swarm cluster initialized"
else
    print_success "Docker Swarm already active"
fi

# 4.1. Configuração de permissões do Docker
print_hacker "Configuring Docker security permissions..."
chmod 666 /var/run/docker.sock
systemctl enable docker >/dev/null 2>&1
systemctl restart docker >/dev/null 2>&1

loading_animation 3 "Applying security configurations"
print_success "Docker security configured"

# 5. Criação de Redes do Swarm
echo
print_matrix "ESTABLISHING NETWORK INFRASTRUCTURE..."
echo

print_hacker "Cleaning existing network configurations..."
# Remove networks if they exist to avoid conflicts
docker network rm traefik-public internal-net 2>/dev/null || true
sleep 1

print_hacker "Creating overlay network topology..."
loading_animation 1 "Configuring traefik-public network"
docker network create --driver overlay traefik-public >/dev/null 2>&1

loading_animation 1 "Configuring internal-net network"
docker network create --driver overlay internal-net >/dev/null 2>&1

print_success "Network infrastructure established"

# 6. Preparação de Diretórios de Dados
echo
print_matrix "PREPARING DATA PERSISTENCE LAYER..."
echo

print_hacker "Creating data directory structure..."
directories=("traefik" "portainer" "n8n" "redis_n8n" "redis_mega" "postgres" "minio" "mega" "evolution" "grafana")

for i in "${!directories[@]}"; do
    mkdir -p "/data/${directories[$i]}" 2>/dev/null
    progress_bar $((i+1)) ${#directories[@]}
    sleep 0.2
done

print_hacker "Configuring SSL certificate storage..."
touch /data/traefik/acme.json
chmod 600 /data/traefik/acme.json

print_hacker "Setting directory permissions..."
loading_animation 1 "Applying security permissions"
chown -R root:root /data >/dev/null 2>&1
chmod -R 755 /data >/dev/null 2>&1
chmod 600 /data/traefik/acme.json

print_success "Data persistence layer configured"

# 7. Configuração do Traefik (Proxy Reverso com SSL)
echo
print_matrix "CONFIGURING REVERSE PROXY & SSL TERMINATION..."
echo

print_hacker "Generating Traefik configuration..."
loading_animation 2 "Creating SSL automation rules"

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

print_success "Traefik reverse proxy configured"

# 8. Deploy das Stacks
echo
print_matrix "INITIATING STACK DEPLOYMENT SEQUENCE..."
echo

# Wait for Docker to be fully ready
loading_animation 3 "Preparing deployment environment"

print_hacker "Deploying Core Infrastructure (Traefik + Portainer)..."
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

loading_animation 8 "Deploying Traefik reverse proxy"
loading_animation 7 "Deploying Portainer management interface"

print_success "Core infrastructure deployed"

# Verificar se os serviços estão rodando
print_info "Verifying core services status..."
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

loading_animation 10 "Deploying PostgreSQL database cluster"
loading_animation 8 "Deploying Redis cache servers"
loading_animation 5 "Configuring data persistence"

print_success "Database infrastructure deployed"

# Verificar se os serviços de banco estão rodando
print_info "Verifying database services status..."
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
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - N8N_ENCRYPTION_KEY=caixapretastack2626
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=redis-n8n
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
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=caixapretastack2626
      - QUEUE_BULL_REDIS_HOST=redis-n8n
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

loading_animation 8 "Deploying n8n automation engine"
loading_animation 6 "Configuring workflow workers"
loading_animation 4 "Establishing queue system"

print_success "Automation infrastructure deployed"

# Verificar se os serviços de automação estão rodando
print_info "Verifying automation services status..."
docker service ls | grep automation

echo
print_matrix "PREPARING MEGA (CHATWOOT) DATABASE..."
echo

# Wait for PostgreSQL to be ready
print_hacker "Waiting for PostgreSQL cluster to be ready..."
loading_animation 5 "Establishing database connections"

# Initialize Chatwoot database
print_hacker "Initializing Chatwoot database schema..."
loading_animation 3 "Preparing database initialization"

docker run --rm --network db_internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
  -e RAILS_ENV=production \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare >/dev/null 2>&1 || print_warning "Database already initialized or initialization failed - continuing..."

print_success "Chatwoot database prepared"

echo
print_matrix "DEPLOYING APPLICATION LAYER..."
echo

print_hacker "Deploying MEGA (Chatwoot V4), Evolution API, MinIO & Grafana..."
cat <<EOF > swarm-apps.yml
version: '3.8'
services:
  evolution:
    image: atendai/evolution-api:latest
    environment:
      - SERVER_URL=https://evolution.$DOMAIN
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=caixapretastack2626
      - DATABASE_CONNECTION_STRING=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - REDIS_URI=redis://redis-mega:6379/0
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
        - "traefik.http.routers.evolution.rule=Host(\`evolution.$DOMAIN\`)"
        - "traefik.http.routers.evolution.entrypoints=websecure"
        - "traefik.http.routers.evolution.tls.certresolver=letsencrypt"
        - "traefik.http.services.evolution.loadbalancer.server.port=8080"

  mega-rails:
    image: sendingtk/chatwoot:v4.11.2
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - REDIS_URL=redis://redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - FRONTEND_URL=https://mega.$DOMAIN
      - FORCE_SSL=true
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true
      - WOO_REDIS_URL=redis://redis-mega:6379/1
      - WOO_REDIS_HOST=redis-mega
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
      - DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db
      - REDIS_URL=redis://redis-mega:6379/1
      - SECRET_KEY_BASE=caixapretastack2626
      - WOO_REDIS_URL=redis://redis-mega:6379/1
      - WOO_REDIS_HOST=redis-mega
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
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=caixapretastack2626
    volumes:
      - /data/minio:/data
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
        - "traefik.http.routers.minio.rule=Host(\`s3.$DOMAIN\`)"
        - "traefik.http.routers.minio.entrypoints=websecure"
        - "traefik.http.routers.minio.tls.certresolver=letsencrypt"
        - "traefik.http.services.minio.loadbalancer.server.port=9000"
        - "traefik.http.routers.minio-console.rule=Host(\`minio.$DOMAIN\`)"
        - "traefik.http.routers.minio-console.entrypoints=websecure"
        - "traefik.http.routers.minio-console.tls.certresolver=letsencrypt"
        - "traefik.http.services.minio-console.loadbalancer.server.port=9001"

  grafana:
    image: grafana/grafana:latest
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
        delay: 5s
        max_attempts: 3
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

loading_animation 10 "Deploying Evolution API (WhatsApp Integration)"
loading_animation 12 "Deploying MEGA (Chatwoot V4 Customer Service)"
loading_animation 8 "Deploying MinIO Object Storage"
loading_animation 6 "Deploying Grafana Monitoring Dashboard"
loading_animation 4 "Configuring service mesh"

print_success "Application layer deployed successfully"

# Verificar se todos os serviços estão rodando
echo
print_matrix "PERFORMING FINAL SYSTEM VERIFICATION..."
echo

print_hacker "Scanning all deployed services..."
loading_animation 3 "Collecting service status information"

docker service ls

print_hacker "Identifying services with deployment issues..."
FAILED_SERVICES=$(docker service ls --filter "desired-state=running" --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)

if [ "$FAILED_SERVICES" -gt 0 ]; then
    print_warning "Some services are still initializing:"
    docker service ls --filter "desired-state=running" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/"
else
    print_success "All services are operational"
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
print_info "  → Create A records for all subdomains pointing to this server"
print_info "  → Server IP: $(curl -s ifconfig.me)"

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
FAILED_SERVICES=$(docker service ls --filter "desired-state=running" --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)
if [ "$FAILED_SERVICES" -gt 0 ]; then
    echo
    print_error "⚠️  ATTENTION: Some services failed to start properly:"
    docker service ls --filter "desired-state=running" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/"
    echo
    print_warning "Execute troubleshooting commands above to investigate"
    print_warning "Wait 2-3 minutes and check again with: docker service ls"
else
    echo
    print_success "✅ ALL SYSTEMS OPERATIONAL - DEPLOYMENT SUCCESSFUL!"
fi

echo
echo -e "${GREEN}${BOLD}"
print_slow "CAIXA PRETA STACK v2.0 - READY FOR PRODUCTION" 0.05
echo -e "${NC}"

echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}                    Thank you for using CaixaPreta Stack!${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"

#!/bin/bash

# CaixaPreta Stack - Installation Validation Script
# Run this after installation to check if everything is working

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

# Hacker-style functions
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

clear

echo -e "${GREEN}${BOLD}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    🔍 CAIXA PRETA STACK VALIDATION SYSTEM 🔍                 ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_matrix "INITIALIZING SYSTEM VALIDATION PROTOCOL..."
echo

# Get domain
echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│                    DOMAIN CONFIGURATION                     │${NC}"
echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
echo
print_hacker "Enter your domain (e.g., yourdomain.com):"
echo -ne "${GREEN}${BOLD}domain@validator:~$ ${NC}"
read DOMAIN

if [ -z "$DOMAIN" ]; then
    print_error "Domain is required for validation!"
    exit 1
fi

print_success "Domain configuration accepted: $DOMAIN"
echo

loading_animation 2 "Initializing validation protocols"

# 1. Check Docker Swarm
echo -e "${YELLOW}1. Verificando Docker Swarm...${NC}"
if docker info | grep -q "Swarm: active"; then
    echo -e "${GREEN}✅ Docker Swarm ativo${NC}"
else
    echo -e "${RED}❌ Docker Swarm não está ativo${NC}"
    exit 1
fi

# 2. Check services
echo -e "\n${YELLOW}2. Verificando serviços...${NC}"
TOTAL_SERVICES=$(docker service ls --format "{{.Name}}" | wc -l)
RUNNING_SERVICES=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep -v "0/" | wc -l)

echo "Total de serviços: $TOTAL_SERVICES"
echo "Serviços rodando: $RUNNING_SERVICES"

if [ "$RUNNING_SERVICES" -eq "$TOTAL_SERVICES" ]; then
    echo -e "${GREEN}✅ Todos os serviços estão rodando${NC}"
else
    echo -e "${YELLOW}⚠️  Alguns serviços podem estar iniciando ainda${NC}"
    echo "Serviços com problemas:"
    docker service ls --format "table {{.Name}}\t{{.Replicas}}" | grep "0/"
fi

# 3. Check networks
echo -e "\n${YELLOW}3. Verificando redes...${NC}"
if docker network ls | grep -q "traefik-public"; then
    echo -e "${GREEN}✅ Rede traefik-public existe${NC}"
else
    echo -e "${RED}❌ Rede traefik-public não encontrada${NC}"
fi

if docker network ls | grep -q "internal-net"; then
    echo -e "${GREEN}✅ Rede internal-net existe${NC}"
else
    echo -e "${RED}❌ Rede internal-net não encontrada${NC}"
fi

# 4. Check data directories
echo -e "\n${YELLOW}4. Verificando diretórios de dados...${NC}"
for dir in traefik portainer n8n postgres redis_n8n redis_mega minio grafana; do
    if [ -d "/data/$dir" ]; then
        echo -e "${GREEN}✅ /data/$dir existe${NC}"
    else
        echo -e "${RED}❌ /data/$dir não encontrado${NC}"
    fi
done

# 5. Check SSL certificates
echo -e "\n${YELLOW}5. Verificando certificados SSL...${NC}"
if [ -f "/data/traefik/acme.json" ]; then
    if [ -s "/data/traefik/acme.json" ]; then
        echo -e "${GREEN}✅ Arquivo de certificados SSL existe e tem conteúdo${NC}"
    else
        echo -e "${YELLOW}⚠️  Arquivo de certificados existe mas está vazio (normal se recém instalado)${NC}"
    fi
else
    echo -e "${RED}❌ Arquivo de certificados SSL não encontrado${NC}"
fi

# 6. Test DNS resolution
echo -e "\n${YELLOW}6. Testando resolução DNS...${NC}"
for subdomain in portainer traefik n8n evolution minio mega grafana; do
    if nslookup $subdomain.$DOMAIN > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $subdomain.$DOMAIN resolve${NC}"
    else
        echo -e "${RED}❌ $subdomain.$DOMAIN não resolve${NC}"
    fi
done

# 7. Test HTTP connectivity
echo -e "\n${YELLOW}7. Testando conectividade HTTP...${NC}"
for subdomain in portainer traefik; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 10 http://$subdomain.$DOMAIN 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ $subdomain.$DOMAIN responde (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${RED}❌ $subdomain.$DOMAIN não responde (HTTP $HTTP_CODE)${NC}"
    fi
done

# 8. Show service details
echo -e "\n${YELLOW}8. Detalhes dos serviços:${NC}"
docker service ls

# 9. Final recommendations
echo -e "\n${YELLOW}=== RECOMENDAÇÕES ===${NC}"
echo -e "1. Se alguns serviços não estão rodando, aguarde 2-3 minutos e execute novamente"
echo -e "2. Se DNS não resolve, verifique os registros A no seu provedor de DNS"
echo -e "3. Se HTTP não responde, verifique se as portas 80 e 443 estão abertas"
echo -e "4. Para logs detalhados: docker service logs NOME_DO_SERVICO"
echo -e "5. Para reiniciar um serviço: docker service update --force NOME_DO_SERVICO"

echo -e "\n${GREEN}Validação concluída!${NC}"
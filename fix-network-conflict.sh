#!/bin/bash

# ==============================================================================
# INFRA CAIXA PRETA v2 - NETWORK CONFLICT FIX
# Quick fix for existing network conflicts with bilingual support
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
                echo "UTILITARIO DE CORRECAO DE CONFLITOS DE REDE"
            else
                echo "NETWORK CONFLICT FIX UTILITY"
            fi
            ;;
        "analyzing_networks")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Analisando redes Docker existentes..."
            else
                echo "Analyzing existing Docker networks..."
            fi
            ;;
        "network_exists_correct")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "rede existe (driver:"
            else
                echo "network exists (driver:"
            fi
            ;;
        "network_correct")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "e uma rede overlay correta"
            else
                echo "is correct overlay network"
            fi
            ;;
        "network_wrong_type")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "nao e uma rede overlay - precisa ser recriada"
            else
                echo "is not an overlay network - needs recreation"
            fi
            ;;
        "network_not_exist")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "rede nao existe"
            else
                echo "network does not exist"
            fi
            ;;
        "stopping_services")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Parando servicos que usam as redes..."
            else
                echo "Stopping services that use the networks..."
            fi
            ;;
        "services_stopped")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Servicos parados"
            else
                echo "Services stopped"
            fi
            ;;
        "waiting_services_stop")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Aguardando 10 segundos para os servicos pararem completamente..."
            else
                echo "Waiting 10 seconds for services to fully stop..."
            fi
            ;;
        "recreating_networks")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Recriando redes..."
            else
                echo "Recreating networks..."
            fi
            ;;
        "removing_recreating")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Removendo e recriando rede"
            else
                echo "Removing and recreating network"
            fi
            ;;
        "network_created_success")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "rede criada com sucesso"
            else
                echo "network created successfully"
            fi
            ;;
        "failed_create_network")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Falha ao criar rede"
            else
                echo "Failed to create network"
            fi
            ;;
        "verifying_config")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando configuracao da rede..."
            else
                echo "Verifying network configuration..."
            fi
            ;;
        "current_networks")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Redes Docker atuais:"
            else
                echo "Current Docker networks:"
            fi
            ;;
        "networks_configured")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Todas as redes estao configuradas corretamente"
            else
                echo "All networks are properly configured"
            fi
            ;;
        "config_still_incorrect")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Configuracao da rede ainda esta incorreta"
            else
                echo "Network configuration is still incorrect"
            fi
            ;;
        "fix_complete")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "UTILITARIO DE CORRECAO DE REDE CONCLUIDO"
            else
                echo "NETWORK FIX UTILITY COMPLETE"
            fi
            ;;
        "networks_ready")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Redes Docker estao agora configuradas corretamente!"
            else
                echo "Docker networks are now properly configured!"
            fi
            ;;
        "next_steps")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Proximos passos:"
            else
                echo "Next steps:"
            fi
            ;;
        "rerun_script")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "1. Execute novamente o script de instalacao: sudo ./caixapreta-stack.sh"
            else
                echo "1. Re-run the installation script: sudo ./caixapreta-stack.sh"
            fi
            ;;
        "no_conflicts")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "2. O script deve prosseguir sem conflitos de rede"
            else
                echo "2. The script should now proceed without network conflicts"
            fi
            ;;
        "monitor_deployment")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "3. Monitore o progresso da implantacao"
            else
                echo "3. Monitor the deployment progress"
            fi
            ;;
        "services_recreated")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Nota: Servicos foram parados e serao recriados durante a instalacao"
            else
                echo "Note: Services were stopped and will be recreated during installation"
            fi
            ;;
        "fixing_conflicts")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Corrigindo conflitos de rede Docker para Infra Caixa Preta..."
            else
                echo "Fixing Docker network conflicts for Infra Caixa Preta..."
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

print_fix() {
    echo -e "${PURPLE}🔧 ${1}${NC}"
}

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗    ███████╗██╗██╗  ██╗
████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝    ██╔════╝██║╚██╗██╔╝
██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝     █████╗  ██║ ╚███╔╝ 
██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗     ██╔══╝  ██║ ██╔██╗ 
██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗    ██║     ██║██╔╝ ██╗
╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝
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

print_info "$(msg "fixing_conflicts")"
echo

# 1. Check existing networks
print_fix "Step 1: $(msg "analyzing_networks")"

if docker network ls | grep -q "traefik-public"; then
    TRAEFIK_DRIVER=$(docker network ls --format "{{.Name}} {{.Driver}}" | grep "traefik-public" | awk '{print $2}')
    print_info "traefik-public $(msg "network_exists_correct") $TRAEFIK_DRIVER)"
    
    if [ "$TRAEFIK_DRIVER" != "overlay" ]; then
        print_warning "traefik-public $(msg "network_wrong_type")"
        RECREATE_TRAEFIK=true
    else
        print_success "traefik-public $(msg "network_correct")"
        RECREATE_TRAEFIK=false
    fi
else
    print_info "traefik-public $(msg "network_not_exist")"
    RECREATE_TRAEFIK=true
fi

if docker network ls | grep -q "internal-net"; then
    INTERNAL_DRIVER=$(docker network ls --format "{{.Name}} {{.Driver}}" | grep "internal-net" | awk '{print $2}')
    print_info "internal-net $(msg "network_exists_correct") $INTERNAL_DRIVER)"
    
    if [ "$INTERNAL_DRIVER" != "overlay" ]; then
        print_warning "internal-net $(msg "network_wrong_type")"
        RECREATE_INTERNAL=true
    else
        print_success "internal-net $(msg "network_correct")"
        RECREATE_INTERNAL=false
    fi
else
    print_info "internal-net $(msg "network_not_exist")"
    RECREATE_INTERNAL=true
fi

# 2. Stop services using the networks if needed
if [ "$RECREATE_TRAEFIK" = true ] || [ "$RECREATE_INTERNAL" = true ]; then
    print_fix "Step 2: $(msg "stopping_services")"
    
    # Stop services that might be using the networks
    docker service rm core_traefik core_portainer 2>/dev/null || true
    docker service rm db_postgres db_redis-n8n db_redis-mega 2>/dev/null || true
    docker service rm automation_n8n automation_evolution automation_n8n-worker 2>/dev/null || true
    docker service rm apps_mega-rails apps_mega-sidekiq apps_minio apps_grafana 2>/dev/null || true
    
    print_success "$(msg "services_stopped")"
    
    # Wait for services to fully stop
    print_info "$(msg "waiting_services_stop")"
    sleep 10
fi

# 3. Recreate networks if needed
print_fix "Step 3: $(msg "recreating_networks")"

if [ "$RECREATE_TRAEFIK" = true ]; then
    print_info "$(msg "removing_recreating") traefik-public..."
    docker network rm traefik-public 2>/dev/null || true
    sleep 2
    
    if docker network create --driver overlay --attachable --subnet=10.0.1.0/24 traefik-public; then
        print_success "traefik-public $(msg "network_created_success")"
    else
        print_error "$(msg "failed_create_network") traefik-public"
        exit 1
    fi
fi

if [ "$RECREATE_INTERNAL" = true ]; then
    print_info "$(msg "removing_recreating") internal-net..."
    docker network rm internal-net 2>/dev/null || true
    sleep 2
    
    if docker network create --driver overlay --attachable --subnet=10.0.2.0/24 internal-net; then
        print_success "internal-net $(msg "network_created_success")"
    else
        print_error "$(msg "failed_create_network") internal-net"
        exit 1
    fi
fi

# 4. Verify networks
print_fix "Step 4: $(msg "verifying_config")"

echo
print_info "$(msg "current_networks")"
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" | grep -E "(NAME|traefik-public|internal-net)"

if docker network ls | grep -q "traefik-public.*overlay" && docker network ls | grep -q "internal-net.*overlay"; then
    print_success "$(msg "networks_configured")"
else
    print_error "$(msg "config_still_incorrect")"
    exit 1
fi

echo
echo -e "${CYAN}${BOLD}$(msg "fix_complete")${NC}"
echo "=================================="

print_success "$(msg "networks_ready")"
echo

print_info "$(msg "next_steps")"
echo "$(msg "rerun_script")"
echo "$(msg "no_conflicts")"
echo "$(msg "monitor_deployment")"

print_warning "$(msg "services_recreated")"
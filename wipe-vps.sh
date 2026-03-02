#!/bin/bash

# ==============================================================================
# INFRA CAIXA PRETA v2 - VPS WIPE UTILITY
# Complete system cleanup for failed installations
# Autor: Hudson Argollo & Team
# DANGER: This will completely wipe Docker and all stack data
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
BLINK='\033[5m'

# Language-specific messages
msg() {
    local key="$1"
    case "$key" in
        "welcome_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "PROTOCOLO DE LIMPEZA COMPLETA DO SISTEMA"
            else
                echo "COMPLETE SYSTEM WIPE PROTOCOL"
            fi
            ;;
        "danger_warning")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "ISSO IRA DESTRUIR COMPLETAMENTE TODOS OS DADOS DO DOCKER E CONFIGURACOES DA STACK"
            else
                echo "THIS WILL COMPLETELY DESTROY ALL DOCKER DATA AND STACK CONFIGURATIONS"
            fi
            ;;
        "operation_will")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Esta operacao ira:"
            else
                echo "This operation will:"
            fi
            ;;
        "remove_containers")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Remover todos os containers, imagens e volumes do Docker"
            else
                echo "  → Remove all Docker containers, images, and volumes"
            fi
            ;;
        "destroy_swarm")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Destruir configuracao do cluster Docker Swarm"
            else
                echo "  → Destroy Docker Swarm cluster configuration"
            fi
            ;;
        "uninstall_docker")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Desinstalar Docker Engine completamente"
            else
                echo "  → Uninstall Docker Engine completely"
            fi
            ;;
        "delete_data")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Deletar todos os dados do CaixaPreta Stack (diretorio /data)"
            else
                echo "  → Delete all CaixaPreta Stack data (/data directory)"
            fi
            ;;
        "remove_configs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Remover todos os arquivos de configuracao da stack"
            else
                echo "  → Remove all stack configuration files"
            fi
            ;;
        "purge_system")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Purgar arquivos e configuracoes do sistema Docker"
            else
                echo "  → Purge Docker system files and configurations"
            fi
            ;;
        "purge_caches")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Limpar todos os caches do sistema e arquivos temporarios"
            else
                echo "  → Clear all system caches and temporary files"
            fi
            ;;
        "clear_logs")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Limpar logs do sistema e arquivos de journal"
            else
                echo "  → Clear system logs and journal files"
            fi
            ;;
        "cannot_undo")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "ESTA ACAO NAO PODE SER DESFEITA!"
            else
                echo "THIS ACTION CANNOT BE UNDONE!"
            fi
            ;;
        "confirm_question")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Voce tem certeza absoluta de que deseja prosseguir?"
            else
                echo "Are you absolutely sure you want to proceed?"
            fi
            ;;
        "type_wipe")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Digite 'WIPE' em maiusculas para confirmar a destruicao total:"
            else
                echo "Type 'WIPE' in uppercase to confirm total destruction:"
            fi
            ;;
        "operation_cancelled")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Operacao cancelada. Sistema permanece intacto."
            else
                echo "Operation cancelled. System remains intact."
            fi
            ;;
        "initiating_wipe")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "INICIANDO PROTOCOLO DE LIMPEZA TOTAL DO SISTEMA..."
            else
                echo "INITIATING TOTAL SYSTEM WIPE PROTOCOL..."
            fi
            ;;
        "root_required")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Acesso root necessario para operacoes de limpeza do sistema"
            else
                echo "Root access required for system wipe operations"
            fi
            ;;
        "terminating")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "TERMINANDO PROCESSO..."
            else
                echo "TERMINATING PROCESS..."
            fi
            ;;
        "phase1_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 1: DESTRUINDO CLUSTER DOCKER SWARM..."
            else
                echo "PHASE 1: DESTROYING DOCKER SWARM CLUSTER..."
            fi
            ;;
        "forcing_swarm")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Forcando dissolucao do cluster Swarm..."
            else
                echo "Forcing Swarm cluster dissolution..."
            fi
            ;;
        "dismantling_cluster")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Desmontando coordenacao do cluster"
            else
                echo "Dismantling cluster coordination"
            fi
            ;;
        "swarm_destroyed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Cluster Docker Swarm destruido"
            else
                echo "Docker Swarm cluster destroyed"
            fi
            ;;
        "swarm_leave_failed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Falha ao sair do cluster Docker Swarm"
            else
                echo "Failed to leave Docker Swarm cluster"
            fi
            ;;
        "swarm_not_active")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker Swarm nao estava ativo (ja dissolvido ou nunca inicializado)"
            else
                echo "Docker Swarm was not active (already disbanded or never initialized)"
            fi
            ;;
        "swarm_normal")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Isso e normal se a instalacao falhou ou estava incompleta"
            else
                echo "This is normal if the installation failed or was incomplete"
            fi
            ;;
        "phase2_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 2: ANIQUILANDO TODOS OS CONTAINERS E IMAGENS..."
            else
                echo "PHASE 2: ANNIHILATING ALL CONTAINERS AND IMAGES..."
            fi
            ;;
        "stopping_containers")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Parando todos os containers em execucao..."
            else
                echo "Stopping all running containers..."
            fi
            ;;
        "removing_all")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Removendo todos os containers, imagens, redes e volumes..."
            else
                echo "Removing all containers, images, networks, and volumes..."
            fi
            ;;
        "purging_docker")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Purgando dados do sistema Docker"
            else
                echo "Purging Docker system data"
            fi
            ;;
        "containers_annihilated")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Todos os containers e imagens do Docker aniquilados"
            else
                echo "All Docker containers and images annihilated"
            fi
            ;;
        "phase3_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 3: TERMINANDO DOCKER ENGINE..."
            else
                echo "PHASE 3: TERMINATING DOCKER ENGINE..."
            fi
            ;;
        "uninstalling_docker")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Desinstalando Docker Engine e todos os componentes..."
            else
                echo "Uninstalling Docker Engine and all components..."
            fi
            ;;
        "removing_packages")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Removendo pacotes Docker"
            else
                echo "Removing Docker packages"
            fi
            ;;
        "docker_terminated")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker Engine terminado"
            else
                echo "Docker Engine terminated"
            fi
            ;;
        "phase4_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 4: OBLITERANDO TODOS OS DADOS DA STACK..."
            else
                echo "PHASE 4: OBLITERATING ALL STACK DATA..."
            fi
            ;;
        "destroying_directories")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Destruindo diretorios do sistema e configuracoes..."
            else
                echo "Destroying system directories and configurations..."
            fi
            ;;
        "data_obliterated")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Todos os dados da stack obliterados"
            else
                echo "All stack data obliterated"
            fi
            ;;
        "phase5_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 5: PURGANDO ARTEFATOS DE INSTALACAO..."
            else
                echo "PHASE 5: PURGING INSTALLATION ARTIFACTS..."
            fi
            ;;
        "removing_scripts")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Removendo scripts de instalacao e configuracoes..."
            else
                echo "Removing installation scripts and configurations..."
            fi
            ;;
        "cleaning_artifacts")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Limpando artefatos de instalacao"
            else
                echo "Cleaning installation artifacts"
            fi
            ;;
        "artifacts_purged")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Artefatos de instalacao purgados"
            else
                echo "Installation artifacts purged"
            fi
            ;;
        "phase6_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "FASE 6: VERIFICACAO FINAL DO SISTEMA..."
            else
                echo "PHASE 6: FINAL SYSTEM VERIFICATION..."
            fi
            ;;
        "verifying_wipe")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Verificando limpeza completa do sistema..."
            else
                echo "Verifying complete system wipe..."
            fi
            ;;
        "destruction_verification")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Executando verificacao de destruicao"
            else
                echo "Running destruction verification"
            fi
            ;;
        "docker_still_exists")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Comando Docker ainda existe (pode precisar de limpeza manual)"
            else
                echo "Docker command still exists (may need manual cleanup)"
            fi
            ;;
        "docker_removed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Docker completamente removido do sistema"
            else
                echo "Docker completely removed from system"
            fi
            ;;
        "data_still_exists")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Diretorio de dados ainda existe (pode precisar de limpeza manual)"
            else
                echo "Data directory still exists (may need manual cleanup)"
            fi
            ;;
        "data_destroyed")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Todos os dados da stack destruidos com sucesso"
            else
                echo "All stack data successfully destroyed"
            fi
            ;;
        "wipe_complete_title")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "💀 PROTOCOLO DE LIMPEZA DO SISTEMA COMPLETO 💀"
            else
                echo "💀 SYSTEM WIPE PROTOCOL COMPLETE 💀"
            fi
            ;;
        "vps_wiped")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "VPS foi completamente limpo e restaurado ao estado limpo"
            else
                echo "VPS has been completely wiped and restored to clean state"
            fi
            ;;
        "cleanup_summary")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Resumo da limpeza do sistema:"
            else
                echo "System cleanup summary:"
            fi
            ;;
        "swarm_cluster")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Cluster Docker Swarm: ${GREEN}DESTRUIDO${NC}"
            else
                echo "  → Docker Swarm cluster: ${GREEN}DESTROYED${NC}"
            fi
            ;;
        "containers_images")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Containers/imagens Docker: ${GREEN}ANIQUILADOS${NC}"
            else
                echo "  → Docker containers/images: ${GREEN}ANNIHILATED${NC}"
            fi
            ;;
        "docker_engine")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Docker Engine: ${GREEN}TERMINADO${NC}"
            else
                echo "  → Docker Engine: ${GREEN}TERMINATED${NC}"
            fi
            ;;
        "stack_data")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Dados da stack (/data): ${GREEN}OBLITERADOS${NC}"
            else
                echo "  → Stack data (/data): ${GREEN}OBLITERATED${NC}"
            fi
            ;;
        "config_files")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Arquivos de configuracao: ${GREEN}PURGADOS${NC}"
            else
                echo "  → Configuration files: ${GREEN}PURGED${NC}"
            fi
            ;;
        "system_caches")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Caches do sistema: ${GREEN}OBLITERADOS${NC}"
            else
                echo "  → System caches: ${GREEN}OBLITERATED${NC}"
            fi
            ;;
        "log_files")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "  → Arquivos de log: ${GREEN}LIMPOS${NC}"
            else
                echo "  → Log files: ${GREEN}CLEARED${NC}"
            fi
            ;;
        "ready_fresh")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "SEU VPS ESTA PRONTO PARA INSTALACAO NOVA"
            else
                echo "YOUR VPS IS NOW READY FOR FRESH INSTALLATION"
            fi
            ;;
        "reinstall_info")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "Para reinstalar CaixaPreta Stack:"
            else
                echo "To reinstall CaixaPreta Stack:"
            fi
            ;;
        "destruction_terminated")
            if [ "$LANG_MODE" = "pt" ]; then
                echo "PROTOCOLO DE DESTRUICAO TERMINADO"
            else
                echo "DESTRUCTION PROTOCOL TERMINATED"
            fi
            ;;
        *)
            echo "$key"
            ;;
    esac
}

# Hacker-style functions
print_matrix() {
    local text="$1"
    echo -e "${GREEN}${BOLD}$text${NC}"
}

print_error() {
    local text="$1"
    echo -e "${RED}${BOLD}[CRITICAL]${NC} ${RED}$text${NC}"
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

print_danger() {
    local text="$1"
    echo -e "${RED}${BOLD}${BLINK}[DANGER]${NC} ${RED}${BOLD}$text${NC}"
}

# Loading animation
loading_animation() {
    local duration="$1"
    local message="$2"
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        for (( i=0; i<${#chars}; i++ )); do
            printf "\r${RED}${BOLD}[${chars:$i:1}]${NC} ${RED}$message${NC}"
            sleep 0.1
        done
    done
    printf "\r${GREEN}${BOLD}[✓]${NC} ${GREEN}$message - Complete${NC}\n"
}

# Destruction progress bar
destruction_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${RED}${BOLD}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<width; i++)); do printf "░"; done
    printf "] %d%% WIPING (%d/%d)${NC}" "$percentage" "$current" "$total"
    
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

# Clear screen and show banner
clear

echo -e "${RED}${BOLD}"
cat << "EOF"
██╗    ██╗██╗██████╗ ███████╗    ██╗███╗   ██╗███████╗██████╗  █████╗ 
██║    ██║██║██╔══██╗██╔════╝    ██║████╗  ██║██╔════╝██╔══██╗██╔══██╗
██║ █╗ ██║██║██████╔╝█████╗      ██║██╔██╗ ██║█████╗  ██████╔╝███████║
██║███╗██║██║██╔═══╝ ██╔══╝      ██║██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║
╚███╔███╔╝██║██║     ███████╗    ██║██║ ╚████║██║     ██║  ██║██║  ██║
 ╚══╝╚══╝ ╚═╝╚═╝     ╚══════╝    ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝
                                                                      
 ██████╗ █████╗ ██╗██╗  ██╗ █████╗     ██████╗ ██████╗ ███████╗████████╗ █████╗ 
██╔════╝██╔══██╗██║╚██╗██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
██║     ███████║██║ ╚███╔╝ ███████║    ██████╔╝██████╔╝█████╗     ██║   ███████║
██║     ██╔══██║██║ ██╔██╗ ██╔══██║    ██╔═══╝ ██╔══██╗██╔══╝     ██║   ██╔══██║
╚██████╗██║  ██║██║██╔╝ ██╗██║  ██║    ██║     ██║  ██║███████╗   ██║   ██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
                                                                                  
██╗   ██╗██████╗ 
██║   ██║╚════██╗
██║   ██║ █████╔╝
╚██╗ ██╔╝██╔═══╝ 
 ╚████╔╝ ███████╗
  ╚═══╝  ╚══════╝
EOF
echo -e "${NC}"

echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}                        VPS WIPE UTILITY v2.0                               ${NC}"
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
echo -ne "${GREEN}${BOLD}language@wipe:~$ ${NC}"
read LANGUAGE_CHOICE

# Set language
if [ "$LANGUAGE_CHOICE" = "2" ]; then
    LANG_MODE="pt"
else
    LANG_MODE="en"
fi

echo
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}                        $(msg "welcome_title")                         ${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo

print_danger "$(msg "danger_warning")"
echo
print_warning "$(msg "operation_will")"
print_info "$(msg "remove_containers")"
print_info "$(msg "destroy_swarm")"
print_info "$(msg "uninstall_docker")"
print_info "$(msg "delete_data")"
print_info "$(msg "remove_configs")"
print_info "$(msg "purge_system")"
print_info "$(msg "purge_caches")"
print_info "$(msg "clear_logs")"
echo

print_danger "$(msg "cannot_undo")"
echo

# Confirmation
echo -e "${YELLOW}${BOLD}$(msg "confirm_question") ${NC}"
echo -e "${RED}$(msg "type_wipe") ${NC}"
echo -ne "${RED}${BOLD}destruction@caixapreta:~$ ${NC}"
read CONFIRMATION

if [ "$CONFIRMATION" != "WIPE" ]; then
    print_info "$(msg "operation_cancelled")"
    exit 0
fi

echo
print_matrix "$(msg "initiating_wipe")"
echo

# Root check
if [ "$EUID" -ne 0 ]; then 
    print_error "$(msg "root_required")"
    echo -e "${RED}${BOLD}$(msg "terminating")${NC}"
    exit 1
fi

# Phase 1: Docker Swarm Destruction
echo
print_matrix "$(msg "phase1_title")"
echo

print_hacker "$(msg "forcing_swarm")"
loading_animation 3 "$(msg "dismantling_cluster")"

# Check if swarm is actually active first
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)

if [ "$SWARM_STATUS" = "active" ]; then
    if docker swarm leave --force >/dev/null 2>&1; then
        print_success "$(msg "swarm_destroyed")"
    else
        print_error "$(msg "swarm_leave_failed")"
    fi
elif [ "$SWARM_STATUS" = "inactive" ]; then
    print_warning "$(msg "swarm_not_active")"
    print_info "$(msg "swarm_normal")"
else
    print_warning "Docker Swarm status: $SWARM_STATUS"
    # Try to leave anyway in case of edge cases
    docker swarm leave --force >/dev/null 2>&1 || true
fi

# Phase 2: Container and Image Annihilation
echo
print_matrix "$(msg "phase2_title")"
echo

print_hacker "$(msg "stopping_containers")"
# Stop all containers forcefully
docker stop $(docker ps -aq) >/dev/null 2>&1 || true
docker kill $(docker ps -aq) >/dev/null 2>&1 || true

print_hacker "$(msg "removing_all")"
loading_animation 5 "$(msg "purging_docker")"

# Complete Docker cleanup - everything must go
docker container prune -f >/dev/null 2>&1 || true
docker image prune -a -f >/dev/null 2>&1 || true
docker volume prune -f >/dev/null 2>&1 || true
docker network prune -f >/dev/null 2>&1 || true
docker system prune -a --volumes -f >/dev/null 2>&1 || true
docker builder prune -a -f >/dev/null 2>&1 || true

# Force remove any remaining containers and images
docker rm -f $(docker ps -aq) >/dev/null 2>&1 || true
docker rmi -f $(docker images -aq) >/dev/null 2>&1 || true

print_success "$(msg "containers_annihilated")"

# Phase 3: Docker Engine Termination
echo
print_matrix "$(msg "phase3_title")"
echo

print_hacker "$(msg "uninstalling_docker")"
loading_animation 4 "$(msg "removing_packages")"

# Stop Docker services completely
systemctl stop docker.service >/dev/null 2>&1 || true
systemctl stop docker.socket >/dev/null 2>&1 || true
systemctl stop containerd.service >/dev/null 2>&1 || true
systemctl disable docker.service >/dev/null 2>&1 || true
systemctl disable docker.socket >/dev/null 2>&1 || true
systemctl disable containerd.service >/dev/null 2>&1 || true

# Remove Docker packages completely
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras docker-scan-plugin >/dev/null 2>&1 || true
apt-get purge -y docker.io docker-doc docker-compose podman-docker containerd runc >/dev/null 2>&1 || true
apt-get autoremove -y --purge >/dev/null 2>&1 || true

# Remove Docker repository
rm -f /etc/apt/sources.list.d/docker.list >/dev/null 2>&1 || true
rm -f /etc/apt/keyrings/docker.gpg >/dev/null 2>&1 || true

print_success "$(msg "docker_terminated")"

# Phase 4: Data Obliteration
echo
print_matrix "$(msg "phase4_title")"
echo

print_hacker "$(msg "destroying_directories")"

# Progress simulation for dramatic effect
directories=(
    "/var/lib/docker" 
    "/etc/docker" 
    "/data" 
    "~/stacks" 
    "/var/run/docker.sock"
    "/var/lib/containerd"
    "/var/lib/docker-engine"
    "/var/cache/docker"
    "/opt/containerd"
    "/run/docker"
    "/run/containerd"
    "$HOME/.docker"
    "/root/.docker"
    "/home/*/.docker"
)
total_dirs=${#directories[@]}

for i in "${!directories[@]}"; do
    destruction_bar $((i+1)) $total_dirs
    rm -rf "${directories[$i]}" 2>/dev/null || true
    sleep 0.3
done

print_success "$(msg "data_obliterated")"

# Phase 5: Cache and System Cleanup
echo
print_matrix "PHASE 5: PURGING ALL CACHES AND SYSTEM ARTIFACTS..."
echo

print_hacker "Obliterating system caches and temporary files..."
loading_animation 4 "Purging cache artifacts"

# Clear package manager caches
apt-get clean >/dev/null 2>&1 || true
apt-get autoclean >/dev/null 2>&1 || true

# Clear system caches
rm -rf /var/cache/* >/dev/null 2>&1 || true
rm -rf /tmp/* >/dev/null 2>&1 || true
rm -rf /var/tmp/* >/dev/null 2>&1 || true

# Clear log files
rm -rf /var/log/docker* >/dev/null 2>&1 || true
rm -rf /var/log/containers* >/dev/null 2>&1 || true
rm -rf /var/log/pods* >/dev/null 2>&1 || true
truncate -s 0 /var/log/syslog >/dev/null 2>&1 || true
truncate -s 0 /var/log/kern.log >/dev/null 2>&1 || true

# Clear systemd journal logs
journalctl --vacuum-time=1s >/dev/null 2>&1 || true
journalctl --vacuum-size=1M >/dev/null 2>&1 || true

# Clear user caches
rm -rf /root/.cache/* >/dev/null 2>&1 || true
rm -rf /home/*/.cache/* >/dev/null 2>&1 || true

# Clear network configurations
rm -rf /etc/systemd/network/docker* >/dev/null 2>&1 || true
rm -rf /etc/systemd/network/*-docker* >/dev/null 2>&1 || true

# Clear any remaining Docker-related systemd units
rm -f /etc/systemd/system/docker* >/dev/null 2>&1 || true
rm -f /lib/systemd/system/docker* >/dev/null 2>&1 || true
rm -f /etc/systemd/system/containerd* >/dev/null 2>&1 || true
systemctl daemon-reload >/dev/null 2>&1 || true

# Clear memory caches (force kernel to drop caches)
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

print_success "All caches and system artifacts purged"

# Phase 6: Script Cleanup
echo
print_matrix "$(msg "phase5_title")"
echo

print_hacker "$(msg "removing_scripts")"
loading_animation 2 "$(msg "cleaning_artifacts")"

rm -f *.sh *.yml *.yaml 2>/dev/null || true

print_success "$(msg "artifacts_purged")"

# Phase 6: Script Cleanup
echo
print_matrix "$(msg "phase5_title")"
echo

print_hacker "$(msg "removing_scripts")"
loading_animation 2 "$(msg "cleaning_artifacts")"

# Remove all installation scripts and artifacts
rm -f *.sh *.yml *.yaml *.json *.log 2>/dev/null || true
rm -f /tmp/caixapreta* >/dev/null 2>&1 || true
rm -f /tmp/docker* >/dev/null 2>&1 || true
rm -f /tmp/*install* >/dev/null 2>&1 || true

# Remove any downloaded Docker installation files
rm -f /tmp/get-docker.sh >/dev/null 2>&1 || true
rm -f get-docker.sh >/dev/null 2>&1 || true

print_success "$(msg "artifacts_purged")"

# Phase 7: Deep System Scan and Cleanup
echo
print_matrix "PHASE 7: DEEP SYSTEM SCAN AND FINAL CLEANUP..."
echo

print_hacker "Performing deep system scan for remaining artifacts..."
loading_animation 3 "Scanning for hidden remnants"

# Find and remove any remaining Docker-related files
find /etc -name "*docker*" -type f -delete 2>/dev/null || true
find /etc -name "*containerd*" -type f -delete 2>/dev/null || true
find /usr -name "*docker*" -type f -delete 2>/dev/null || true
find /opt -name "*docker*" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove any Docker-related environment variables from system files
sed -i '/DOCKER/d' /etc/environment 2>/dev/null || true
sed -i '/docker/d' /etc/bash.bashrc 2>/dev/null || true

# Clear any Docker-related cron jobs
crontab -l 2>/dev/null | grep -v docker | crontab - 2>/dev/null || true

# Remove Docker-related users and groups
userdel docker 2>/dev/null || true
groupdel docker 2>/dev/null || true

# Final memory and swap cleanup
swapoff -a 2>/dev/null || true
swapon -a 2>/dev/null || true

print_success "Deep system scan completed - all remnants eliminated"

# Phase 8: Final Verification
echo
print_matrix "$(msg "phase6_title")"
echo

print_hacker "$(msg "verifying_wipe")"
loading_animation 3 "$(msg "destruction_verification")"

# Check if Docker is gone
if command -v docker &> /dev/null; then
    print_warning "$(msg "docker_still_exists")"
else
    print_success "$(msg "docker_removed")"
fi

# Check if data directory is gone
if [ -d "/data" ]; then
    print_warning "$(msg "data_still_exists")"
else
    print_success "$(msg "data_destroyed")"
fi

# Final message
echo
echo -e "${GREEN}${BOLD}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    💀 SYSTEM WIPE PROTOCOL COMPLETE 💀                       ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_success "$(msg "vps_wiped")"
echo

print_info "$(msg "cleanup_summary")"
echo -e "$(msg "swarm_cluster")"
echo -e "$(msg "containers_images")"
echo -e "$(msg "docker_engine")"
echo -e "$(msg "stack_data")"
echo -e "$(msg "config_files")"
echo -e "$(msg "system_caches")"
echo -e "$(msg "log_files")"

echo
print_matrix "$(msg "ready_fresh")"
echo

print_info "$(msg "reinstall_info")"
echo "wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/caixapreta-stack.sh"
echo "chmod +x caixapreta-stack.sh && sudo ./caixapreta-stack.sh"

echo
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}                    $(msg "destruction_terminated")                          ${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
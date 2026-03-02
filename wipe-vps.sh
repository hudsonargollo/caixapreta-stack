#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK - VPS WIPE UTILITY v2.0
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
██╗    ██╗██╗██████╗ ███████╗    ██╗   ██╗██████╗ ███████╗
██║    ██║██║██╔══██╗██╔════╝    ██║   ██║██╔══██╗██╔════╝
██║ █╗ ██║██║██████╔╝█████╗      ██║   ██║██████╔╝███████╗
██║███╗██║██║██╔═══╝ ██╔══╝      ╚██╗ ██╔╝██╔═══╝ ╚════██║
╚███╔███╔╝██║██║     ███████╗     ╚████╔╝ ██║     ███████║
 ╚══╝╚══╝ ╚═╝╚═╝     ╚══════╝      ╚═══╝  ╚═╝     ╚══════╝
                                                           
 ██████╗ █████╗ ██╗██╗  ██╗ █████╗     ██████╗ ██████╗ ███████╗████████╗ █████╗ 
██╔════╝██╔══██╗██║╚██╗██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
██║     ███████║██║ ╚███╔╝ ███████║    ██████╔╝██████╔╝█████╗     ██║   ███████║
██║     ██╔══██║██║ ██╔██╗ ██╔══██║    ██╔═══╝ ██╔══██╗██╔══╝     ██║   ██╔══██║
╚██████╗██║  ██║██║██╔╝ ██╗██║  ██║    ██║     ██║  ██║███████╗   ██║   ██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}                        COMPLETE SYSTEM WIPE PROTOCOL                         ${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo

print_danger "THIS WILL COMPLETELY DESTROY ALL DOCKER DATA AND STACK CONFIGURATIONS"
echo
print_warning "This operation will:"
print_info "  → Remove all Docker containers, images, and volumes"
print_info "  → Destroy Docker Swarm cluster configuration"
print_info "  → Uninstall Docker Engine completely"
print_info "  → Delete all CaixaPreta Stack data (/data directory)"
print_info "  → Remove all stack configuration files"
print_info "  → Purge Docker system files and configurations"
echo

print_danger "THIS ACTION CANNOT BE UNDONE!"
echo

# Confirmation
echo -e "${YELLOW}${BOLD}Are you absolutely sure you want to proceed? ${NC}"
echo -e "${RED}Type 'WIPE' in uppercase to confirm total destruction: ${NC}"
echo -ne "${RED}${BOLD}destruction@caixapreta:~$ ${NC}"
read CONFIRMATION

if [ "$CONFIRMATION" != "WIPE" ]; then
    print_info "Operation cancelled. System remains intact."
    exit 0
fi

echo
print_matrix "INITIATING TOTAL SYSTEM WIPE PROTOCOL..."
echo

# Root check
if [ "$EUID" -ne 0 ]; then 
    print_error "Root access required for system wipe operations"
    echo -e "${RED}${BOLD}TERMINATING PROCESS...${NC}"
    exit 1
fi

# Phase 1: Docker Swarm Destruction
echo
print_matrix "PHASE 1: DESTROYING DOCKER SWARM CLUSTER..."
echo

print_hacker "Forcing Swarm cluster dissolution..."
loading_animation 3 "Dismantling cluster coordination"

# Check if swarm is actually active first
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)

if [ "$SWARM_STATUS" = "active" ]; then
    if docker swarm leave --force >/dev/null 2>&1; then
        print_success "Docker Swarm cluster destroyed"
    else
        print_error "Failed to leave Docker Swarm cluster"
    fi
elif [ "$SWARM_STATUS" = "inactive" ]; then
    print_warning "Docker Swarm was not active (already disbanded or never initialized)"
    print_info "This is normal if the installation failed or was incomplete"
else
    print_warning "Docker Swarm status: $SWARM_STATUS"
    # Try to leave anyway in case of edge cases
    docker swarm leave --force >/dev/null 2>&1 || true
fi

# Phase 2: Container and Image Annihilation
echo
print_matrix "PHASE 2: ANNIHILATING ALL CONTAINERS AND IMAGES..."
echo

print_hacker "Stopping all running containers..."
docker stop $(docker ps -aq) >/dev/null 2>&1 || true

print_hacker "Removing all containers, images, networks, and volumes..."
loading_animation 5 "Purging Docker system data"

docker system prune -a --volumes -f >/dev/null 2>&1 || true

print_success "All Docker containers and images annihilated"

# Phase 3: Docker Engine Termination
echo
print_matrix "PHASE 3: TERMINATING DOCKER ENGINE..."
echo

print_hacker "Uninstalling Docker Engine and all components..."
loading_animation 4 "Removing Docker packages"

apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1 || true
apt-get autoremove -y --purge >/dev/null 2>&1 || true

print_success "Docker Engine terminated"

# Phase 4: Data Obliteration
echo
print_matrix "PHASE 4: OBLITERATING ALL STACK DATA..."
echo

print_hacker "Destroying system directories and configurations..."

# Progress simulation for dramatic effect
directories=("/var/lib/docker" "/etc/docker" "/data" "~/stacks" "/var/run/docker.sock")
total_dirs=${#directories[@]}

for i in "${!directories[@]}"; do
    destruction_bar $((i+1)) $total_dirs
    rm -rf "${directories[$i]}" 2>/dev/null || true
    sleep 0.5
done

print_success "All stack data obliterated"

# Phase 5: Script Cleanup
echo
print_matrix "PHASE 5: PURGING INSTALLATION ARTIFACTS..."
echo

print_hacker "Removing installation scripts and configurations..."
loading_animation 2 "Cleaning installation artifacts"

rm -f *.sh *.yml *.yaml 2>/dev/null || true

print_success "Installation artifacts purged"

# Phase 6: Final Verification
echo
print_matrix "PHASE 6: FINAL SYSTEM VERIFICATION..."
echo

print_hacker "Verifying complete system wipe..."
loading_animation 3 "Running destruction verification"

# Check if Docker is gone
if command -v docker &> /dev/null; then
    print_warning "Docker command still exists (may need manual cleanup)"
else
    print_success "Docker completely removed from system"
fi

# Check if data directory is gone
if [ -d "/data" ]; then
    print_warning "Data directory still exists (may need manual cleanup)"
else
    print_success "All stack data successfully destroyed"
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

print_success "VPS has been completely wiped and restored to clean state"
echo

print_info "System cleanup summary:"
echo -e "${CYAN}  → Docker Swarm cluster: ${GREEN}DESTROYED${NC}"
echo -e "${CYAN}  → Docker containers/images: ${GREEN}ANNIHILATED${NC}"
echo -e "${CYAN}  → Docker Engine: ${GREEN}TERMINATED${NC}"
echo -e "${CYAN}  → Stack data (/data): ${GREEN}OBLITERATED${NC}"
echo -e "${CYAN}  → Configuration files: ${GREEN}PURGED${NC}"

echo
print_matrix "YOUR VPS IS NOW READY FOR FRESH INSTALLATION"
echo

print_info "To reinstall CaixaPreta Stack:"
echo "wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/caixapreta-stack.sh"
echo "chmod +x caixapreta-stack.sh"
echo "sudo ./caixapreta-stack.sh"

echo
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}${BOLD}                    DESTRUCTION PROTOCOL TERMINATED                          ${NC}"
echo -e "${GRAY}${DIM}════════════════════════════════════════════════════════════════════════════════${NC}"
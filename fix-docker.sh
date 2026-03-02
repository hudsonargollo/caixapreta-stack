#!/bin/bash

# CaixaPreta Stack - Docker Fix Script
# Use this to fix Docker daemon connection issues

set -e

# Terminal Colors & Effects
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} ${RED}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} ${YELLOW}$1${NC}"
}

print_info() {
    echo -e "${CYAN}${BOLD}[INFO]${NC} ${CYAN}$1${NC}"
}

echo -e "${GREEN}${BOLD}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    🐳 DOCKER CONNECTION FIX UTILITY 🐳                       ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "Diagnosing Docker connection issues..."
echo

# 1. Check if Docker is installed
print_info "1. Checking Docker installation..."
if command -v docker &> /dev/null; then
    print_success "Docker command found"
    docker --version
else
    print_error "Docker is not installed"
    print_info "Please run the main CaixaPreta installation script first"
    exit 1
fi
echo

# 2. Check Docker service status
print_info "2. Checking Docker service status..."
if systemctl is-active --quiet docker; then
    print_success "Docker service is running"
else
    print_warning "Docker service is not running"
    print_info "Starting Docker service..."
    systemctl start docker
    sleep 3
    
    if systemctl is-active --quiet docker; then
        print_success "Docker service started successfully"
    else
        print_error "Failed to start Docker service"
        print_info "Check service status: systemctl status docker"
        exit 1
    fi
fi
echo

# 3. Check Docker socket permissions
print_info "3. Checking Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
    print_success "Docker socket exists"
    ls -la /var/run/docker.sock
    
    print_info "Fixing socket permissions..."
    chmod 666 /var/run/docker.sock
    print_success "Socket permissions updated"
else
    print_error "Docker socket not found"
    print_info "Docker daemon may not be running properly"
fi
echo

# 4. Test Docker daemon connection
print_info "4. Testing Docker daemon connection..."
if docker info >/dev/null 2>&1; then
    print_success "Docker daemon is responding"
    echo "Docker system info:"
    docker info | head -10
else
    print_error "Cannot connect to Docker daemon"
    
    print_info "Attempting to restart Docker..."
    systemctl restart docker
    sleep 10
    
    if docker info >/dev/null 2>&1; then
        print_success "Docker connection restored after restart"
    else
        print_error "Docker daemon still not responding"
        echo
        print_info "Manual troubleshooting steps:"
        echo "1. Check Docker service: systemctl status docker"
        echo "2. Check Docker logs: journalctl -u docker.service"
        echo "3. Restart Docker: systemctl restart docker"
        echo "4. Check socket: ls -la /var/run/docker.sock"
        echo "5. Fix permissions: chmod 666 /var/run/docker.sock"
        exit 1
    fi
fi
echo

# 5. Test basic Docker functionality
print_info "5. Testing basic Docker functionality..."
if docker run --rm hello-world >/dev/null 2>&1; then
    print_success "Docker is working correctly"
else
    print_warning "Docker basic test failed"
    print_info "This might be a network or registry issue"
fi
echo

# 6. Check user permissions
print_info "6. Checking user permissions..."
if groups | grep -q docker; then
    print_success "User is in docker group"
else
    print_warning "User is not in docker group"
    print_info "Adding user to docker group..."
    usermod -aG docker $USER
    print_success "User added to docker group"
    print_warning "You may need to log out and back in for group changes to take effect"
fi
echo

print_success "Docker fix utility completed!"
print_info "If issues persist, check Docker documentation or system logs"
echo
print_info "You can now retry the CaixaPreta installation script"
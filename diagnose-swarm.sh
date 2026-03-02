#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔍 DOCKER SWARM DIAGNOSTIC TOOL${NC}"
echo "=================================="
echo

# 1. Check Docker status
echo -e "${YELLOW}1. Docker Engine Status:${NC}"
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}✅ Docker service is running${NC}"
else
    echo -e "${RED}❌ Docker service is not running${NC}"
    exit 1
fi

# 2. Check Docker daemon connectivity
echo -e "\n${YELLOW}2. Docker Daemon Connectivity:${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker daemon is accessible${NC}"
else
    echo -e "${RED}❌ Cannot connect to Docker daemon${NC}"
    exit 1
fi

# 3. Check Swarm status
echo -e "\n${YELLOW}3. Docker Swarm Status:${NC}"
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)

case "$SWARM_STATUS" in
    "active")
        echo -e "${GREEN}✅ Docker Swarm is ACTIVE${NC}"
        echo -e "   Node Role: $(docker info --format '{{.Swarm.ControlAvailable}}')"
        echo -e "   Node ID: $(docker info --format '{{.Swarm.NodeID}}')"
        ;;
    "inactive")
        echo -e "${RED}❌ Docker Swarm is INACTIVE${NC}"
        echo -e "   This node is not part of any swarm cluster"
        ;;
    "pending")
        echo -e "${YELLOW}⚠️  Docker Swarm is PENDING${NC}"
        echo -e "   Node is trying to join a swarm"
        ;;
    "error")
        echo -e "${RED}❌ Docker Swarm has ERRORS${NC}"
        echo -e "   There are issues with the swarm configuration"
        ;;
    *)
        echo -e "${RED}❌ Unknown Swarm status: $SWARM_STATUS${NC}"
        ;;
esac

# 4. Check for existing services (even if swarm is inactive)
echo -e "\n${YELLOW}4. Checking for Docker Services:${NC}"
if docker service ls >/dev/null 2>&1; then
    SERVICE_COUNT=$(docker service ls --format "{{.Name}}" | wc -l)
    if [ "$SERVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $SERVICE_COUNT Docker services${NC}"
        echo -e "\n${BLUE}Active Services:${NC}"
        docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"
    else
        echo -e "${YELLOW}⚠️  No Docker services found${NC}"
    fi
else
    echo -e "${RED}❌ Cannot list Docker services (Swarm not active)${NC}"
fi

# 5. Check for containers (running outside swarm)
echo -e "\n${YELLOW}5. Checking for Regular Containers:${NC}"
CONTAINER_COUNT=$(docker ps -a --format "{{.Names}}" | wc -l)
if [ "$CONTAINER_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $CONTAINER_COUNT containers (not managed by Swarm)${NC}"
    echo -e "\n${BLUE}Containers:${NC}"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
else
    echo -e "${GREEN}✅ No standalone containers found${NC}"
fi

# 6. Check for networks
echo -e "\n${YELLOW}6. Checking Docker Networks:${NC}"
NETWORK_COUNT=$(docker network ls --filter driver=overlay --format "{{.Name}}" | wc -l)
if [ "$NETWORK_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $NETWORK_COUNT overlay networks (Swarm networks)${NC}"
    docker network ls --filter driver=overlay --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
else
    echo -e "${GREEN}✅ No overlay networks found${NC}"
fi

# 7. Check data directory
echo -e "\n${YELLOW}7. Checking CaixaPreta Data:${NC}"
if [ -d "/data" ]; then
    DATA_SIZE=$(du -sh /data 2>/dev/null | cut -f1)
    echo -e "${YELLOW}⚠️  CaixaPreta data directory exists: ${DATA_SIZE}${NC}"
    echo -e "   Location: /data"
    ls -la /data/ 2>/dev/null | head -10
else
    echo -e "${GREEN}✅ No CaixaPreta data directory found${NC}"
fi

echo
echo -e "${CYAN}📋 DIAGNOSIS SUMMARY:${NC}"
echo "===================="

if [ "$SWARM_STATUS" = "active" ]; then
    echo -e "${GREEN}✅ Docker Swarm is working correctly${NC}"
    echo -e "   Your CaixaPreta Stack should be running normally"
elif [ "$SWARM_STATUS" = "inactive" ] && [ "$SERVICE_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ INCONSISTENT STATE DETECTED${NC}"
    echo -e "   Swarm is inactive but services exist - this shouldn't happen"
    echo -e "   Recommendation: Run the fix-and-redeploy.sh script"
elif [ "$SWARM_STATUS" = "inactive" ]; then
    echo -e "${YELLOW}⚠️  Docker Swarm was never initialized or was disbanded${NC}"
    echo -e "   This explains why 'docker swarm leave' failed"
    echo -e "   Recommendation: Re-run the installation script"
else
    echo -e "${RED}❌ Docker Swarm has issues${NC}"
    echo -e "   Recommendation: Check Docker logs and restart Docker service"
fi

echo
echo -e "${BLUE}💡 NEXT STEPS:${NC}"
if [ "$SWARM_STATUS" = "inactive" ]; then
    echo "1. If you want to reinstall: Run ./caixapreta-stack.sh"
    echo "2. If you want to clean up: Run ./wipe-vps.sh (it will handle the missing swarm)"
    echo "3. If you want to fix existing: Run ./fix-and-redeploy.sh"
else
    echo "1. Check service status: docker service ls"
    echo "2. Check service logs: docker service logs SERVICE_NAME"
    echo "3. If issues persist: Run ./diagnose-portainer.sh or ./diagnose-mega.sh"
fi

echo
echo -e "${CYAN}Diagnostic complete!${NC}"
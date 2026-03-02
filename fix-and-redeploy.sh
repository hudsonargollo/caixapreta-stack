#!/bin/bash

# CaixaPreta Stack - Fix and Redeploy Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Fixing CaixaPreta Stack deployment issues...${NC}"

# Get domain
read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Domain is required!${NC}"
    exit 1
fi

read -p "Enter your email for SSL: " EMAIL
if [ -z "$EMAIL" ]; then
    echo -e "${RED}Email is required!${NC}"
    exit 1
fi

echo -e "${YELLOW}1. Fixing Docker permissions...${NC}"
chmod 666 /var/run/docker.sock
systemctl restart docker
sleep 5

echo -e "${YELLOW}2. Checking Docker Swarm...${NC}"
if ! docker info | grep -q "Swarm: active"; then
    echo "Reinitializing Docker Swarm..."
    PUBLIC_IP=$(curl -s ifconfig.me)
    docker swarm leave --force 2>/dev/null || true
    docker swarm init --advertise-addr $PUBLIC_IP
fi

echo -e "${YELLOW}3. Removing old stacks...${NC}"
docker stack rm apps automation core db 2>/dev/null || true
sleep 10

echo -e "${YELLOW}4. Recreating networks...${NC}"
docker network rm traefik-public internal-net 2>/dev/null || true
sleep 2
docker network create --driver overlay traefik-public
docker network create --driver overlay internal-net

echo -e "${YELLOW}5. Fixing data directory permissions...${NC}"
chown -R root:root /data
chmod -R 755 /data
chmod 600 /data/traefik/acme.json

echo -e "${YELLOW}6. Recreating Traefik config...${NC}"
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

echo -e "${YELLOW}7. Deploying Core Stack (Traefik + Portainer)...${NC}"
cat <<EOF > swarm-core-fixed.yml
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

docker stack deploy -c swarm-core-fixed.yml core

echo -e "${YELLOW}8. Waiting for services to start...${NC}"
sleep 15

echo -e "${YELLOW}9. Checking service status...${NC}"
docker service ls
echo
docker service ps core_traefik
echo
docker service ps core_portainer

echo -e "${GREEN}Core stack deployment complete!${NC}"
echo -e "Access Portainer at: https://portainer.$DOMAIN"
echo -e "Access Traefik at: https://traefik.$DOMAIN"
echo
echo -e "${YELLOW}If services are still starting, wait 2-3 minutes and check again with:${NC}"
echo "docker service ls"
echo "docker service ps core_portainer"
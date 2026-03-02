#!/bin/bash

# ==============================================================================
# CAIXA PRETA STACK
# Script de Automação de Infraestrutura Docker Swarm (Inspirado na Masterclass)
# Autor: Hudson Argollo e seus amiguinho Manus
# Sistema: Debian
# Foco: n8n + MEGA (Chatwoot V4 mod Nestor/Valus) + Evolution API + Traefik
# ==============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando a instalação da infraestrutura automatizada CaixaPreta...${NC}"

# 1. Verificação de Requisitos
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Por favor, execute como root.${NC}"
  exit
fi

# Solicitar domínio base
read -p "Digite o seu domínio base (ex: seu-dominio.com): " DOMAIN
read -p "Digite o seu e-mail para o SSL (Let's Encrypt): " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo -e "${RED}Domínio e e-mail são obrigatórios.${NC}"
    exit 1
fi

# 2. Atualização do Sistema e Instalação de Dependências
echo -e "${YELLOW}Atualizando o sistema e instalando dependências...${NC}"
apt update && apt upgrade -y
apt install -y curl wget git jq ufw unzip

# 3. Instalação do Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Instalando Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# 4. Inicialização do Docker Swarm
if ! docker info | grep -q "Swarm: active"; then
    echo -e "${YELLOW}Inicializando Docker Swarm...${NC}"
    PUBLIC_IP=$(curl -s ifconfig.me)
    docker swarm init --advertise-addr $PUBLIC_IP
fi

# 4.1. Configuração de permissões do Docker
echo -e "${YELLOW}Configurando permissões do Docker...${NC}"
chmod 666 /var/run/docker.sock
systemctl enable docker
systemctl restart docker
sleep 5

# 5. Criação de Redes do Swarm
echo -e "${YELLOW}Criando redes do Swarm...${NC}"
# Remove networks if they exist to avoid conflicts
docker network rm traefik-public internal-net 2>/dev/null || true
sleep 2
docker network create --driver overlay traefik-public
docker network create --driver overlay internal-net

# 6. Preparação de Diretórios de Dados
echo -e "${YELLOW}Criando diretórios para persistência de dados...${NC}"
mkdir -p /data/traefik /data/portainer /data/n8n /data/redis_n8n /data/redis_mega /data/postgres /data/minio /data/mega /data/evolution /data/grafana
touch /data/traefik/acme.json
chmod 600 /data/traefik/acme.json
# Ensure proper ownership and permissions
chown -R root:root /data
chmod -R 755 /data
chmod 600 /data/traefik/acme.json

# 7. Configuração do Traefik (Proxy Reverso com SSL)
echo -e "${YELLOW}Configurando Traefik...${NC}"
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

# 8. Deploy das Stacks
echo -e "${YELLOW}Iniciando o deploy das stacks...${NC}"

# Wait for Docker to be fully ready
sleep 5

# STACK 1: Traefik & Portainer
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

docker stack deploy -c swarm-core.yml core

echo -e "${YELLOW}Aguardando Traefik e Portainer iniciarem...${NC}"
sleep 15

# Verificar se os serviços estão rodando
echo -e "${YELLOW}Verificando status dos serviços core...${NC}"
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

docker stack deploy -c swarm-db.yml db

echo -e "${YELLOW}Aguardando banco de dados iniciar...${NC}"
sleep 20

# Verificar se os serviços de banco estão rodando
echo -e "${YELLOW}Verificando status dos serviços de banco...${NC}"
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

docker stack deploy -c swarm-automation.yml automation

echo -e "${YELLOW}Aguardando n8n iniciar...${NC}"
sleep 15

# Verificar se os serviços de automação estão rodando
echo -e "${YELLOW}Verificando status dos serviços de automação...${NC}"
docker service ls | grep automation

# STACK 4: MEGA (Chatwoot V4 Mod Valus) e Evolution API
echo -e "${YELLOW}Preparando banco de dados para MEGA (Chatwoot)...${NC}"

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Aguardando PostgreSQL estar pronto...${NC}"
sleep 10

# Initialize Chatwoot database
echo -e "${YELLOW}Inicializando banco de dados do Chatwoot...${NC}"
docker run --rm --network db_internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@postgres:5432/main_db \
  -e RAILS_ENV=production \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare || echo "Database already initialized or initialization failed - continuing..."

sleep 5
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

docker stack deploy -c swarm-apps.yml apps

echo -e "${YELLOW}Aguardando aplicações iniciarem...${NC}"
sleep 20

# Verificar se todos os serviços estão rodando
echo -e "${YELLOW}Verificando status final de todos os serviços...${NC}"
docker service ls

echo -e "${YELLOW}Verificando serviços com problemas...${NC}"
docker service ls --filter "desired-state=running" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/"

# 9. Finalização
echo -e "${GREEN}Instalação CaixaPreta concluída com sucesso!${NC}"
echo -e "Acesse os serviços nos endereços abaixo:"
echo -e "- Portainer: https://portainer.$DOMAIN"
echo -e "- Traefik Dashboard: https://traefik.$DOMAIN"
echo -e "- n8n: https://n8n.$DOMAIN"
echo -e "- Evolution API: https://evolution.$DOMAIN"
echo -e "- MinIO Console: https://minio.$DOMAIN"
echo -e "- MEGA (Chatwoot V4 + Kanban): https://mega.$DOMAIN"
echo -e "- Grafana: https://grafana.$DOMAIN"
echo -e "\n${YELLOW}IMPORTANTE: Certifique-se de que os registros DNS (A Records) para os subdomínios acima apontam para o IP deste servidor.${NC}"
echo -e "${YELLOW}Aguarde alguns minutos para a propagação do SSL do Let's Encrypt.${NC}"

# Status final e troubleshooting
echo -e "\n${YELLOW}=== STATUS FINAL DOS SERVIÇOS ===${NC}"
docker service ls

echo -e "\n${YELLOW}=== COMANDOS ÚTEIS PARA TROUBLESHOOTING ===${NC}"
echo -e "Verificar logs do Portainer: docker service logs core_portainer"
echo -e "Verificar logs do Traefik: docker service logs core_traefik"
echo -e "Verificar status de um serviço: docker service ps NOME_DO_SERVICO"
echo -e "Reiniciar um serviço: docker service update --force NOME_DO_SERVICO"
echo -e "Verificar certificados SSL: cat /data/traefik/acme.json"

# Verificar se há serviços com problemas
FAILED_SERVICES=$(docker service ls --filter "desired-state=running" --format "{{.Name}} {{.Replicas}}" | grep "0/" | wc -l)
if [ "$FAILED_SERVICES" -gt 0 ]; then
    echo -e "\n${RED}⚠️  ATENÇÃO: Alguns serviços não iniciaram corretamente:${NC}"
    docker service ls --filter "desired-state=running" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}" | grep "0/"
    echo -e "\n${YELLOW}Execute os comandos de troubleshooting acima para investigar.${NC}"
    echo -e "${YELLOW}Aguarde 2-3 minutos e verifique novamente com: docker service ls${NC}"
else
    echo -e "\n${GREEN}✅ Todos os serviços estão rodando corretamente!${NC}"
fi

# 🚀 CaixaPreta Stack - Infraestrutura Automatizada

**Parte do Ecossistema CaixaPreta** | [Visite nosso site](https://caixapreta.clubemkt.digital/)

## 📋 Sobre o Produto

O **CaixaPreta Stack** é uma solução completa de infraestrutura automatizada que permite a **não-técnicos** instalar e configurar uma stack profissional de automação e atendimento em poucos minutos, sem conhecimento técnico avançado.

### 🎯 Para Quem é Este Produto?

- **Empreendedores digitais** que precisam de automação profissional
- **Agências de marketing** que querem oferecer soluções completas
- **Consultores** que precisam de infraestrutura rápida para clientes
- **Qualquer pessoa** que quer uma stack profissional sem complicação técnica

## 🏗️ O Que Você Recebe

### Stack Completa Inclui:

- **🤖 n8n** - Automação de processos e workflows
- **💬 MEGA (Chatwoot V4)** - Atendimento multicanal profissional
- **📱 Evolution API** - Integração WhatsApp Business
- **🔒 Traefik** - Proxy reverso com SSL automático
- **📊 Grafana** - Dashboards e monitoramento
- **💾 MinIO** - Armazenamento de arquivos
- **🗄️ PostgreSQL 15** - Banco de dados robusto
- **⚡ Redis** - Cache e filas de alta performance

### 🌐 Subdomínios Configurados Automaticamente:

- `n8n.seudominio.com` - Plataforma de automação
- `mega.seudominio.com` - Sistema de atendimento
- `evolution.seudominio.com` - API do WhatsApp
- `portainer.seudominio.com` - Gerenciamento de containers
- `traefik.seudominio.com` - Dashboard do proxy
- `minio.seudominio.com` - Console de arquivos
- `grafana.seudominio.com` - Dashboards de monitoramento

## 🚀 Instalação Rápida (5 Minutos)

### Pré-requisitos:
- VPS com Ubuntu/Debian
- Domínio próprio
- Acesso root ao servidor

### Passo a Passo:

1. **Conecte no seu servidor via SSH**
2. **Baixe e execute o script:**
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/caixapreta-stack.sh
chmod +x caixapreta-stack.sh
sudo ./caixapreta-stack.sh
```

3. **Configure quando solicitado:**
   - Digite seu domínio (ex: `meusite.com`)
   - Digite seu e-mail para SSL

4. **Configure DNS:**
   - Aponte os subdomínios para o IP do seu servidor
   - Aguarde propagação (5-15 minutos)

5. **Valide a instalação (opcional):**
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/validate-installation.sh
chmod +x validate-installation.sh
sudo ./validate-installation.sh
```

6. **Pronto!** Acesse seus serviços com SSL automático

### 📖 Guia Completo de Instalação

Para um guia detalhado com interface visual, acesse:
**[instalar.caixapreta.clubemkt.digital]( https://instalar.caixapreta.clubemkt.digital )**

- 🎭 **Interface profissional**: Guia com tema cyberpunk e animações
- 🔐 **Acesso restrito**: Solicite a senha via WhatsApp
- 📱 **Interface responsiva**: Funciona em desktop e mobile
- 🛠️ **Seção de troubleshooting**: Inclui todos os scripts de diagnóstico
- 💀 **Utilitário de limpeza**: Script para limpar VPS com falhas

**📱 Para obter acesso ao guia:** [WhatsApp +557398803-3318] https://wa.me/5573988083318

## 💡 Parte do Ecossistema CaixaPreta

Este produto faz parte do **bundle completo CaixaPreta** que inclui:

- ✅ **15.000+ Flows n8n** prontos para usar
- ✅ **Comunidade exclusiva** para networking e suporte
- ✅ **Consultoria completa** com Hudson Argollo
- ✅ **CaixaPreta Stack** (este produto) - Infraestrutura automatizada

[**🔗 Conheça todos os produtos e ofertas**](https://caixapreta.clubemkt.digital/)

## 🛠️ Scripts de Diagnóstico e Correção

### 🔍 Scripts de Diagnóstico (Análise de Problemas)

```bash
# Redis - Analisa problemas nos serviços Redis (n8n e MEGA)
./diagnose-redis.sh

# PostgreSQL - Analisa problemas no banco de dados
./diagnose-postgres.sh

# MEGA - Analisa problemas no sistema de atendimento
./diagnose-mega.sh

# Traefik - Analisa problemas de SSL e proxy reverso
./diagnose-traefik.sh

# Portainer - Analisa problemas de acesso ao gerenciador
./diagnose-portainer.sh

# Conectividade - Testa conectividade geral dos serviços
./diagnose-connectivity.sh

# SSL/DNS - Verifica configuração de SSL e DNS
./diagnose-ssl-dns.sh

# Docker Swarm - Analisa problemas do cluster
./diagnose-swarm.sh
```

### 🔧 Scripts de Correção Automática

```bash
# Redis - Corrige automaticamente problemas do Redis
sudo ./fix-redis-deployment.sh

# PostgreSQL - Corrige automaticamente problemas do banco
sudo ./fix-postgres-deployment.sh

# MEGA - Corrige erro 404 e problemas do MEGA
sudo ./fix-mega.sh

# Traefik - Corrige problemas de SSL e proxy
sudo ./fix-traefik-deployment.sh

# Rede - Corrige conflitos de rede
sudo ./fix-network-conflict.sh

# Portainer - Corrige problemas de acesso
sudo ./fix-portainer.sh

# Correção Completa - Tenta corrigir todos os problemas
sudo ./fix-and-redeploy.sh
```

### 📥 Como Baixar os Scripts

**Opção 1: Baixar todos de uma vez**
```bash
# Clone o repositório completo
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack
chmod +x *.sh
```

**Opção 2: Baixar scripts individuais**
```bash
# Exemplo: Baixar script de diagnóstico do Redis
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-redis.sh
chmod +x diagnose-redis.sh

# Exemplo: Baixar script de correção do PostgreSQL
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-postgres-deployment.sh
chmod +x fix-postgres-deployment.sh
```

### 🚨 Fluxo de Resolução de Problemas

1. **Identifique o problema**: Use os scripts de diagnóstico
2. **Execute a correção**: Use o script de correção correspondente
3. **Verifique o resultado**: Execute novamente o diagnóstico
4. **Se persistir**: Use o script de correção completa

```bash
# Exemplo: Problema com Redis
./diagnose-redis.sh          # 1. Diagnosticar
sudo ./fix-redis-deployment.sh  # 2. Corrigir
./diagnose-redis.sh          # 3. Verificar
```

## 🛠️ Scripts Auxiliares Legados

### Validação da Instalação
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/validate-installation.sh
chmod +x validate-installation.sh
sudo ./validate-installation.sh
```

### Correção de Problemas (Para instalações existentes)
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-and-redeploy.sh
chmod +x fix-and-redeploy.sh
sudo ./fix-and-redeploy.sh
```

### Diagnóstico do Portainer
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-portainer.sh
chmod +x diagnose-portainer.sh
sudo ./diagnose-portainer.sh
```

### Diagnóstico do MEGA (Chatwoot)
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-mega.sh
chmod +x diagnose-mega.sh
sudo ./diagnose-mega.sh
```

### Correção do MEGA (Para erro 404)
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-mega.sh
chmod +x fix-mega.sh
sudo ./fix-mega.sh
```

## 🛠️ Tecnologias Utilizadas

- **Docker Swarm** - Orquestração de containers
- **Traefik v2.10** - Proxy reverso moderno
- **Let's Encrypt** - SSL gratuito e automático
- **PostgreSQL 15** - Banco com suporte a pgvector
- **Redis 7** - Cache e filas distribuídas
- **n8n Latest** - Automação em modo queue
- **Chatwoot V4** - Atendimento com modificações Valus/Nestor

## 📞 Suporte e Comunidade

- **Comunidade CaixaPreta**: Acesso exclusivo para clientes
- **Suporte direto**: Com Hudson Argollo e equipe
- **Documentação completa**: Guias passo a passo
- **Updates automáticos**: Sempre na versão mais recente

## 🔐 Credenciais Padrão

**Importante**: Altere as senhas após a instalação!

- **PostgreSQL**: `postgres` / [Solicite via WhatsApp](https://wa.me/5573988083318)
- **MinIO**: `admin` / [Solicite via WhatsApp](https://wa.me/5573988083318)
- **Evolution API Key**: [Solicite via WhatsApp](https://wa.me/5573988083318)

## ⚠️ Requisitos do Servidor

### Mínimo Recomendado:
- **CPU**: 2 vCores
- **RAM**: 4GB
- **Storage**: 40GB SSD
- **OS**: Ubuntu 20.04+ ou Debian 11+

### Para Produção:
- **CPU**: 4+ vCores
- **RAM**: 8GB+
- **Storage**: 100GB+ SSD
- **Backup**: Configuração automática recomendada

## ⚠️ Resolução de Problemas Comuns

### 🔴 Redis não funciona (0/1 replicas)
**Sintomas:** n8n e MEGA não funcionam, Redis mostra 0/1 replicas

**Solução Rápida:**
```bash
sudo ./fix-redis-deployment.sh
```

**Diagnóstico Detalhado:**
```bash
./diagnose-redis.sh
```

### 🔵 PostgreSQL não inicia (0/1 replicas)
**Sintomas:** Banco não conecta, serviços dependentes falham

**Solução Rápida:**
```bash
sudo ./fix-postgres-deployment.sh
```

**Diagnóstico Detalhado:**
```bash
./diagnose-postgres.sh
```

### 🟣 MEGA retorna erro 404
**Sintomas:** mega.seudominio.com mostra página 404

**Solução Rápida:**
```bash
sudo ./fix-mega.sh
```

**Solução Manual:**
```bash
docker run --rm --network internal-net \
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db \
  -e RAILS_ENV=production \
  sendingtk/chatwoot:v4.11.2 \
  bundle exec rails db:chatwoot_prepare
```

### 🔒 Certificados SSL não funcionam
**Causa:** DNS não propagado ou configurado incorretamente

**Diagnóstico:**
```bash
./diagnose-ssl-dns.sh
```

**Soluções:**
1. Verifique DNS: `nslookup n8n.seudominio.com`
2. Aguarde propagação (até 24h)
3. Reinicie Traefik: `docker service update --force core_traefik`

### 🌐 Portainer não acessível
**Diagnóstico:**
```bash
./diagnose-portainer.sh
```

**Soluções:**
1. Verifique serviços: `docker service ls`
2. Verifique logs: `docker service logs core_portainer`
3. Reinicie: `docker service update --force core_portainer`

### ⚡ Servidor lento ou travando
**Causa:** Falta de recursos (RAM/CPU)

**Diagnóstico:**
```bash
free -h && df -h && docker stats --no-stream
```

**Soluções:**
1. Monitore recursos: `htop`
2. Configure swap: `fallocate -l 2G /swapfile`
3. Aumente RAM do servidor se necessário

### 🔧 Correção Completa (Todos os Problemas)
Se múltiplos serviços estão falhando:

```bash
sudo ./fix-and-redeploy.sh
```

Este script tenta corrigir automaticamente todos os problemas conhecidos.

## 🚨 Pós-Instalação

1. **Altere todas as senhas padrão**
2. **Configure backups automáticos**
3. **Monitore recursos via Grafana**
4. **Teste todas as integrações**
5. **Configure firewall (UFW já instalado)**

## 📈 Monitoramento

O Grafana vem pré-configurado para monitorar:
- Performance dos containers
- Uso de recursos (CPU, RAM, Disk)
- Logs de aplicação
- Métricas de rede

## 🤝 Sobre o Criador

**Hudson Argollo** - Especialista em automação e infraestrutura, criador do ecossistema CaixaPreta com milhares de clientes satisfeitos.

---

## 📞 Precisa de Ajuda?

- 🌐 **Site oficial**: [caixapreta.clubemkt.digital](https://caixapreta.clubemkt.digital/)
- 📱 **WhatsApp**: [+55 73 98808-3318](https://wa.me/5573988083318)
- 💬 **Comunidade**: Acesso exclusivo para clientes
- 📧 **Suporte**: Disponível no bundle completo

---

**⚡ Transforme sua infraestrutura em minutos, não em semanas!**

*Este produto é parte da Comunidade CaixaPreta - A solução mais completa de automação do mercado brasileiro.*
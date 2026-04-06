# 🚀 Infra Caixa Preta v2 - Infraestrutura Automatizada

**Parte do Ecossistema Caixa Preta** | [Visite nosso site](https://caixapreta.clubemkt.digital/)

## 📋 Sobre o Produto

O **Infra Caixa Preta v2** é uma solução completa de infraestrutura automatizada que permite a **não-técnicos** instalar e configurar uma stack profissional de automação e atendimento em poucos minutos, sem conhecimento técnico avançado.

### 🎯 Para Quem é Este Produto?

- **Empreendedores digitais** que precisam de automação profissional
- **Agências de marketing** que querem oferecer soluções completas
- **Consultores** que precisam de infraestrutura rápida para clientes
- **Qualquer pessoa** que quer uma stack profissional sem complicação técnica

## 🏗️ O Que Você Recebe

### Stack Completa Inclui:

- **🤖 n8n** - Automação de processos e workflows
- **💬 MEGA (Chatwoot V4)** - Atendimento multicanal profissional
- **📱 Evolution API** - Integração WhatsApp Business (suporta múltiplas instâncias)
- **� Gowa WhatsApp API** - API WhatsApp alternativa
- **� Traefik** - Proxy reverso com SSL automático
- **📊 Grafana** - Dashboards e monitoramento
- **💾 MinIO** - Armazenamento de arquivos
- **🗄️ PostgreSQL 15** - Banco de dados robusto
- **⚡ Redis** - Cache e filas de alta performance
- **🐳 Portainer** - Gerenciamento visual de containers

### 🌐 Subdomínios Configurados Automaticamente:

- `n8n.seudominio.com` - Plataforma de automação
- `mega.seudominio.com` - Sistema de atendimento
- `evolution.seudominio.com` - API do WhatsApp (instância 1)
- `evolution2.seudominio.com` - API do WhatsApp (instância 2, se configurado)
- `evolution3.seudominio.com` - API do WhatsApp (instância 3, se configurado)
- `gowa.seudominio.com` - API Gowa WhatsApp
- `portainer.seudominio.com` - Gerenciamento de containers
- `traefik.seudominio.com` - Dashboard do proxy
- `minio.seudominio.com` - Console de arquivos
- `grafana.seudominio.com` - Dashboards de monitoramento

## 🚀 Instalação Rápida (5 Minutos)

### Pré-requisitos:
- VPS com Ubuntu/Debian (20.04+)
- Domínio próprio
- Acesso root ao servidor
- Mínimo: 2 vCores, 4GB RAM, 40GB SSD

### Passo a Passo:

1. **Conecte no seu servidor via SSH**

2. **Baixe e execute o script de instalação:**
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/scripts/install/caixapreta-stack-enhanced.sh
chmod +x caixapreta-stack-enhanced.sh
sudo ./caixapreta-stack-enhanced.sh
```

3. **Configure quando solicitado:**
   - Digite seu domínio (ex: `meusite.com`)
   - Digite seu e-mail para SSL
   - Escolha quantas instâncias Evolution API deseja (padrão: 1)

4. **Configure DNS:**
   - Aponte os subdomínios para o IP do seu servidor
   - Aguarde propagação (5-15 minutos)

5. **Valide a instalação (opcional):**
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/scripts/utils/validate-installation.sh
chmod +x validate-installation.sh
sudo ./validate-installation.sh
```

6. **Pronto!** Acesse seus serviços com SSL automático

### 📖 Guia Completo de Instalação

Para um guia detalhado com interface visual, acesse:
**[instalar.caixapreta.clubemkt.digital](https://instalar.caixapreta.clubemkt.digital)**

- 🎭 **Interface profissional**: Guia com tema industrial skeuomorphism
- 🔐 **Acesso restrito**: Solicite a senha via WhatsApp
- 📱 **Interface responsiva**: Funciona em desktop e mobile
- 🛠️ **Seção de troubleshooting**: Inclui todos os scripts de diagnóstico
- 💀 **Utilitário de limpeza**: Script para limpar VPS com falhas

**📱 Para obter acesso ao guia:** [WhatsApp +55 73 98808-3318](https://wa.me/5573988083318)

## 📁 Estrutura do Projeto

```
caixapreta-stack/
├── scripts/
│   ├── install/                    # Scripts de instalação
│   │   ├── caixapreta-stack.sh                    # Instalação básica
│   │   ├── caixapreta-stack-enhanced.sh           # Instalação completa (RECOMENDADO)
│   │   └── caixapreta-stack-orion-style.sh        # Variante alternativa
│   │
│   ├── diagnose/                   # Scripts de diagnóstico
│   │   ├── diagnose-all-services.sh               # Diagnóstico completo
│   │   ├── diagnose-redis.sh                      # Diagnóstico Redis
│   │   ├── diagnose-postgres.sh                   # Diagnóstico PostgreSQL
│   │   ├── diagnose-mega.sh                       # Diagnóstico MEGA/Chatwoot
│   │   ├── diagnose-traefik.sh                    # Diagnóstico Traefik
│   │   ├── diagnose-portainer.sh                  # Diagnóstico Portainer
│   │   ├── diagnose-connectivity.sh               # Diagnóstico de conectividade
│   │   ├── diagnose-ssl-dns.sh                    # Diagnóstico SSL/DNS
│   │   └── diagnose-swarm.sh                      # Diagnóstico Docker Swarm
│   │
│   ├── fix/                        # Scripts de correção automática
│   │   ├── fix-and-redeploy.sh                    # Correção completa
│   │   ├── fix-redis-deployment.sh                # Corrige Redis
│   │   ├── fix-postgres-deployment.sh             # Corrige PostgreSQL
│   │   ├── fix-mega.sh                            # Corrige MEGA/Chatwoot
│   │   ├── fix-traefik-deployment.sh              # Corrige Traefik
│   │   ├── fix-network-conflict.sh                # Corrige conflitos de rede
│   │   ├── fix-docker.sh                          # Corrige Docker
│   │   ├── fix-deployment-issues.sh               # Corrige problemas gerais
│   │   ├── fix-ipv6-services.sh                   # Corrige IPv6
│   │   ├── fix-port-binding.sh                    # Corrige binding de portas
│   │   ├── fix-remaining-services.sh              # Corrige serviços restantes
│   │   └── fix-ssl-services.sh                    # Corrige SSL
│   │
│   └── utils/                      # Scripts utilitários
│       ├── validate-installation.sh                # Valida instalação
│       ├── wipe-vps.sh                            # Limpa VPS completamente
│       ├── check-dns-status.sh                    # Verifica status DNS
│       ├── deploy-to-cloudflare.sh                # Deploy para Cloudflare
│       ├── test-cloudflare-token.sh               # Testa token Cloudflare
│       └── manual-deploy.sh                       # Deploy manual
│
├── docs/                           # Documentação e interface web
│   ├── caixa-preta-landing.html                   # Landing page
│   ├── caixa-preta-login.html                     # Página de login
│   ├── clean-install.html                         # Guia de instalação
│   ├── design-tokens.css                          # Design system centralizado
│   └── ...                         # Outros arquivos de documentação
│
├── .github/
│   └── workflows/
│       └── deploy-cloudflare.yml                  # CI/CD para Cloudflare Pages
│
├── README.md                       # Este arquivo
└── .gitignore                      # Arquivos ignorados pelo Git
```

## 🎯 Qual Script Usar?

### Para Instalação Inicial:
```bash
# Recomendado: Instalação completa com todas as features
sudo ./scripts/install/caixapreta-stack-enhanced.sh

# Alternativa: Instalação básica
sudo ./scripts/install/caixapreta-stack.sh
```

### Para Diagnóstico de Problemas:
```bash
# Diagnóstico completo de todos os serviços
./scripts/diagnose/diagnose-all-services.sh

# Diagnóstico específico
./scripts/diagnose/diagnose-redis.sh
./scripts/diagnose/diagnose-postgres.sh
./scripts/diagnose/diagnose-mega.sh
./scripts/diagnose/diagnose-traefik.sh
```

### Para Corrigir Problemas:
```bash
# Correção automática completa (tenta corrigir tudo)
sudo ./scripts/fix/fix-and-redeploy.sh

# Correção específica
sudo ./scripts/fix/fix-redis-deployment.sh
sudo ./scripts/fix/fix-postgres-deployment.sh
sudo ./scripts/fix/fix-mega.sh
```

### Para Validação e Limpeza:
```bash
# Validar instalação
sudo ./scripts/utils/validate-installation.sh

# Limpar VPS completamente (CUIDADO!)
sudo ./scripts/utils/wipe-vps.sh
```

## 🔄 Fluxo de Resolução de Problemas

1. **Identifique o problema**: Use os scripts de diagnóstico
2. **Execute a correção**: Use o script de correção correspondente
3. **Verifique o resultado**: Execute novamente o diagnóstico
4. **Se persistir**: Use o script de correção completa

```bash
# Exemplo: Problema com Redis
./scripts/diagnose/diagnose-redis.sh              # 1. Diagnosticar
sudo ./scripts/fix/fix-redis-deployment.sh        # 2. Corrigir
./scripts/diagnose/diagnose-redis.sh              # 3. Verificar
```

## 🆕 Admin Painel - Gerenciamento Centralizado

O novo **Admin Painel** oferece uma interface web para gerenciar toda a infraestrutura:

### Funcionalidades:
- 📊 **Dashboard em Tempo Real**: Visualize status de todos os serviços
- 🔍 **Monitoramento**: CPU, memória, disco e uptime
- 🐛 **Debug & Logs**: Acesse logs de qualquer serviço
- ⚙️ **Configurações**: Gerencie DNS, SSL, backups
- 🔄 **Controle de Serviços**: Reinicie serviços com um clique
- 📈 **Métricas**: Acompanhe performance em tempo real

### Acesso:
```
https://seu-dominio.com/painel
```

Ou diretamente pelo IP:
```
https://seu-ip/painel
```

---

## 🆕 Novidades - Múltiplas Instâncias Evolution API

A versão enhanced agora suporta **múltiplas instâncias do Evolution API** rodando em paralelo:

### Como Usar:
1. Durante a instalação, quando perguntado "How many Evolution API instances?", digite o número desejado
2. Cada instância terá:
   - Banco de dados separado (`evolution_db_1`, `evolution_db_2`, etc.)
   - Subdomínio próprio (`evolution.domain.com`, `evolution2.domain.com`, etc.)
   - Volume de dados isolado (`/data/evolution`, `/data/evolution2`, etc.)
   - Configuração independente

### Exemplo:
```bash
# Instalar com 3 instâncias Evolution
sudo ./scripts/install/caixapreta-stack-enhanced.sh
# Quando perguntado: 3
```

Resultado:
- `evolution.seudominio.com` - Instância 1
- `evolution2.seudominio.com` - Instância 2
- `evolution3.seudominio.com` - Instância 3

Cada uma com banco de dados e configuração independentes!

## 💡 Parte do Ecossistema CaixaPreta

Este produto faz parte do **bundle completo CaixaPreta** que inclui:

- ✅ **15.000+ Flows n8n** prontos para usar
- ✅ **Comunidade exclusiva** para networking e suporte
- ✅ **Consultoria completa** com Hudson Argollo
- ✅ **CaixaPreta Stack** (este produto) - Infraestrutura automatizada

[**🔗 Conheça todos os produtos e ofertas**](https://caixapreta.clubemkt.digital/)

## 🛠️ Tecnologias Utilizadas

- **Docker Swarm** - Orquestração de containers
- **Traefik v2.10** - Proxy reverso moderno
- **Let's Encrypt** - SSL gratuito e automático
- **PostgreSQL 15** - Banco com suporte a pgvector
- **Redis 7** - Cache e filas distribuídas
- **n8n Latest** - Automação em modo queue
- **Chatwoot V4** - Atendimento com modificações
- **Evolution API** - Integração WhatsApp (múltiplas instâncias)
- **Gowa WhatsApp API** - API WhatsApp alternativa

## 📞 Suporte e Comunidade

- **Comunidade CaixaPreta**: Acesso exclusivo para clientes
- **Suporte direto**: Com Hudson Argollo e equipe
- **Documentação completa**: Guias passo a passo
- **Updates automáticos**: Sempre na versão mais recente

## � Credenciais Padrão

**Importante**: Altere as senhas após a instalação!

- **PostgreSQL**: `postgres` / [Solicite via WhatsApp](https://wa.me/5573988083318)
- **MinIO**: `admin` / [Solicite via WhatsApp](https://wa.me/5573988083318)
- **Evolution API Key**: [Solicite via WhatsApp](https://wa.me/5573988083318)
- **Gowa API Key**: [Solicite via WhatsApp](https://wa.me/5573988083318)

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

### Para Múltiplas Instâncias Evolution:
- **CPU**: 4+ vCores (adicione 1 vCore por instância extra)
- **RAM**: 8GB+ (adicione 512MB por instância extra)
- **Storage**: 100GB+ SSD

## ⚠️ Resolução de Problemas Comuns

### 🔴 Redis não funciona (0/1 replicas)
**Sintomas:** n8n e MEGA não funcionam, Redis mostra 0/1 replicas

**Solução Rápida:**
```bash
sudo ./scripts/fix/fix-redis-deployment.sh
```

**Diagnóstico Detalhado:**
```bash
./scripts/diagnose/diagnose-redis.sh
```

### � PostgreSQL não inicia (0/1 replicas)
**Sintomas:** Banco não conecta, serviços dependentes falham

**Solução Rápida:**
```bash
sudo ./scripts/fix/fix-postgres-deployment.sh
```

**Diagnóstico Detalhado:**
```bash
./scripts/diagnose/diagnose-postgres.sh
```

### 🟣 MEGA retorna erro 404
**Sintomas:** mega.seudominio.com mostra página 404

**Solução Rápida:**
```bash
sudo ./scripts/fix/fix-mega.sh
```

### 🔒 Certificados SSL não funcionam
**Causa:** DNS não propagado ou configurado incorretamente

**Diagnóstico:**
```bash
./scripts/diagnose/diagnose-ssl-dns.sh
```

**Soluções:**
1. Verifique DNS: `nslookup n8n.seudominio.com`
2. Aguarde propagação (até 24h)
3. Reinicie Traefik: `docker service update --force core_traefik`

### 🌐 Portainer não acessível
**Diagnóstico:**
```bash
./scripts/diagnose/diagnose-portainer.sh
```

### ⚡ Servidor lento ou travando
**Causa:** Falta de recursos (RAM/CPU)

**Diagnóstico:**
```bash
free -h && df -h && docker stats --no-stream
```

### 🔧 Correção Completa (Todos os Problemas)
Se múltiplos serviços estão falhando:

```bash
sudo ./scripts/fix/fix-and-redeploy.sh
```

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

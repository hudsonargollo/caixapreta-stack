# 🚀 Infra Caixa Preta v3 - Infraestrutura Automatizada

**Parte do Ecossistema Caixa Preta** | [Visite nosso site](https://caixapreta.clubemkt.digital/)

## 📋 Sobre o Produto

O **Infra Caixa Preta v3** é uma solução completa de infraestrutura automatizada que permite a **não-técnicos** instalar e configurar uma stack profissional de automação e atendimento em poucos minutos, sem conhecimento técnico avançado.

> **v3 (Abril 2026)** — Redesign completo: Nginx substitui Traefik, SSL via Cloudflare, instalação 3x mais rápida com taxa de sucesso de 95%+.

### 🎯 Para Quem é Este Produto?

- **Empreendedores digitais** que precisam de automação profissional
- **Agências de marketing** que querem oferecer soluções completas
- **Consultores** que precisam de infraestrutura rápida para clientes
- **Qualquer pessoa** que quer uma stack profissional sem complicação técnica

## 🏗️ O Que Você Recebe

### Stack Completa Inclui:

- **🤖 n8n** - Automação de processos e workflows (modo queue com workers)
- **💬 Chatwoot V4 (MEGA)** - Atendimento multicanal profissional
- **📱 Evolution API** - Integração WhatsApp Business (2 instâncias)
- **🌐 Nginx** - Proxy reverso simples e confiável
- **☁️ Cloudflare SSL** - SSL automático sem complexidade Let's Encrypt
- **📊 Grafana** - Dashboards e monitoramento
- **💾 MinIO** - Armazenamento de arquivos (API S3 compatível)
- **🗄️ PostgreSQL 15** - Banco de dados robusto
- **⚡ Redis 7** - Cache e filas de alta performance (instâncias separadas para n8n e MEGA)
- **🐳 Portainer** - Gerenciamento visual de containers

### 🌐 Subdomínios Configurados Automaticamente:

| Subdomínio | Serviço |
|---|---|
| `auto.seudominio.com` | n8n — Automação |
| `evo.seudominio.com` | Evolution API (instância 1) |
| `evo2.seudominio.com` | Evolution API (instância 2) |
| `s3.seudominio.com` | MinIO API (S3) |
| `min.seudominio.com` | MinIO Console |
| `graf.seudominio.com` | Grafana |
| `chat.seudominio.com` | Chatwoot (MEGA) |
| `port.seudominio.com` | Portainer |

## 🚀 Instalação Rápida (~10 Minutos)

### Pré-requisitos:
- VPS com Ubuntu 20.04+ ou Debian 11+
- Domínio com Cloudflare (proxy ativo — nuvem laranja)
- Acesso root ao servidor
- Mínimo: 2 vCores, 4GB RAM, 40GB SSD

### Passo a Passo:

**1. Configure o DNS no Cloudflare** (antes de instalar)

Crie registros A apontando para o IP do seu VPS, com proxy ativo (nuvem laranja):

```
auto.seudominio.com  → IP do VPS  (Proxied)
evo.seudominio.com   → IP do VPS  (Proxied)
evo2.seudominio.com  → IP do VPS  (Proxied)
s3.seudominio.com    → IP do VPS  (Proxied)
min.seudominio.com   → IP do VPS  (Proxied)
graf.seudominio.com  → IP do VPS  (Proxied)
chat.seudominio.com  → IP do VPS  (Proxied)
port.seudominio.com  → IP do VPS  (Proxied)
```

**2. Conecte no servidor e execute o instalador:**

```bash
ssh root@ip-do-seu-servidor

git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack

bash scripts/install/caixapreta-stack-production.sh
```

**3. Informe quando solicitado:**
```
Domain: seudominio.com
Email:  seu@email.com
```

**4. Aguarde ~10 minutos** — o instalador cuida de tudo automaticamente.

**5. Acesse seus serviços** com SSL válido via Cloudflare.

### 📖 Guia Completo de Instalação

Para um guia detalhado com interface visual, acesse:
**[instalar.caixapreta.clubemkt.digital](https://instalar.caixapreta.clubemkt.digital)**

**📱 Para obter acesso ao guia:** [WhatsApp +55 73 98808-3318](https://wa.me/5573988083318)

## 🔐 Credenciais Padrão

Todos os serviços usam a mesma senha padrão após a instalação:

```
Usuário: admin (ou específico do serviço)
Senha:   caixapretastack2626
```

> ⚠️ **Altere todas as senhas imediatamente após o primeiro acesso!**

## 🏛️ Arquitetura v3

```
Usuário (HTTPS com SSL Cloudflare)
    ↓
Cloudflare (SSL Termination + DDoS Protection)
    ↓
VPS — Nginx (Proxy Reverso com certificado self-signed interno)
    ↓
Serviços Docker Swarm (rede interna isolada)
```

**Por que Nginx + Cloudflare?**
- Sem complexidade do Let's Encrypt / ACME
- SSL válido para o usuário final via Cloudflare
- Configuração simples e fácil de entender
- Disponibilidade imediata dos serviços

## 📁 Estrutura do Projeto

```
caixapreta-stack/
├── scripts/
│   ├── install/
│   │   ├── caixapreta-stack-production.sh     # ✅ RECOMENDADO — Instalador v3
│   │   ├── caixapreta-stack-enhanced.sh       # Instalador v2 (legado)
│   │   └── caixapreta-stack.sh                # Instalador básico (legado)
│   │
│   ├── diagnose/                              # Scripts de diagnóstico
│   │   ├── diagnose-all-services.sh
│   │   ├── diagnose-redis.sh
│   │   ├── diagnose-postgres.sh
│   │   ├── diagnose-mega.sh
│   │   ├── diagnose-traefik.sh
│   │   ├── diagnose-portainer.sh
│   │   ├── diagnose-connectivity.sh
│   │   ├── diagnose-ssl-dns.sh
│   │   └── diagnose-swarm.sh
│   │
│   ├── fix/                                   # Scripts de correção automática
│   │   ├── fix-and-redeploy.sh
│   │   ├── fix-redis-deployment.sh
│   │   ├── fix-postgres-deployment.sh
│   │   ├── fix-mega.sh
│   │   ├── fix-traefik-deployment.sh
│   │   ├── fix-network-conflict.sh
│   │   ├── fix-docker.sh
│   │   ├── fix-deployment-issues.sh
│   │   ├── fix-ipv6-services.sh
│   │   ├── fix-port-binding.sh
│   │   ├── fix-remaining-services.sh
│   │   └── fix-ssl-services.sh
│   │
│   └── utils/                                 # Scripts utilitários
│       ├── validate-installation.sh
│       ├── wipe-vps.sh
│       ├── check-dns-status.sh
│       ├── setup-painel.sh
│       ├── deploy-to-cloudflare.sh
│       ├── test-cloudflare-token.sh
│       └── manual-deploy.sh
│
├── docs/                                      # Documentação e interface web
│   ├── caixa-preta-landing.html
│   ├── caixa-preta-login.html
│   ├── design-tokens.css
│   └── ...
│
├── QUICK_START_PRODUCTION.md                  # Guia rápido v3
├── PRODUCTION_INSTALLER.md                    # Guia completo v3
├── DEPLOYMENT_GUIDE_v3.md                     # Guia de deploy v3
├── RELEASE_NOTES_v3.md                        # Notas de versão v3
├── DEPLOYMENT_CHECKLIST.md                    # Checklist de deploy
└── README.md
```

## 🎯 Qual Script Usar?

### Para Instalação Inicial (v3 — Recomendado):
```bash
bash scripts/install/caixapreta-stack-production.sh
```

### Para Diagnóstico de Problemas:
```bash
# Diagnóstico completo
./scripts/diagnose/diagnose-all-services.sh

# Diagnóstico específico
./scripts/diagnose/diagnose-redis.sh
./scripts/diagnose/diagnose-postgres.sh
./scripts/diagnose/diagnose-mega.sh
```

### Para Corrigir Problemas:
```bash
# Correção automática completa
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

## 🔄 Comandos Essenciais Pós-Instalação

```bash
# Ver todos os serviços
docker service ls

# Ver logs de um serviço
docker service logs <nome_do_servico> --tail 50

# Reiniciar um serviço
docker service update --force <nome_do_servico>

# Verificar uso de recursos
docker stats

# Backup dos dados
tar -czf backup-$(date +%Y%m%d).tar.gz /data/
```

## ⚠️ Resolução de Problemas Comuns

### 🔴 Serviço mostra 0/1 replicas
```bash
docker service logs <nome_do_servico> --tail 50
docker service update --force <nome_do_servico>
```

### 🔒 Erro 404 nos subdomínios
Verifique se o DNS está proxiado pelo Cloudflare (nuvem laranja):
```bash
nslookup auto.seudominio.com 8.8.8.8
# Deve retornar IPs da Cloudflare (104.21.x.x ou 172.67.x.x)
```

### ⚠️ Aviso de certificado SSL
Normal — o Nginx usa certificado self-signed internamente. O usuário final vê SSL válido via Cloudflare. Para testar via curl:
```bash
curl -k https://auto.seudominio.com
```

### 🗄️ PostgreSQL não conecta
```bash
docker service logs core_db_db_postgres --tail 20
docker service update --force core_db_db_postgres
```

### ⚡ Redis com problemas
```bash
sudo ./scripts/fix/fix-redis-deployment.sh
```

### 🔧 Múltiplos serviços falhando
```bash
sudo ./scripts/fix/fix-and-redeploy.sh
```

## 🆕 O Que Mudou na v3

| Aspecto | v2 | v3 |
|---|---|---|
| Proxy Reverso | Traefik | Nginx |
| SSL | Let's Encrypt (ACME) | Cloudflare Flexible + HTTP interno |
| Tempo de Instalação | 15-20 min | 5-10 min |
| Taxa de Sucesso | ~60% | 95%+ |
| Problemas de SSL | Frequentes | Resolvidos |
| Subdomínios | `n8n.`, `mega.`, `evolution.` | `auto.`, `chat.`, `evo.` |
| Evolution API | atendai (desatualizado) | evoapicloud v2.3.7+ (QR funcionando) |
| Chatwoot | sendingtk fork (quebrado) | chatwoot/chatwoot v3.11.0 |

---

## 🦞 OpenClaw — Assistente de IA Pessoal

O **OpenClaw** é um assistente de IA pessoal open-source que roda no seu próprio servidor ou máquina. Integra com WhatsApp, Telegram, Slack, Discord e 20+ canais. Extensível com mais de 5.400 skills da comunidade.

### Instalação Rápida

```bash
curl -fsSL https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/scripts/install/openclaw-install.sh | bash
```

Ou baixe e execute:

```bash
curl -fsSL https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/scripts/install/openclaw-install.sh -o openclaw-install.sh
chmod +x openclaw-install.sh
bash openclaw-install.sh
```

### O que o instalador faz:

1. **Verifica/instala Node.js 24** (requisito mínimo: 22+)
2. **Instala OpenClaw** via npm ou pnpm
3. **Configura o modelo de IA** (OpenAI, Anthropic, ou manual)
4. **Instala skill packs** da comunidade:
   - 🤖 Automação & n8n
   - 💬 WhatsApp & mensagens
   - 🔍 Pesquisa & research
   - 📊 DevOps & cloud
   - 🌐 Browser & automação web
5. **Executa o onboard** interativo (opcional)

### Comandos Principais

```bash
openclaw onboard --install-daemon   # Setup completo com daemon
openclaw gateway --port 18789       # Iniciar gateway
openclaw agent --message "Olá"      # Falar com o assistente
openclaw doctor                     # Verificar saúde
```

### Skills Recomendadas

Explore mais de 5.400 skills em [awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) ou instale diretamente:

```bash
clawhub install n8n                    # Integração n8n
clawhub install openclaw-free-web-search  # Busca web gratuita
clawhub install agent-deep-research    # Pesquisa profunda
clawhub install agentic-devops         # DevOps automatizado
clawhub install elevenlabs-tts         # Text-to-speech
```

**Links:**
- 🦞 [openclaw.ai](https://openclaw.ai) — Documentação oficial
- 🔌 [clawhub.ai](https://clawhub.ai) — Registry de skills
- ⭐ [awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) — 5.400+ skills categorizadas

## ⚠️ Requisitos do Servidor

### Mínimo:
- **CPU**: 2 vCores
- **RAM**: 4GB
- **Storage**: 40GB SSD
- **OS**: Ubuntu 20.04+ ou Debian 11+

### Recomendado para Produção:
- **CPU**: 4+ vCores
- **RAM**: 8GB+
- **Storage**: 100GB+ SSD

## 💡 Parte do Ecossistema CaixaPreta

Este produto faz parte do **bundle completo CaixaPreta** que inclui:

- ✅ **15.000+ Flows n8n** prontos para usar
- ✅ **Comunidade exclusiva** para networking e suporte
- ✅ **Consultoria completa** com Hudson Argollo
- ✅ **CaixaPreta Stack** (este produto) — Infraestrutura automatizada

[**🔗 Conheça todos os produtos e ofertas**](https://caixapreta.clubemkt.digital/)

## 🛠️ Tecnologias Utilizadas

- **Docker Swarm** — Orquestração de containers
- **Nginx** — Proxy reverso simples e confiável
- **Cloudflare** — SSL e proteção DDoS
- **PostgreSQL 15** — Banco com suporte a pgvector
- **Redis 7** — Cache e filas distribuídas (instâncias separadas)
- **n8n Latest** — Automação em modo queue com workers
- **Chatwoot V4** — Atendimento multicanal
- **Evolution API** — Integração WhatsApp (2 instâncias)
- **MinIO** — Armazenamento S3-compatível
- **Grafana** — Monitoramento e dashboards
- **Portainer** — Gerenciamento visual Docker

## 📞 Suporte e Comunidade

- **Comunidade CaixaPreta**: Acesso exclusivo para clientes
- **Suporte direto**: Com Hudson Argollo e equipe
- **Documentação completa**: Guias passo a passo
- **GitHub Issues**: [github.com/hudsonargollo/caixapreta-stack/issues](https://github.com/hudsonargollo/caixapreta-stack/issues)

## 🚨 Pós-Instalação

1. **Altere todas as senhas padrão** (`caixapretastack2626`)
2. **Configure backups automáticos** do diretório `/data/`
3. **Monitore recursos** via Grafana (`graf.seudominio.com`)
4. **Teste todas as integrações**
5. **Configure firewall** (UFW já instalado pelo script)

---

## 📞 Precisa de Ajuda?

- 🌐 **Site oficial**: [caixapreta.clubemkt.digital](https://caixapreta.clubemkt.digital/)
- 📱 **WhatsApp**: [+55 73 98808-3318](https://wa.me/5573988083318)
- 💬 **Comunidade**: Acesso exclusivo para clientes
- 📖 **Docs completos**: `PRODUCTION_INSTALLER.md` e `DEPLOYMENT_GUIDE_v3.md`

---

**⚡ Transforme sua infraestrutura em minutos, não em semanas!**

*Este produto é parte da Comunidade CaixaPreta — A solução mais completa de automação do mercado brasileiro.*

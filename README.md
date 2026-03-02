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
wget https://raw.githubusercontent.com/[seu-usuario]/caixapreta-stack/main/caixapreta-stack.sh
chmod +x caixapreta-stack.sh
sudo ./caixapreta-stack.sh
```

3. **Configure quando solicitado:**
   - Digite seu domínio (ex: `meusite.com`)
   - Digite seu e-mail para SSL

4. **Configure DNS:**
   - Aponte os subdomínios para o IP do seu servidor
   - Aguarde propagação (5-15 minutos)

5. **Pronto!** Acesse seus serviços com SSL automático

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
- **Chatwoot V4** - Atendimento com modificações Valus/Nestor

## 📞 Suporte e Comunidade

- **Comunidade CaixaPreta**: Acesso exclusivo para clientes
- **Suporte direto**: Com Hudson Argollo e equipe
- **Documentação completa**: Guias passo a passo
- **Updates automáticos**: Sempre na versão mais recente

## 🔐 Credenciais Padrão

**Importante**: Altere as senhas após a instalação!

- **PostgreSQL**: `postgres` / `caixapretastack2626`
- **MinIO**: `admin` / `caixapretastack2626`
- **Evolution API Key**: `caixapretastack2626`

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
- 💬 **Comunidade**: Acesso exclusivo para clientes
- 📧 **Suporte**: Disponível no bundle completo

---

**⚡ Transforme sua infraestrutura em minutos, não em semanas!**

*Este produto é parte do bundle CaixaPreta - A solução mais completa de automação do mercado brasileiro.*
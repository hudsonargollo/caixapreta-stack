# 📚 Referência Completa de Scripts

Guia rápido para todos os scripts disponíveis no Infra Caixa Preta v2.

## 📦 Scripts de Instalação

Localização: `scripts/install/`

### caixapreta-stack-enhanced.sh ⭐ RECOMENDADO
**Instalação completa com todas as features**

```bash
sudo ./scripts/install/caixapreta-stack-enhanced.sh
```

**Inclui:**
- ✅ Docker Swarm setup
- ✅ Traefik com SSL automático
- ✅ PostgreSQL 15
- ✅ Redis (n8n e MEGA)
- ✅ n8n com workers
- ✅ MEGA/Chatwoot V4
- ✅ Evolution API (múltiplas instâncias)
- ✅ Gowa WhatsApp API
- ✅ MinIO
- ✅ Portainer
- ✅ Grafana

**Prompts:**
- Domínio
- Email para SSL
- Número de instâncias Evolution API (padrão: 1)

---

### caixapreta-stack.sh
**Instalação básica**

```bash
sudo ./scripts/install/caixapreta-stack.sh
```

Versão simplificada com funcionalidades essenciais.

---

### caixapreta-stack-orion-style.sh
**Variante alternativa**

```bash
sudo ./scripts/install/caixapreta-stack-orion-style.sh
```

Versão com configurações alternativas.

---

## 🔍 Scripts de Diagnóstico

Localização: `scripts/diagnose/`

Use estes scripts para **identificar problemas** sem fazer alterações.

### diagnose-all-services.sh
**Diagnóstico completo de todos os serviços**

```bash
./scripts/diagnose/diagnose-all-services.sh
```

Verifica:
- Status de todos os containers
- Conectividade entre serviços
- Saúde dos bancos de dados
- Configuração de SSL/DNS
- Recursos do servidor

---

### diagnose-redis.sh
**Diagnóstico do Redis**

```bash
./scripts/diagnose/diagnose-redis.sh
```

Verifica:
- Status do Redis (n8n e MEGA)
- Conectividade
- Uso de memória
- Replicação

**Quando usar:** Redis mostra 0/1 replicas

---

### diagnose-postgres.sh
**Diagnóstico do PostgreSQL**

```bash
./scripts/diagnose/diagnose-postgres.sh
```

Verifica:
- Status do PostgreSQL
- Conectividade
- Bancos de dados
- Espaço em disco

**Quando usar:** PostgreSQL não conecta

---

### diagnose-mega.sh
**Diagnóstico do MEGA/Chatwoot**

```bash
./scripts/diagnose/diagnose-mega.sh
```

Verifica:
- Status do container
- Conectividade com banco
- Logs de erro
- Configuração

**Quando usar:** MEGA retorna erro 404

---

### diagnose-traefik.sh
**Diagnóstico do Traefik**

```bash
./scripts/diagnose/diagnose-traefik.sh
```

Verifica:
- Status do Traefik
- Certificados SSL
- Rotas configuradas
- Logs de erro

**Quando usar:** SSL não funciona ou subdomínios não resolvem

---

### diagnose-portainer.sh
**Diagnóstico do Portainer**

```bash
./scripts/diagnose/diagnose-portainer.sh
```

Verifica:
- Status do Portainer
- Conectividade
- Logs

**Quando usar:** Portainer não acessível

---

### diagnose-connectivity.sh
**Diagnóstico de conectividade**

```bash
./scripts/diagnose/diagnose-connectivity.sh
```

Verifica:
- Conectividade entre containers
- Redes Docker
- Resolução DNS

**Quando usar:** Serviços não conseguem se comunicar

---

### diagnose-ssl-dns.sh
**Diagnóstico de SSL e DNS**

```bash
./scripts/diagnose/diagnose-ssl-dns.sh
```

Verifica:
- Propagação de DNS
- Certificados SSL
- Validade de certificados

**Quando usar:** Certificados SSL não funcionam

---

### diagnose-swarm.sh
**Diagnóstico do Docker Swarm**

```bash
./scripts/diagnose/diagnose-swarm.sh
```

Verifica:
- Status do Swarm
- Nós do cluster
- Serviços
- Redes

**Quando usar:** Problemas gerais de orquestração

---

## 🔧 Scripts de Correção

Localização: `scripts/fix/`

Use estes scripts para **corrigir problemas identificados**.

### fix-and-redeploy.sh ⭐ PARA EMERGÊNCIAS
**Correção completa - tenta corrigir TUDO**

```bash
sudo ./scripts/fix/fix-and-redeploy.sh
```

**O que faz:**
- Limpa containers com problemas
- Recria serviços
- Reinicializa redes
- Reaplica configurações

**Quando usar:** Múltiplos serviços falhando

⚠️ **Aviso:** Pode causar downtime temporário

---

### fix-redis-deployment.sh
**Corrige problemas do Redis**

```bash
sudo ./scripts/fix/fix-redis-deployment.sh
```

**Resolve:**
- Redis 0/1 replicas
- Problemas de conectividade
- Erros de memória

---

### fix-postgres-deployment.sh
**Corrige problemas do PostgreSQL**

```bash
sudo ./scripts/fix/fix-postgres-deployment.sh
```

**Resolve:**
- PostgreSQL 0/1 replicas
- Problemas de conectividade
- Erros de banco de dados

---

### fix-mega.sh
**Corrige problemas do MEGA/Chatwoot**

```bash
sudo ./scripts/fix/fix-mega.sh
```

**Resolve:**
- Erro 404 no MEGA
- Problemas de banco de dados
- Erros de inicialização

---

### fix-traefik-deployment.sh
**Corrige problemas do Traefik**

```bash
sudo ./scripts/fix/fix-traefik-deployment.sh
```

**Resolve:**
- SSL não funciona
- Subdomínios não resolvem
- Problemas de roteamento

---

### fix-network-conflict.sh
**Corrige conflitos de rede**

```bash
sudo ./scripts/fix/fix-network-conflict.sh
```

**Resolve:**
- Conflitos de IP
- Problemas de rede overlay
- Erros de conectividade

---

### fix-docker.sh
**Corrige problemas do Docker**

```bash
sudo ./scripts/fix/fix-docker.sh
```

**Resolve:**
- Docker daemon não responde
- Problemas de socket
- Erros de permissão

---

### fix-deployment-issues.sh
**Corrige problemas gerais de deployment**

```bash
sudo ./scripts/fix/fix-deployment-issues.sh
```

**Resolve:**
- Serviços não iniciam
- Problemas de volume
- Erros de configuração

---

### fix-ipv6-services.sh
**Corrige problemas de IPv6**

```bash
sudo ./scripts/fix/fix-ipv6-services.sh
```

**Resolve:**
- Problemas com IPv6
- Conflitos de endereço
- Erros de roteamento IPv6

---

### fix-port-binding.sh
**Corrige problemas de binding de portas**

```bash
sudo ./scripts/fix/fix-port-binding.sh
```

**Resolve:**
- Portas já em uso
- Erros de binding
- Conflitos de porta

---

### fix-remaining-services.sh
**Corrige serviços restantes**

```bash
sudo ./scripts/fix/fix-remaining-services.sh
```

**Resolve:**
- Serviços secundários com problemas
- Configurações faltantes
- Erros de inicialização

---

### fix-ssl-services.sh
**Corrige problemas de SSL**

```bash
sudo ./scripts/fix/fix-ssl-services.sh
```

**Resolve:**
- Certificados expirados
- Problemas de renovação
- Erros de SSL

---

## 🛠️ Scripts Utilitários

Localização: `scripts/utils/`

### validate-installation.sh
**Valida se a instalação foi bem-sucedida**

```bash
sudo ./scripts/utils/validate-installation.sh
```

Verifica:
- Todos os serviços rodando
- Conectividade
- SSL funcionando
- Bancos de dados acessíveis

**Quando usar:** Após instalação para confirmar sucesso

---

### wipe-vps.sh ⚠️ CUIDADO!
**Limpa VPS completamente**

```bash
sudo ./scripts/utils/wipe-vps.sh
```

**O que faz:**
- Remove todos os containers
- Remove todas as imagens
- Remove todos os volumes
- Remove todas as redes
- Limpa dados

⚠️ **AVISO:** Isso **DELETA TUDO**! Use apenas se tiver certeza!

---

### check-dns-status.sh
**Verifica status de DNS**

```bash
./scripts/utils/check-dns-status.sh
```

Verifica:
- Propagação de DNS
- Resolução de subdomínios
- Registros A/CNAME

---

### deploy-to-cloudflare.sh
**Deploy para Cloudflare Pages**

```bash
./scripts/utils/deploy-to-cloudflare.sh
```

Faz deploy da documentação para Cloudflare Pages.

---

### test-cloudflare-token.sh
**Testa token do Cloudflare**

```bash
./scripts/utils/test-cloudflare-token.sh
```

Valida se o token Cloudflare está funcionando.

---

### manual-deploy.sh
**Deploy manual**

```bash
./scripts/utils/manual-deploy.sh
```

Permite deploy manual de serviços específicos.

---

## 🔄 Fluxo Recomendado de Resolução

### Passo 1: Diagnosticar
```bash
./scripts/diagnose/diagnose-all-services.sh
```

### Passo 2: Identificar o Problema
Leia a saída e identifique qual serviço está com problema.

### Passo 3: Corrigir Específico
```bash
# Se Redis tem problema:
sudo ./scripts/fix/fix-redis-deployment.sh

# Se PostgreSQL tem problema:
sudo ./scripts/fix/fix-postgres-deployment.sh

# Se MEGA tem problema:
sudo ./scripts/fix/fix-mega.sh
```

### Passo 4: Verificar
```bash
./scripts/diagnose/diagnose-all-services.sh
```

### Passo 5: Se Persistir
```bash
sudo ./scripts/fix/fix-and-redeploy.sh
```

---

## 📋 Checklist de Instalação

- [ ] Executar `caixapreta-stack-enhanced.sh`
- [ ] Configurar domínio
- [ ] Configurar email para SSL
- [ ] Escolher número de instâncias Evolution
- [ ] Configurar DNS
- [ ] Aguardar propagação DNS (5-15 min)
- [ ] Executar `validate-installation.sh`
- [ ] Acessar todos os subdomínios
- [ ] Alterar senhas padrão
- [ ] Configurar backups

---

## 🆘 Suporte Rápido

**Problema:** Não sei qual script usar
**Solução:** Execute `diagnose-all-services.sh` primeiro

**Problema:** Múltiplos serviços falhando
**Solução:** Execute `fix-and-redeploy.sh`

**Problema:** Preciso limpar tudo
**Solução:** Execute `wipe-vps.sh` (CUIDADO!)

**Problema:** Preciso de ajuda
**Solução:** [WhatsApp +55 73 98808-3318](https://wa.me/5573988083318)

---

*Última atualização: 2024*

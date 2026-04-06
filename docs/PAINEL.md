# 🎛️ Admin Painel - Documentação Completa

O **Admin Painel** é um dashboard web centralizado para gerenciar toda a infraestrutura Caixa Preta.

## 🚀 Acesso

### Via Domínio (Recomendado)
```
https://seu-dominio.com/painel
```

### Via IP do Servidor
```
https://seu-ip/painel
```

## 📊 Dashboard Principal

### Status Geral
- **Overall Status**: Status operacional geral do sistema
- **Serviços**: Quantidade de serviços rodando vs total
- **Última Atualização**: Timestamp da última verificação

### Estatísticas em Tempo Real
- **CPU Usage**: Percentual de uso de CPU
- **Memory Usage**: Percentual de uso de memória RAM
- **Disk Usage**: Percentual de uso de disco
- **Uptime**: Tempo que o servidor está ligado

## 🔧 Serviços Instalados

Visualize todos os serviços com:
- **Status**: Running/Stopped/Warning
- **Replicas**: Quantidade de instâncias rodando
- **CPU**: Uso de CPU do serviço
- **Memory**: Uso de memória do serviço
- **URL**: Link para acessar o serviço

### Ações Disponíveis
- **📋 Logs**: Visualizar logs do serviço
- **🔄 Restart**: Reiniciar o serviço

## 🐛 Debug & Logs

### Console de Logs
- Visualize logs em tempo real
- Filtro por tipo (Info, Success, Warning, Error)
- Atualização automática a cada 10 segundos

### Ações
- **🔄 Atualizar Logs**: Força atualização imediata
- **🗑️ Limpar**: Limpa o console de logs

## ⚙️ Configurações

### 🌐 Configurar DNS
Configure registros DNS para seus subdomínios:
- Domínio
- Subdomínio
- IP do Servidor

### 🔒 Renovar SSL
Renove certificados SSL para qualquer serviço:
- Selecione o serviço
- Clique em "Renovar"
- Certificado será renovado automaticamente

### 💾 Backup
Crie backups da infraestrutura:
- **Completo**: Todos os dados
- **Bancos de Dados**: Apenas PostgreSQL e Redis
- **Configurações**: Apenas arquivos de configuração

### 🔄 Reiniciar Serviço
Reinicie qualquer serviço:
- Selecione o serviço
- Clique em "Reiniciar"
- Serviço será reiniciado com downtime mínimo

## 📡 API Endpoints

O painel expõe uma API REST para integração:

### GET /api/health
Verifica saúde do painel
```bash
curl https://seu-dominio.com/api/health
```

### GET /api/services
Lista todos os serviços
```bash
curl https://seu-dominio.com/api/services
```

### GET /api/services/:service
Detalhes de um serviço específico
```bash
curl https://seu-dominio.com/api/services/n8n
```

### GET /api/logs/:service
Logs de um serviço
```bash
curl https://seu-dominio.com/api/logs/n8n
```

### GET /api/stats
Estatísticas do sistema
```bash
curl https://seu-dominio.com/api/stats
```

### POST /api/services/:service/restart
Reinicia um serviço
```bash
curl -X POST https://seu-dominio.com/api/services/n8n/restart
```

## 🎨 Design

O painel utiliza o design system **Industrial Skeuomorphism** com:
- Tema escuro profissional
- Neumorphic shadows
- Indicadores LED animados
- Tipografia monospace
- Responsivo para mobile

## 🔐 Segurança

### Recomendações
1. **Altere a senha padrão** do servidor
2. **Configure firewall** para restringir acesso
3. **Use HTTPS** sempre (automático via Traefik)
4. **Monitore logs** regularmente
5. **Faça backups** frequentes

### Acesso Restrito
Para restringir acesso ao painel, configure no Traefik:
```yaml
# Adicione autenticação básica
traefik.http.middlewares.painel-auth.basicauth.users=admin:password
```

## 🐛 Troubleshooting

### Painel não carrega
1. Verifique se o serviço está rodando: `docker service ls | grep painel`
2. Verifique logs: `docker service logs painel_painel`
3. Reinicie: `docker service update --force painel_painel`

### Dados não atualizam
1. Verifique conexão com Docker socket
2. Verifique permissões: `ls -la /var/run/docker.sock`
3. Reinicie o painel

### Erro ao reiniciar serviço
1. Verifique se o serviço existe: `docker service ls`
2. Verifique permissões do Docker socket
3. Tente via CLI: `docker service update --force nome-do-servico`

## 📱 Acesso Mobile

O painel é totalmente responsivo e funciona em:
- Smartphones
- Tablets
- Desktops

## 🔄 Atualizações

O painel é atualizado automaticamente:
- Estatísticas: A cada 5 segundos
- Logs: A cada 10 segundos
- Status: Em tempo real

## 💡 Dicas

1. **Bookmark o painel**: Adicione aos favoritos para acesso rápido
2. **Monitore regularmente**: Verifique status diariamente
3. **Configure alertas**: Use Grafana para alertas automáticos
4. **Mantenha backups**: Faça backup regularmente
5. **Revise logs**: Procure por erros e warnings

## 🆘 Suporte

Se encontrar problemas:
1. Verifique a documentação
2. Consulte os logs do painel
3. Execute diagnóstico: `./scripts/diagnose/diagnose-all-services.sh`
4. Contate suporte: [WhatsApp +55 73 98808-3318](https://wa.me/5573988083318)

---

**Última atualização**: 2024
**Versão**: 1.0

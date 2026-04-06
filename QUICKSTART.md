# ⚡ Quick Start Guide

Comece em 5 minutos!

## 🚀 Instalação Rápida

### 1. SSH no seu servidor
```bash
ssh root@seu-servidor-ip
```

### 2. Baixe e execute
```bash
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/scripts/install/caixapreta-stack-enhanced.sh
chmod +x caixapreta-stack-enhanced.sh
sudo ./caixapreta-stack-enhanced.sh
```

### 3. Responda as perguntas
- **Domínio**: `seu-dominio.com`
- **Email**: `seu-email@example.com`
- **Evolution instances**: `1` (ou mais se quiser múltiplas)

### 4. Configure DNS
Aponte estes registros para o IP do seu servidor:
```
n8n.seu-dominio.com          A  seu-ip
mega.seu-dominio.com         A  seu-ip
evolution.seu-dominio.com    A  seu-ip
gowa.seu-dominio.com         A  seu-ip
portainer.seu-dominio.com    A  seu-ip
traefik.seu-dominio.com      A  seu-ip
minio.seu-dominio.com        A  seu-ip
grafana.seu-dominio.com      A  seu-ip
```

### 5. Aguarde 5-15 minutos
SSL é gerado automaticamente!

### 6. Acesse seus serviços
- 🤖 n8n: https://n8n.seu-dominio.com
- 💬 MEGA: https://mega.seu-dominio.com
- 📱 Evolution: https://evolution.seu-dominio.com
- 🐳 Portainer: https://portainer.seu-dominio.com

## 🆘 Algo deu errado?

### Verificar status
```bash
./scripts/diagnose/diagnose-all-services.sh
```

### Corrigir automaticamente
```bash
sudo ./scripts/fix/fix-and-redeploy.sh
```

### Validar instalação
```bash
sudo ./scripts/utils/validate-installation.sh
```

## 📚 Próximos Passos

1. **Leia o README completo**: `README.md`
2. **Conheça todos os scripts**: `SCRIPTS.md`
3. **Altere as senhas padrão**
4. **Configure backups**
5. **Explore a comunidade CaixaPreta**

## 🆕 Múltiplas Instâncias Evolution

Quer rodar 3 instâncias Evolution em paralelo?

Durante a instalação, quando perguntado:
```
How many Evolution API instances do you want to deploy? (default: 1):
```

Digite: `3`

Resultado:
- `evolution.seu-dominio.com` (instância 1)
- `evolution2.seu-dominio.com` (instância 2)
- `evolution3.seu-dominio.com` (instância 3)

Cada uma com banco de dados e configuração independentes!

## 📞 Precisa de Ajuda?

- 📱 WhatsApp: [+55 73 98808-3318](https://wa.me/5573988083318)
- 🌐 Site: [caixapreta.clubemkt.digital](https://caixapreta.clubemkt.digital/)
- 💬 Comunidade: Acesso exclusivo para clientes

---

**Pronto! Sua infraestrutura profissional está rodando! 🎉**

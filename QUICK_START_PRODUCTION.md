# Quick Start - Caixa Preta Production v3

## 5-Minute Setup

### Prerequisites
- VPS with Ubuntu/Debian
- Domain with Cloudflare
- Root SSH access

### Step 1: Prepare DNS (2 minutes)

1. Add domain to Cloudflare
2. Create A records pointing to your VPS IP:
   ```
   auto.yourdomain.com    → 62.171.137.90
   evo.yourdomain.com     → 62.171.137.90
   evo2.yourdomain.com    → 62.171.137.90
   min.yourdomain.com     → 62.171.137.90
   s3.yourdomain.com      → 62.171.137.90
   graf.yourdomain.com    → 62.171.137.90
   chat.yourdomain.com    → 62.171.137.90
   port.yourdomain.com    → 62.171.137.90
   ```

3. **Enable Cloudflare proxying** (orange cloud) for all records

### Step 2: Run Installer (3 minutes)

```bash
# SSH to VPS
ssh root@your-vps-ip

# Clone repo
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack

# Run installer
bash scripts/install/caixapreta-stack-production.sh
```

When prompted:
```
Domain: yourdomain.com
Email: your-email@example.com
```

### Step 3: Access Services

After installation completes, access your services:

```
https://auto.yourdomain.com      (n8n)
https://evo.yourdomain.com       (Evolution API)
https://min.yourdomain.com       (MinIO)
https://graf.yourdomain.com      (Grafana)
https://chat.yourdomain.com      (Chatwoot)
https://port.yourdomain.com      (Portainer)
```

**Default password for all**: `caixapretastack2626`

## Verify Installation

```bash
# Check all services running
docker service ls

# Should show 12+ services with 1/1 replicas

# Test n8n
curl -k https://auto.yourdomain.com | head -c 100

# Should return HTML (n8n interface)
```

## Common Commands

```bash
# View logs
docker service logs core_nginx --tail 50

# Restart a service
docker service update --force automation_n8n

# Check service status
docker service ps automation_n8n

# View all services
docker service ls
```

## Troubleshooting

### Services show 0/1 replicas
```bash
# Check logs
docker service logs <service_name> --tail 50

# Restart service
docker service update --force <service_name>
```

### Getting 404 errors
```bash
# Verify DNS is proxied through Cloudflare
nslookup auto.yourdomain.com 8.8.8.8

# Should show Cloudflare IPs (104.21.x.x or 172.67.x.x)
# NOT your VPS IP directly
```

### SSL certificate warnings
This is normal! Use `curl -k` to bypass:
```bash
curl -k https://auto.yourdomain.com
```

End users see valid Cloudflare SSL in their browsers.

## Next Steps

1. **Change default passwords** - Log into each service and update passwords
2. **Configure backups** - Set up automated backups of `/data/`
3. **Monitor services** - Check logs regularly
4. **Read full documentation** - See `PRODUCTION_INSTALLER.md`

## Support

- Full docs: `PRODUCTION_INSTALLER.md`
- Issues: GitHub issues
- Logs: `docker service logs <service_name>`

---

**Installation complete! Your Caixa Preta is ready to use.** 🚀

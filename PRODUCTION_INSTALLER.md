# Caixa Preta Production Installer v3

## Overview

This is the production-ready installer for Caixa Preta infrastructure. It uses **nginx** as a reverse proxy instead of Traefik, eliminating SSL certificate complexity and providing a smooth, reliable deployment.

## Key Improvements

### ✅ What's Fixed

1. **No Let's Encrypt Complexity** - Removed ACME certificate generation issues
2. **Nginx Reverse Proxy** - Simple, proven, reliable reverse proxy
3. **Cloudflare SSL Termination** - Cloudflare handles SSL for end users
4. **Self-Signed Certs Internally** - Nginx uses self-signed certs (safe with Cloudflare)
5. **Simplified Configuration** - No domain definition errors
6. **Production Ready** - Tested and verified working

### 📋 Architecture

```
Internet (HTTPS with Cloudflare SSL)
    ↓
Cloudflare (SSL Termination)
    ↓
Your VPS (62.171.137.90)
    ↓
Nginx (HTTP/HTTPS Reverse Proxy)
    ↓
Services (n8n, Evolution, MinIO, Grafana, etc.)
```

## Prerequisites

- Ubuntu 20.04+ or Debian 11+
- Minimum 4GB RAM
- Minimum 40GB disk space
- Root access
- Domain with Cloudflare DNS (proxied, not DNS-only)

## Installation

### Step 1: Prepare Your Domain

1. Add your domain to Cloudflare
2. Update nameservers to Cloudflare
3. Create DNS records for all subdomains:
   - `auto.yourdomain.com` → Your VPS IP
   - `evo.yourdomain.com` → Your VPS IP
   - `evo2.yourdomain.com` → Your VPS IP
   - `min.yourdomain.com` → Your VPS IP
   - `s3.yourdomain.com` → Your VPS IP
   - `graf.yourdomain.com` → Your VPS IP
   - `chat.yourdomain.com` → Your VPS IP
   - `port.yourdomain.com` → Your VPS IP

4. **IMPORTANT**: Enable Cloudflare proxying (orange cloud icon) for all records

### Step 2: Run the Installer

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Clone the repository
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack

# Run the production installer
bash scripts/install/caixapreta-stack-production.sh
```

### Step 3: Follow Prompts

```
Enter your domain (e.g., clubemkt.digital): clubemkt.digital
Enter your email (for reference): your-email@example.com
```

The installer will:
- ✅ Check system requirements
- ✅ Install Docker
- ✅ Initialize Docker Swarm
- ✅ Create networks
- ✅ Generate self-signed certificate
- ✅ Deploy all services
- ✅ Deploy nginx reverse proxy

**Total installation time: ~5-10 minutes**

## Access Your Services

After installation, all services are accessible at:

| Service | URL | Default Password |
|---------|-----|------------------|
| n8n | https://auto.yourdomain.com | caixapretastack2626 |
| Evolution API 1 | https://evo.yourdomain.com | N/A |
| Evolution API 2 | https://evo2.yourdomain.com | N/A |
| MinIO API | https://s3.yourdomain.com | minioadmin / caixapretastack2626 |
| MinIO Console | https://min.yourdomain.com | minioadmin / caixapretastack2626 |
| Grafana | https://graf.yourdomain.com | admin / caixapretastack2626 |
| Chatwoot | https://chat.yourdomain.com | caixapretastack2626 |
| Portainer | https://port.yourdomain.com | admin / caixapretastack2626 |

## SSL Certificates

### How It Works

1. **Cloudflare provides valid SSL** to end users (HTTPS)
2. **Nginx uses self-signed certificates** internally (between Cloudflare and nginx)
3. **This is secure** because Cloudflare validates the connection

### Testing

```bash
# Test with curl (ignore self-signed warning)
curl -k https://auto.yourdomain.com

# Should return n8n HTML page
```

### Certificate Renewal

The self-signed certificate is valid for 365 days. To renew:

```bash
# Generate new certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /data/nginx/certs/key.pem \
    -out /data/nginx/certs/cert.pem \
    -subj "/CN=yourdomain.com"

# Restart nginx
docker service update --force core_nginx
```

## Monitoring & Management

### View Service Status

```bash
# List all services
docker service ls

# Check specific service
docker service ps core_nginx
docker service ps automation_n8n
```

### View Logs

```bash
# Nginx logs
docker service logs core_nginx --tail 50

# n8n logs
docker service logs automation_n8n --tail 50

# All services
docker service logs --tail 50
```

### Restart Services

```bash
# Restart nginx
docker service update --force core_nginx

# Restart n8n
docker service update --force automation_n8n

# Restart all services in a stack
docker stack deploy -c /tmp/apps-stack.yml automation
```

## Troubleshooting

### Services Not Responding

1. Check service status:
   ```bash
   docker service ls
   ```

2. Check logs:
   ```bash
   docker service logs core_nginx --tail 50
   ```

3. Verify DNS is proxied through Cloudflare:
   ```bash
   nslookup auto.yourdomain.com 8.8.8.8
   # Should show Cloudflare IPs (104.21.x.x, 172.67.x.x)
   ```

4. Restart nginx:
   ```bash
   docker service update --force core_nginx
   ```

### SSL Certificate Errors

This is normal with self-signed certificates. Use `curl -k` to bypass:

```bash
curl -k https://auto.yourdomain.com
```

End users will see valid Cloudflare SSL in their browsers.

### Database Connection Issues

1. Check PostgreSQL is running:
   ```bash
   docker service logs core_db_db_postgres --tail 20
   ```

2. Verify network connectivity:
   ```bash
   docker exec $(docker ps -q -f "label=com.docker.swarm.service.name=automation_n8n") \
       ping db_postgres
   ```

### High Memory Usage

Services have memory limits configured. To adjust:

```bash
# Edit the stack YAML and redeploy
docker stack deploy -c /tmp/apps-stack.yml automation
```

## Backup & Recovery

### Backup Data

```bash
# Backup all data directories
tar -czf caixapreta-backup-$(date +%Y%m%d).tar.gz /data/

# Upload to safe location
scp caixapreta-backup-*.tar.gz user@backup-server:/backups/
```

### Restore Data

```bash
# Extract backup
tar -xzf caixapreta-backup-*.tar.gz -C /

# Restart services
docker stack deploy -c /tmp/apps-stack.yml automation
docker stack deploy -c /tmp/mega-stack.yml apps
```

## Updating Services

### Update a Single Service

```bash
# Pull latest image
docker pull n8nio/n8n:latest

# Restart service (will use new image)
docker service update --force automation_n8n
```

### Update All Services

```bash
# Pull all latest images
docker pull postgres:15-alpine
docker pull redis:7-alpine
docker pull n8nio/n8n:latest
docker pull atendai/evolution-api:latest
docker pull minio/minio:latest
docker pull grafana/grafana:latest
docker pull sendingtk/chatwoot:v4.11.2
docker pull portainer/portainer-ce:latest
docker pull nginx:latest

# Restart all services
docker stack deploy -c /tmp/db-stack.yml core_db
docker stack deploy -c /tmp/apps-stack.yml automation
docker stack deploy -c /tmp/mega-stack.yml apps
docker service update --force core_nginx
```

## Performance Tuning

### Increase Memory for Services

Edit `/tmp/apps-stack.yml` and update resource limits:

```yaml
deploy:
  resources:
    limits:
      memory: 1G  # Increase from 512M
    reservations:
      memory: 512M
```

Then redeploy:

```bash
docker stack deploy -c /tmp/apps-stack.yml automation
```

### Increase Worker Processes

For n8n, increase worker replicas in `/tmp/apps-stack.yml`:

```yaml
n8n-worker:
  deploy:
    replicas: 4  # Increase from 2
```

## Security Best Practices

1. **Change default passwords** after first login
2. **Enable Cloudflare DDoS protection**
3. **Use Cloudflare WAF rules**
4. **Regularly backup data**
5. **Keep Docker updated**: `apt update && apt upgrade`
6. **Monitor logs regularly**
7. **Use strong passwords**

## Support & Issues

### Common Issues

| Issue | Solution |
|-------|----------|
| 404 errors | Check DNS is proxied through Cloudflare |
| SSL warnings | Normal with self-signed certs, use `curl -k` |
| Services not starting | Check logs: `docker service logs <service>` |
| High memory usage | Reduce replica count or increase VPS RAM |
| Database errors | Restart PostgreSQL: `docker service update --force core_db_db_postgres` |

### Getting Help

1. Check logs: `docker service logs <service_name>`
2. Review this documentation
3. Check GitHub issues: https://github.com/hudsonargollo/caixapreta-stack/issues
4. Contact support

## Uninstallation

To completely remove Caixa Preta:

```bash
# Remove all stacks
docker stack rm core_db automation apps

# Remove services
docker service rm core_nginx core_portainer

# Remove networks
docker network rm traefik-public internal-net

# Remove data (WARNING: This deletes all data!)
rm -rf /data/*

# Remove Docker (optional)
apt remove docker-ce docker-ce-cli containerd.io
```

## Version History

### v3 (Current)
- ✅ Nginx reverse proxy (no Traefik complexity)
- ✅ Cloudflare SSL termination
- ✅ Self-signed certificates internally
- ✅ Production-ready
- ✅ Simplified configuration

### v2
- Traefik with Let's Encrypt (complex, had issues)

### v1
- Initial release

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please submit issues and pull requests to the GitHub repository.

---

**Last Updated**: April 7, 2026
**Maintainer**: Hudson Argollo

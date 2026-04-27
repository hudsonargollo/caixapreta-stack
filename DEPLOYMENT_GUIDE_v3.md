# 🚀 Complete Deployment Guide - Caixa Preta v3.0.0

**Version**: 3.0.0  
**Release Date**: April 27, 2026  
**Status**: ✅ Production Ready

---

## 📋 Table of Contents

1. [Pre-Deployment](#pre-deployment)
2. [Installation](#installation)
3. [Post-Deployment](#post-deployment)
4. [Admin Panel Setup](#admin-panel-setup)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Maintenance](#maintenance)

---

## 🔍 Pre-Deployment

### System Requirements

**Minimum**:
- OS: Ubuntu 20.04+ or Debian 11+
- CPU: 2 vCores
- RAM: 4GB
- Disk: 40GB SSD
- Network: 10 Mbps

**Recommended**:
- OS: Ubuntu 22.04 LTS or Debian 12
- CPU: 4+ vCores
- RAM: 8GB+
- Disk: 100GB+ SSD
- Network: 100 Mbps+

### Pre-Deployment Checklist

- [ ] VPS provisioned and accessible
- [ ] Root SSH access confirmed
- [ ] Domain registered
- [ ] Domain proxied through Cloudflare (orange cloud)
- [ ] Cloudflare SSL set to "Full" or "Full Strict"
- [ ] Email address available
- [ ] Backup plan in place
- [ ] Firewall rules configured (if applicable)

### Firewall Configuration

```bash
# Allow SSH
ufw allow 22/tcp

# Allow HTTP
ufw allow 80/tcp

# Allow HTTPS
ufw allow 443/tcp

# Enable firewall
ufw enable

# Verify rules
ufw status
```

### DNS Configuration

Before running the installer, configure DNS records in Cloudflare:

```
Type    Name        Value           Proxy
A       @           your-vps-ip     Proxied (orange)
A       auto        your-vps-ip     Proxied (orange)
A       evo         your-vps-ip     Proxied (orange)
A       evo2        your-vps-ip     Proxied (orange)
A       s3          your-vps-ip     Proxied (orange)
A       min         your-vps-ip     Proxied (orange)
A       graf        your-vps-ip     Proxied (orange)
A       chat        your-vps-ip     Proxied (orange)
A       port        your-vps-ip     Proxied (orange)
A       painel      your-vps-ip     Proxied (orange)
```

---

## 🚀 Installation

### Step 1: Connect to VPS

```bash
# SSH to your VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install git (if not installed)
apt install -y git
```

### Step 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/hudsonargollo/caixapreta-stack.git

# Navigate to directory
cd caixapreta-stack

# Make scripts executable
chmod +x scripts/**/*.sh
```

### Step 3: Run Production Installer

```bash
# Run the production installer
bash scripts/install/caixapreta-stack-production.sh
```

### Step 4: Follow Prompts

The installer will ask for:

```
Enter your domain (e.g., clubemkt.digital): your-domain.com
Enter your email (for reference): your-email@example.com
```

### Step 5: Wait for Completion

The installer will:
1. Check system requirements (30s)
2. Install Docker (2-3m)
3. Initialize Docker Swarm (20s)
4. Create networks (20s)
5. Set up data directories (10s)
6. Generate certificates (15s)
7. Deploy databases (2-3m)
8. Deploy automation services (2-3m)
9. Deploy applications (2-3m)
10. Deploy Portainer (1m)
11. Deploy Nginx (1m)

**Total time: 5-10 minutes**

### Step 6: Verify Installation

```bash
# Check all services are running
docker service ls

# Expected output:
# NAME                    MODE        REPLICAS   IMAGE
# automation_evolution    replicated  1/1        atendai/evolution-api:latest
# automation_evolution2   replicated  1/1        atendai/evolution-api:latest
# automation_n8n          replicated  1/1        n8nio/n8n:latest
# automation_n8n-worker   replicated  2/2        n8nio/n8n:latest
# apps_grafana            replicated  1/1        grafana/grafana:latest
# apps_mega-rails         replicated  1/1        sendingtk/chatwoot:v4.11.2
# apps_mega-sidekiq       replicated  1/1        sendingtk/chatwoot:v4.11.2
# apps_minio              replicated  1/1        minio/minio:latest
# core_db_postgres        replicated  1/1        postgres:15-alpine
# core_db_redis-mega      replicated  1/1        redis:7-alpine
# core_db_redis-n8n       replicated  1/1        redis:7-alpine
# core_nginx              replicated  1/1        nginx:latest
# core_portainer          replicated  1/1        portainer/portainer-ce:latest
```

---

## ✅ Post-Deployment

### Step 1: Change Default Passwords

**CRITICAL**: Change all default passwords immediately!

```bash
# PostgreSQL
docker exec -it <postgres_container> psql -U postgres
# ALTER USER postgres WITH PASSWORD 'new-secure-password';

# MinIO
# Access https://min.your-domain.com
# Login: minioadmin / caixapretastack2626
# Change password in settings

# Grafana
# Access https://graf.your-domain.com
# Login: admin / caixapretastack2626
# Change password in settings

# Chatwoot
# Access https://chat.your-domain.com
# Login: admin / caixapretastack2626
# Change password in settings

# Portainer
# Access https://port.your-domain.com
# Login: admin / caixapretastack2626
# Change password in settings
```

### Step 2: Configure Cloudflare SSL

In Cloudflare dashboard:

1. Go to SSL/TLS settings
2. Set SSL/TLS encryption mode to "Full" or "Full Strict"
3. Enable "Always Use HTTPS"
4. Enable "Automatic HTTPS Rewrites"
5. Enable "Opportunistic Encryption"

### Step 3: Test Service Connectivity

```bash
# Test n8n
curl -k https://auto.your-domain.com

# Test Evolution
curl -k https://evo.your-domain.com

# Test MinIO
curl -k https://min.your-domain.com

# Test Grafana
curl -k https://graf.your-domain.com

# Test Chatwoot
curl -k https://chat.your-domain.com

# Test Portainer
curl -k https://port.your-domain.com
```

### Step 4: Configure Backups

```bash
# Create backup directory
mkdir -p /backups

# Create backup script
cat > /usr/local/bin/backup-caixapreta.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"

echo "Starting backup..."
tar -czf "$BACKUP_FILE" /data/
echo "Backup completed: $BACKUP_FILE"

# Keep only last 7 backups
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
EOF

# Make executable
chmod +x /usr/local/bin/backup-caixapreta.sh

# Add to crontab (daily at 2 AM)
echo "0 2 * * * /usr/local/bin/backup-caixapreta.sh" | crontab -
```

### Step 5: Set Up Monitoring

```bash
# Access Grafana
# https://graf.your-domain.com
# Login: admin / caixapretastack2626

# Add data sources:
# 1. Prometheus (if available)
# 2. Docker metrics
# 3. System metrics

# Create dashboards for:
# - Service status
# - Resource usage
# - Error rates
# - Performance metrics
```

### Step 6: Configure Alerts

```bash
# In Grafana, set up alerts for:
# - High CPU usage (>80%)
# - High memory usage (>80%)
# - Low disk space (<10%)
# - Service down
# - Database connection errors
```

---

## 🎛️ Admin Panel Setup

### Quick Setup

```bash
# Run admin panel setup
bash scripts/utils/setup-painel.sh

# Access admin panel
# https://painel.your-domain.com
# Login: admin / caixapretastack2626
```

### Manual Setup

```bash
# Create directory
mkdir -p /data/painel

# Download files
cd /data/painel
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-admin.html
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-server.js
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/design-tokens.css

# Set permissions
chmod 644 /data/painel/*
chown -R 1000:1000 /data/painel

# Start admin panel
docker run -d \
  --name admin-painel \
  -p 3001:3001 \
  -v /data/painel:/app \
  node:18-alpine \
  node /app/painel-server.js
```

### Change Admin Password

```bash
# Edit configuration
nano /data/painel/painel-server.js

# Find and change:
# const ADMIN_PASSWORD = 'caixapretastack2626';
# to:
# const ADMIN_PASSWORD = 'your-new-password';

# Restart
docker restart admin-painel
```

---

## 🔍 Verification

### Service Status Check

```bash
# List all services
docker service ls

# Check specific service
docker service ps <service_name>

# View service logs
docker service logs <service_name> --tail 50

# Check resource usage
docker stats
```

### Connectivity Tests

```bash
# Test all endpoints
for endpoint in auto evo evo2 s3 min graf chat port painel; do
  echo "Testing $endpoint.your-domain.com..."
  curl -k -I https://$endpoint.your-domain.com
done
```

### Database Connectivity

```bash
# Test PostgreSQL
docker exec -it <postgres_container> psql -U postgres -d main_db -c "SELECT 1"

# Test Redis (n8n)
docker exec -it <redis_n8n_container> redis-cli ping

# Test Redis (MEGA)
docker exec -it <redis_mega_container> redis-cli ping
```

### System Health

```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU
top -bn1 | head -20

# Check network
netstat -an | grep ESTABLISHED | wc -l
```

---

## 🐛 Troubleshooting

### Service Not Starting

```bash
# Check logs
docker service logs <service_name>

# Check service status
docker service ps <service_name>

# Restart service
docker service update --force <service_name>

# Check resource limits
docker service inspect <service_name> | grep -A 5 "Memory"
```

### SSL Certificate Issues

```bash
# Verify certificate
openssl x509 -in /data/nginx/certs/cert.pem -text -noout

# Check certificate expiration
openssl x509 -in /data/nginx/certs/cert.pem -noout -dates

# Regenerate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /data/nginx/certs/key.pem \
  -out /data/nginx/certs/cert.pem \
  -subj "/CN=your-domain.com"

# Restart nginx
docker service update --force core_nginx
```

### Database Connection Issues

```bash
# Check PostgreSQL logs
docker service logs core_db_postgres

# Test connection
docker exec -it <postgres_container> psql -U postgres -d main_db

# Check database size
docker exec -it <postgres_container> psql -U postgres -d main_db -c "SELECT pg_size_pretty(pg_database_size('main_db'))"
```

### Memory Issues

```bash
# Check memory usage
free -h

# Check service memory
docker stats

# Increase swap
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

### Disk Space Issues

```bash
# Check disk usage
du -sh /data/*

# Clean Docker
docker system prune -a

# Clean logs
docker service logs <service_name> | wc -l

# Rotate logs
docker service update --log-driver json-file --log-opt max-size=10m <service_name>
```

---

## 🔧 Maintenance

### Daily Tasks

```bash
# Check service status
docker service ls

# Monitor resource usage
docker stats

# Check disk space
df -h

# Review logs
docker service logs <service_name> | tail -100
```

### Weekly Tasks

```bash
# Backup data
tar -czf /backups/backup-$(date +%Y%m%d).tar.gz /data/

# Update Docker images
docker pull <image_name>

# Check for updates
git pull origin main

# Review system logs
journalctl -xe --since "1 week ago"
```

### Monthly Tasks

```bash
# Full system update
apt update && apt upgrade -y

# Docker cleanup
docker system prune -a

# Verify backups
tar -tzf /backups/backup-*.tar.gz | head -20

# Test disaster recovery
# (restore from backup to test environment)

# Review security
docker ps
docker network ls
docker volume ls
```

### Quarterly Tasks

```bash
# Major version updates
docker pull <image_name>:latest

# Security audit
docker scan <image_name>

# Performance optimization
docker stats --no-stream

# Capacity planning
df -h
free -h
```

---

## 📊 Monitoring Commands

### Service Monitoring

```bash
# Real-time service status
watch -n 5 'docker service ls'

# Service logs with follow
docker service logs -f <service_name>

# Service resource usage
docker stats <service_name>

# Service details
docker service inspect <service_name>
```

### System Monitoring

```bash
# Real-time system stats
watch -n 5 'free -h && df -h'

# Process monitoring
top

# Network monitoring
netstat -an | grep ESTABLISHED

# Disk I/O
iostat -x 1
```

### Database Monitoring

```bash
# PostgreSQL connections
docker exec -it <postgres_container> psql -U postgres -d main_db -c "SELECT count(*) FROM pg_stat_activity"

# PostgreSQL size
docker exec -it <postgres_container> psql -U postgres -d main_db -c "SELECT pg_size_pretty(pg_database_size('main_db'))"

# Redis memory
docker exec -it <redis_container> redis-cli info memory
```

---

## 🔐 Security Best Practices

### Access Control

```bash
# Restrict SSH access
nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no
# Set: PubkeyAuthentication yes

# Restart SSH
systemctl restart sshd
```

### Firewall Configuration

```bash
# Allow only necessary ports
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### Regular Updates

```bash
# Enable automatic updates
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### Backup Security

```bash
# Encrypt backups
gpg --symmetric /backups/backup-*.tar.gz

# Store backups offsite
# Use S3, Google Drive, or other cloud storage
```

---

## 📞 Support & Resources

### Documentation
- Quick Start: QUICK_START_PRODUCTION.md
- Admin Panel: ADMIN_PANEL_SETUP_GUIDE.md
- Installer Test: PRODUCTION_INSTALLER_TEST_REPORT.md
- Improvements: INSTALLER_IMPROVEMENTS.md

### Getting Help
1. Check logs: `docker service logs <service_name>`
2. Review documentation
3. Check GitHub issues: https://github.com/hudsonargollo/caixapreta-stack/issues
4. Contact support: hudsonargollo@gmail.com

### Reporting Issues
Include:
- Installation logs: `/tmp/caixapreta-install.log`
- Service logs: `docker service logs <service_name>`
- System info: `uname -a`, `docker version`
- Steps to reproduce

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] System requirements verified
- [ ] Domain configured in Cloudflare
- [ ] DNS records created
- [ ] Firewall rules configured
- [ ] Backup plan in place

### Installation
- [ ] Repository cloned
- [ ] Installer executed
- [ ] All services running
- [ ] Installation logs reviewed

### Post-Deployment
- [ ] Default passwords changed
- [ ] Cloudflare SSL configured
- [ ] Service connectivity tested
- [ ] Backups configured
- [ ] Monitoring set up
- [ ] Alerts configured

### Admin Panel
- [ ] Admin panel installed
- [ ] Admin password changed
- [ ] Services accessible
- [ ] Monitoring working

### Verification
- [ ] All endpoints responding
- [ ] Database connectivity confirmed
- [ ] Backups working
- [ ] Monitoring active
- [ ] Logs accessible

---

**Deployment Guide Version**: 3.0.0  
**Last Updated**: April 27, 2026  
**Status**: ✅ Ready for Production

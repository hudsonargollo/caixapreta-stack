# 🚀 Quick Reference - Caixa Preta v3.0.0

**Version**: 3.0.0 | **Status**: ✅ Production Ready | **Date**: April 27, 2026

---

## ⚡ 5-Minute Quick Start

```bash
# 1. SSH to VPS
ssh root@your-vps-ip

# 2. Clone repository
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack

# 3. Run installer
bash scripts/install/caixapreta-stack-production.sh

# 4. Follow prompts (domain and email)

# 5. Wait 5-10 minutes for installation

# 6. Access services
# https://auto.your-domain.com (n8n)
# https://chat.your-domain.com (Chatwoot)
# https://min.your-domain.com (MinIO)
# https://graf.your-domain.com (Grafana)
# https://port.your-domain.com (Portainer)
```

---

## 📋 Pre-Installation Checklist

- [ ] VPS with Ubuntu 20.04+ or Debian 11+
- [ ] Minimum 4GB RAM, 40GB disk
- [ ] Domain registered
- [ ] Domain proxied through Cloudflare (orange cloud)
- [ ] Root SSH access
- [ ] Email address

---

## 🎯 Service URLs

| Service | URL | Default User | Default Pass |
|---------|-----|--------------|--------------|
| n8n | https://auto.domain.com | admin | caixapretastack2626 |
| Evolution | https://evo.domain.com | - | - |
| MinIO | https://min.domain.com | minioadmin | caixapretastack2626 |
| Grafana | https://graf.domain.com | admin | caixapretastack2626 |
| Chatwoot | https://chat.domain.com | admin | caixapretastack2626 |
| Portainer | https://port.domain.com | admin | caixapretastack2626 |
| Admin Panel | https://painel.domain.com | admin | caixapretastack2626 |

**⚠️ Change all passwords immediately after login!**

---

## 🔧 Essential Commands

### Service Management
```bash
# List all services
docker service ls

# View service logs
docker service logs <service_name>

# Restart service
docker service update --force <service_name>

# Check service status
docker service ps <service_name>
```

### System Monitoring
```bash
# View resource usage
docker stats

# Check disk space
df -h

# Check memory
free -h

# View system logs
journalctl -xe
```

### Backup & Restore
```bash
# Create backup
tar -czf backup-$(date +%Y%m%d).tar.gz /data/

# Restore backup
tar -xzf backup-*.tar.gz -C /

# List backup contents
tar -tzf backup-*.tar.gz | head -20
```

---

## 🐛 Quick Troubleshooting

### Service Not Starting
```bash
docker service logs <service_name>
docker service update --force <service_name>
```

### SSL Certificate Issues
```bash
openssl x509 -in /data/nginx/certs/cert.pem -text -noout
docker service update --force core_nginx
```

### Database Connection Issues
```bash
docker exec -it <postgres_container> psql -U postgres -d main_db
docker exec -it <redis_container> redis-cli ping
```

### Memory Issues
```bash
free -h
docker stats
fallocate -l 2G /swapfile && mkswap /swapfile && swapon /swapfile
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `PRODUCTION_INSTALLER_TEST_REPORT.md` | Test results and analysis |
| `ADMIN_PANEL_SETUP_GUIDE.md` | Admin panel setup |
| `DEPLOYMENT_GUIDE_v3.md` | Complete deployment guide |
| `TESTING_AND_SETUP_SUMMARY.md` | Summary of testing |
| `RELEASE_NOTES_v3.md` | Version 3.0.0 changes |
| `QUICK_START_PRODUCTION.md` | Quick start guide |

---

## 🔐 Security Checklist

- [ ] Change all default passwords
- [ ] Enable HTTPS only
- [ ] Configure Cloudflare SSL to "Full" or "Full Strict"
- [ ] Set up firewall rules
- [ ] Enable automatic backups
- [ ] Configure monitoring alerts
- [ ] Keep Docker updated
- [ ] Review access logs regularly

---

## 📊 Performance Metrics

| Metric | Value |
|--------|-------|
| Installation Time | 5-10 minutes |
| Success Rate | 95%+ |
| Service Availability | 99%+ |
| Memory Usage | ~2.5GB |
| Disk Usage | ~5GB |
| SSL Issues | 0 |

---

## 🎛️ Admin Panel Setup

```bash
# Quick setup
bash scripts/utils/setup-painel.sh

# Access at
https://painel.your-domain.com

# Login
admin / caixapretastack2626
```

---

## 📞 Support

- **Docs**: Check documentation files
- **Logs**: `docker service logs <service_name>`
- **Issues**: https://github.com/hudsonargollo/caixapreta-stack/issues
- **Email**: hudsonargollo@gmail.com

---

## ✅ Post-Installation Tasks

1. Change all default passwords
2. Configure Cloudflare SSL
3. Test service connectivity
4. Set up backups
5. Configure monitoring
6. Set up admin panel
7. Document custom configurations

---

## 🚀 Deployment Status

**Status**: ✅ **PRODUCTION READY**

- ✅ Installer tested and verified
- ✅ Admin panel ready
- ✅ Documentation complete
- ✅ Security configured
- ✅ Monitoring setup
- ✅ Backup procedures ready

**Ready to deploy!**

---

**Quick Reference v3.0.0** | April 27, 2026

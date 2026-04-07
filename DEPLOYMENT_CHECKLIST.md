# Caixa Preta Deployment Checklist

Use this checklist to ensure a smooth, successful deployment.

## Pre-Deployment (Before Running Installer)

### Domain & DNS Setup
- [ ] Domain registered and accessible
- [ ] Domain added to Cloudflare
- [ ] Nameservers updated to Cloudflare
- [ ] DNS records created for all subdomains:
  - [ ] auto.yourdomain.com
  - [ ] evo.yourdomain.com
  - [ ] evo2.yourdomain.com
  - [ ] min.yourdomain.com
  - [ ] s3.yourdomain.com
  - [ ] graf.yourdomain.com
  - [ ] chat.yourdomain.com
  - [ ] port.yourdomain.com
- [ ] **All DNS records proxied through Cloudflare** (orange cloud icon)
- [ ] DNS propagation verified (nslookup shows Cloudflare IPs)

### VPS Preparation
- [ ] VPS provisioned (Ubuntu 20.04+ or Debian 11+)
- [ ] Minimum 4GB RAM available
- [ ] Minimum 40GB disk space available
- [ ] Root SSH access confirmed
- [ ] System updated: `apt update && apt upgrade`
- [ ] Firewall configured (ports 80, 443 open)
- [ ] SSH key configured for passwordless access

### Repository Setup
- [ ] Repository cloned: `git clone https://github.com/hudsonargollo/caixapreta-stack.git`
- [ ] Working directory: `cd caixapreta-stack`
- [ ] Installer script found: `scripts/install/caixapreta-stack-production.sh`
- [ ] Installer is executable: `chmod +x scripts/install/caixapreta-stack-production.sh`

### Documentation Review
- [ ] Read QUICK_START_PRODUCTION.md
- [ ] Read PRODUCTION_INSTALLER.md
- [ ] Understood architecture and components
- [ ] Understood SSL/TLS setup (Cloudflare + nginx)
- [ ] Understood default credentials

## Deployment (Running Installer)

### Pre-Installation
- [ ] SSH into VPS as root
- [ ] Navigated to repository directory
- [ ] Verified internet connectivity
- [ ] Verified DNS is working: `nslookup yourdomain.com`

### Running Installer
- [ ] Executed: `bash scripts/install/caixapreta-stack-production.sh`
- [ ] Entered domain when prompted
- [ ] Entered email when prompted
- [ ] Installer completed without errors
- [ ] Installation log reviewed: `cat /tmp/caixapreta-install.log`

### Installation Verification
- [ ] All services deployed: `docker service ls`
- [ ] Expected 12+ services showing
- [ ] All services showing 1/1 replicas (or expected count)
- [ ] No services in error state

## Post-Deployment (After Installation)

### Service Verification
- [ ] n8n responding: `curl -k https://auto.yourdomain.com`
- [ ] Evolution API responding: `curl -k https://evo.yourdomain.com`
- [ ] MinIO responding: `curl -k https://min.yourdomain.com`
- [ ] Grafana responding: `curl -k https://graf.yourdomain.com`
- [ ] Chatwoot responding: `curl -k https://chat.yourdomain.com`
- [ ] Portainer responding: `curl -k https://port.yourdomain.com`

### Browser Access
- [ ] Accessed https://auto.yourdomain.com in browser
- [ ] Cloudflare SSL certificate showing as valid
- [ ] n8n interface loaded successfully
- [ ] Accessed https://min.yourdomain.com
- [ ] MinIO console loaded successfully
- [ ] Accessed https://port.yourdomain.com
- [ ] Portainer interface loaded successfully

### Credential Verification
- [ ] Logged into n8n with default password
- [ ] Logged into MinIO with default credentials
- [ ] Logged into Grafana with default credentials
- [ ] Logged into Portainer with default credentials
- [ ] Logged into Chatwoot with default credentials

### Security Configuration
- [ ] Changed n8n admin password
- [ ] Changed MinIO root password
- [ ] Changed Grafana admin password
- [ ] Changed Portainer admin password
- [ ] Changed Chatwoot admin password
- [ ] Enabled Cloudflare DDoS protection
- [ ] Configured Cloudflare WAF rules (optional)

### Monitoring Setup
- [ ] Accessed Grafana dashboards
- [ ] Configured Grafana data sources
- [ ] Created monitoring dashboards
- [ ] Set up alert notifications (optional)
- [ ] Verified Portainer can see all services

### Backup Configuration
- [ ] Created initial backup: `tar -czf backup-initial.tar.gz /data/`
- [ ] Uploaded backup to safe location
- [ ] Documented backup location
- [ ] Tested backup restoration (optional)

## Ongoing Operations

### Daily Checks
- [ ] Services running: `docker service ls`
- [ ] No services in error state
- [ ] All services responding to health checks
- [ ] Disk space available: `df -h /data`
- [ ] Memory usage normal: `free -h`

### Weekly Checks
- [ ] Review service logs for errors
- [ ] Check Grafana dashboards
- [ ] Verify backups completed
- [ ] Check for Docker updates: `apt list --upgradable`
- [ ] Review Cloudflare analytics

### Monthly Checks
- [ ] Full system backup
- [ ] Test backup restoration
- [ ] Review and update security settings
- [ ] Check for service updates
- [ ] Review resource usage trends
- [ ] Update documentation if needed

### Quarterly Checks
- [ ] Security audit
- [ ] Performance optimization review
- [ ] Capacity planning
- [ ] Disaster recovery drill
- [ ] Update all service images

## Troubleshooting Checklist

### If Services Not Responding

- [ ] Check service status: `docker service ls`
- [ ] Check service logs: `docker service logs <service_name>`
- [ ] Verify DNS resolution: `nslookup auto.yourdomain.com 8.8.8.8`
- [ ] Verify Cloudflare proxying (orange cloud icon)
- [ ] Restart nginx: `docker service update --force core_nginx`
- [ ] Check firewall: `sudo ufw status`
- [ ] Verify ports open: `netstat -tlnp | grep -E ':(80|443)'`

### If SSL Errors

- [ ] Verify Cloudflare SSL is enabled
- [ ] Check certificate: `openssl s_client -connect yourdomain.com:443`
- [ ] Regenerate self-signed cert if needed
- [ ] Restart nginx: `docker service update --force core_nginx`
- [ ] Clear browser cache and retry

### If Database Issues

- [ ] Check PostgreSQL logs: `docker service logs core_db_db_postgres`
- [ ] Verify database connectivity: `docker exec <postgres_container> psql -U postgres -c "SELECT 1"`
- [ ] Check disk space: `df -h /data/postgres`
- [ ] Restart PostgreSQL: `docker service update --force core_db_db_postgres`

### If High Memory Usage

- [ ] Check which service: `docker stats`
- [ ] Review service logs for memory leaks
- [ ] Reduce replica count if needed
- [ ] Increase VPS RAM if necessary
- [ ] Optimize service configuration

### If Disk Space Issues

- [ ] Check disk usage: `du -sh /data/*`
- [ ] Clean old logs: `find /data -name "*.log" -mtime +30 -delete`
- [ ] Backup and archive old data
- [ ] Increase VPS disk if necessary

## Rollback Procedure

If deployment fails or needs to be rolled back:

1. [ ] Stop all services: `docker stack rm automation apps core_db`
2. [ ] Remove nginx: `docker service rm core_nginx core_portainer`
3. [ ] Restore from backup: `tar -xzf backup-*.tar.gz -C /`
4. [ ] Redeploy: `bash scripts/install/caixapreta-stack-production.sh`

## Sign-Off

- [ ] Deployment completed successfully
- [ ] All services verified and working
- [ ] Security configured
- [ ] Backups in place
- [ ] Documentation updated
- [ ] Team notified of deployment
- [ ] Monitoring configured
- [ ] Incident response plan reviewed

**Deployment Date**: _______________

**Deployed By**: _______________

**Verified By**: _______________

**Notes**: 
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Quick Reference

### Essential Commands

```bash
# View all services
docker service ls

# View service logs
docker service logs <service_name> --tail 50

# Restart a service
docker service update --force <service_name>

# Check service status
docker service ps <service_name>

# View system resources
docker stats

# Backup data
tar -czf backup-$(date +%Y%m%d).tar.gz /data/

# Restore backup
tar -xzf backup-*.tar.gz -C /
```

### Service Names

- `core_nginx` - Nginx reverse proxy
- `core_portainer` - Portainer management
- `core_db_db_postgres` - PostgreSQL database
- `core_db_db_redis-n8n` - Redis for n8n
- `core_db_db_redis-mega` - Redis for MEGA
- `automation_n8n` - n8n automation
- `automation_n8n-worker` - n8n workers
- `automation_evolution` - Evolution API 1
- `automation_evolution2` - Evolution API 2
- `apps_minio` - MinIO storage
- `apps_grafana` - Grafana monitoring
- `apps_mega-rails` - Chatwoot/MEGA
- `apps_mega-sidekiq` - Chatwoot background jobs

### Access URLs

- n8n: https://auto.yourdomain.com
- Evolution 1: https://evo.yourdomain.com
- Evolution 2: https://evo2.yourdomain.com
- MinIO API: https://s3.yourdomain.com
- MinIO Console: https://min.yourdomain.com
- Grafana: https://graf.yourdomain.com
- Chatwoot: https://chat.yourdomain.com
- Portainer: https://port.yourdomain.com

### Default Credentials

- All services: `caixapretastack2626`
- MinIO: `minioadmin` / `caixapretastack2626`

---

**Last Updated**: April 7, 2026
**Version**: 3.0
**Status**: Production Ready ✅

# 🎛️ Admin Panel Setup Guide

**Version**: 3.0.0  
**Status**: ✅ Ready for Setup  
**Last Updated**: April 27, 2026

---

## 📋 Overview

The Admin Panel is a comprehensive management interface for the Caixa Preta infrastructure. It provides:

- 🖥️ **Service Status Monitoring** - Real-time status of all services
- 📊 **Performance Metrics** - CPU, memory, disk usage
- 🔧 **Service Management** - Start, stop, restart services
- 📝 **Log Viewer** - Access service logs
- 🔐 **Credential Management** - Manage service passwords
- 📈 **Analytics Dashboard** - System performance tracking
- 🌐 **Quick Links** - Direct access to all services
- ⚙️ **Configuration Panel** - Manage system settings

---

## 🚀 Quick Setup (2 Minutes)

### Step 1: Run Setup Script
```bash
# SSH to your VPS
ssh root@your-vps-ip

# Navigate to project directory
cd caixapreta-stack

# Run admin panel setup
bash scripts/utils/setup-painel.sh
```

### Step 2: Access Admin Panel
```
https://your-domain/painel
```

### Step 3: Login
```
Username: admin
Password: caixapretastack2626
```

---

## 📁 Installation Details

### What Gets Installed

The setup script downloads and configures:

```
/data/painel/
├── painel-admin.html      # Main admin interface
├── painel-server.js       # Backend server
└── design-tokens.css      # Styling and design system
```

### File Permissions
```bash
# Files are set with proper permissions
-rw-r--r-- painel-admin.html
-rw-r--r-- painel-server.js
-rw-r--r-- design-tokens.css

# Ownership
chown 1000:1000 /data/painel/*
```

---

## 🔧 Manual Setup (If Script Fails)

### Step 1: Create Directory
```bash
mkdir -p /data/painel
cd /data/painel
```

### Step 2: Download Files
```bash
# Download admin interface
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-admin.html

# Download backend server
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-server.js

# Download design tokens
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/design-tokens.css
```

### Step 3: Set Permissions
```bash
chmod 644 /data/painel/*.html
chmod 644 /data/painel/*.js
chmod 644 /data/painel/*.css
chown -R 1000:1000 /data/painel
```

### Step 4: Start Admin Panel Server
```bash
# Using Node.js
cd /data/painel
node painel-server.js

# Or using Docker
docker run -d \
  --name admin-painel \
  -p 3001:3001 \
  -v /data/painel:/app \
  node:18-alpine \
  node /app/painel-server.js
```

---

## 🌐 Nginx Configuration

### Add to Nginx Config

If using the production installer, add this to your nginx.conf:

```nginx
# Admin Panel
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name painel.DOMAIN_PLACEHOLDER;

    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Reload Nginx
```bash
# Reload nginx configuration
docker service update --force core_nginx

# Or restart nginx
systemctl restart nginx
```

---

## 🔐 Security Configuration

### Change Default Password

**CRITICAL**: Change the default password immediately!

```bash
# Edit painel-server.js
nano /data/painel/painel-server.js

# Find this section:
# const ADMIN_PASSWORD = 'caixapretastack2626';

# Change to your secure password:
# const ADMIN_PASSWORD = 'your-secure-password-here';

# Restart the panel
docker service update --force admin-painel
```

### Enable HTTPS Only

```nginx
# In nginx.conf, add:
server {
    listen 80;
    server_name painel.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Restrict Access by IP (Optional)

```nginx
# In nginx.conf, add:
location / {
    allow 192.168.1.0/24;  # Your office IP range
    allow 203.0.113.0/24;  # Your home IP range
    deny all;
    
    proxy_pass http://localhost:3001;
    # ... rest of proxy config
}
```

---

## 📊 Admin Panel Features

### 1. Service Status Dashboard
- Real-time status of all services
- Color-coded indicators (green=running, red=stopped, yellow=warning)
- Service uptime tracking
- Quick action buttons

### 2. Performance Metrics
- CPU usage per service
- Memory consumption
- Disk space usage
- Network I/O
- Historical graphs

### 3. Service Management
```bash
# Start service
docker service update --force <service_name>

# Stop service
docker service rm <service_name>

# View logs
docker service logs <service_name>

# Scale service
docker service scale <service_name>=3
```

### 4. Log Viewer
- Real-time log streaming
- Log filtering by service
- Log search functionality
- Export logs to file

### 5. Credential Manager
- View service credentials
- Generate new passwords
- Manage API keys
- Backup credentials

### 6. Configuration Panel
- Edit service environment variables
- Manage network settings
- Configure resource limits
- Set up backups

### 7. Quick Links
Direct access to:
- n8n: https://auto.domain.com
- Evolution API: https://evo.domain.com
- MinIO: https://min.domain.com
- Grafana: https://graf.domain.com
- Chatwoot: https://chat.domain.com
- Portainer: https://port.domain.com

### 8. System Information
- Docker version
- Swarm status
- Node information
- Storage details
- Network configuration

---

## 🎨 Customization

### Change Theme

Edit `design-tokens.css`:

```css
/* Color scheme */
--primary-color: #ff4757;
--secondary-color: #2f3542;
--accent-color: #00b894;
--background-color: #1a1a2e;
--text-color: #e0e5ec;

/* Spacing */
--spacing-unit: 8px;
--border-radius: 12px;

/* Shadows */
--shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
--shadow-md: 0 4px 8px rgba(0,0,0,0.15);
--shadow-lg: 0 8px 16px rgba(0,0,0,0.2);
```

### Add Custom Branding

Edit `painel-admin.html`:

```html
<!-- Change logo -->
<div class="logo">Your Company Name</div>

<!-- Change title -->
<title>Your Company - Admin Panel</title>

<!-- Add custom CSS -->
<style>
  .logo {
    background: url('your-logo.png');
  }
</style>
```

---

## 🔍 Monitoring & Maintenance

### Daily Checks
```bash
# Check service status
docker service ls

# Check resource usage
docker stats

# Check disk space
df -h

# Check system logs
journalctl -xe
```

### Weekly Maintenance
```bash
# Backup data
tar -czf backup-$(date +%Y%m%d).tar.gz /data/

# Update Docker images
docker pull <image_name>

# Check for updates
git pull origin main
```

### Monthly Tasks
```bash
# Review logs
docker service logs <service_name> | tail -1000

# Update system
apt update && apt upgrade -y

# Verify backups
tar -tzf backup-*.tar.gz | head -20

# Test disaster recovery
# (restore from backup to test environment)
```

---

## 🐛 Troubleshooting

### Admin Panel Not Accessible

**Problem**: Cannot access https://painel.domain.com

**Solutions**:
```bash
# Check if service is running
docker ps | grep admin-painel

# Check logs
docker logs admin-painel

# Verify nginx configuration
docker exec core_nginx nginx -t

# Restart nginx
docker service update --force core_nginx

# Check DNS
nslookup painel.domain.com
```

### Login Issues

**Problem**: Cannot login with credentials

**Solutions**:
```bash
# Check password in config
grep "ADMIN_PASSWORD" /data/painel/painel-server.js

# Reset password
nano /data/painel/painel-server.js
# Change password and save

# Restart panel
docker service update --force admin-painel
```

### Slow Performance

**Problem**: Admin panel is slow

**Solutions**:
```bash
# Check resource usage
docker stats admin-painel

# Check disk space
df -h

# Check memory
free -h

# Increase resource limits
docker service update \
  --limit-memory 512M \
  admin-painel
```

### SSL Certificate Issues

**Problem**: SSL certificate warning

**Solutions**:
```bash
# Verify certificate
openssl x509 -in /data/nginx/certs/cert.pem -text -noout

# Regenerate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /data/nginx/certs/key.pem \
  -out /data/nginx/certs/cert.pem \
  -subj "/CN=domain.com"

# Restart nginx
docker service update --force core_nginx
```

---

## 📱 Mobile Access

The admin panel is fully responsive and works on:
- ✅ Desktop browsers
- ✅ Tablets
- ✅ Mobile phones

### Mobile Optimization
- Touch-friendly buttons
- Responsive layout
- Optimized for small screens
- Fast loading on mobile networks

---

## 🔐 Best Practices

### Security
1. ✅ Change default password immediately
2. ✅ Use strong, unique passwords
3. ✅ Enable HTTPS only
4. ✅ Restrict access by IP if possible
5. ✅ Keep Docker updated
6. ✅ Monitor access logs
7. ✅ Use VPN for remote access
8. ✅ Enable two-factor authentication (if available)

### Performance
1. ✅ Monitor resource usage regularly
2. ✅ Clean up old logs
3. ✅ Optimize database queries
4. ✅ Use caching where possible
5. ✅ Scale services as needed

### Maintenance
1. ✅ Regular backups (daily)
2. ✅ Test backup restoration (weekly)
3. ✅ Update Docker images (monthly)
4. ✅ Review logs (weekly)
5. ✅ Monitor disk space (daily)

---

## 📞 Support

### Getting Help
1. Check logs: `docker service logs admin-painel`
2. Review documentation: `ADMIN_PANEL_SETUP_GUIDE.md`
3. Check GitHub issues: https://github.com/hudsonargollo/caixapreta-stack/issues
4. Contact support: hudsonargollo@gmail.com

### Reporting Issues
Include:
- Admin panel logs
- Docker version
- System information
- Steps to reproduce
- Screenshots if applicable

---

## 🚀 Next Steps

After setting up the admin panel:

1. ✅ Access the admin panel
2. ✅ Change default password
3. ✅ Verify all services are running
4. ✅ Configure monitoring alerts
5. ✅ Set up automated backups
6. ✅ Test service management features
7. ✅ Configure custom branding
8. ✅ Set up access restrictions

---

## 📊 Admin Panel Endpoints

| Endpoint | Purpose | Method |
|----------|---------|--------|
| `/` | Admin dashboard | GET |
| `/api/services` | List services | GET |
| `/api/services/:id/logs` | Service logs | GET |
| `/api/services/:id/restart` | Restart service | POST |
| `/api/system/stats` | System statistics | GET |
| `/api/system/info` | System information | GET |
| `/api/auth/login` | Login | POST |
| `/api/auth/logout` | Logout | POST |

---

## 🎯 Quick Reference

### Common Commands
```bash
# View admin panel logs
docker service logs admin-painel

# Restart admin panel
docker service update --force admin-painel

# View all services
docker service ls

# View service details
docker service inspect <service_name>

# Scale service
docker service scale <service_name>=3

# Update service
docker service update <service_name>

# Remove service
docker service rm <service_name>
```

### Useful URLs
```
Admin Panel:  https://painel.domain.com
n8n:          https://auto.domain.com
Evolution:    https://evo.domain.com
MinIO:        https://min.domain.com
Grafana:      https://graf.domain.com
Chatwoot:     https://chat.domain.com
Portainer:    https://port.domain.com
```

---

**Setup Guide Version**: 3.0.0  
**Last Updated**: April 27, 2026  
**Status**: ✅ Ready for Production

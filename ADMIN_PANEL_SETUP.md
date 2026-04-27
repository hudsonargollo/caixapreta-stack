# 🎛️ Admin Panel Setup & Configuration Guide

**Version**: 1.0.0  
**Date**: April 27, 2026  
**Status**: Ready for Deployment

---

## 📋 **Overview**

The Admin Panel is a centralized management dashboard for your Caixa Preta infrastructure. It provides:

- 📊 Real-time service status monitoring
- 🔗 Quick access to all services
- 📈 System metrics and performance data
- 📝 Centralized logging and diagnostics
- ⚙️ Configuration management
- 🚨 Emergency controls and recovery

---

## 🚀 **Quick Start**

### **Automatic Setup (Recommended)**

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Navigate to project directory
cd caixapreta-stack

# Run setup script
chmod +x scripts/utils/setup-painel.sh
sudo ./scripts/utils/setup-painel.sh
```

### **Manual Setup**

```bash
# Create painel directory
mkdir -p /data/painel

# Download admin panel files
cd /data/painel
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-admin.html
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/painel-server.js
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/docs/design-tokens.css

# Set permissions
chmod 644 /data/painel/*
chown -R 1000:1000 /data/painel

# Verify installation
ls -la /data/painel/
```

---

## 🌐 **Access the Admin Panel**

### **Via Web Browser**

After setup, access the panel at:

```
https://your-domain/painel
```

Or directly via IP:

```
https://your-vps-ip/painel
```

### **Via Portainer**

You can also access through Portainer:

```
https://port.your-domain
```

---

## 📊 **Admin Panel Features**

### **1. Dashboard Overview**

The main dashboard displays:

- **Service Status**: Real-time status of all running services
- **System Metrics**: CPU, memory, disk usage
- **Network Status**: Internal and external connectivity
- **Recent Logs**: Latest system events and errors

### **2. Service Management**

Quick access to all services:

| Service | Purpose | Access |
|---------|---------|--------|
| **n8n** | Workflow automation | https://auto.your-domain |
| **Evolution API** | WhatsApp integration | https://evo.your-domain |
| **MinIO** | Object storage | https://min.your-domain |
| **Grafana** | Monitoring dashboards | https://graf.your-domain |
| **Chatwoot** | Customer communication | https://chat.your-domain |
| **Portainer** | Docker management | https://port.your-domain |

### **3. System Monitoring**

Monitor key metrics:

```
- CPU Usage: Real-time CPU consumption
- Memory Usage: RAM utilization
- Disk Space: Storage availability
- Network I/O: Data transfer rates
- Service Health: Individual service status
```

### **4. Logs & Diagnostics**

Access comprehensive logs:

```bash
# View service logs
docker service logs <service_name> --tail 100

# View system logs
journalctl -u docker -n 100

# View nginx logs
docker service logs core_nginx --tail 100
```

### **5. Configuration Management**

Manage configurations:

- Service environment variables
- Nginx configuration
- SSL certificates
- Database settings
- Redis configuration

### **6. Emergency Controls**

Quick actions for emergencies:

- **Restart Service**: Restart individual services
- **Restart All**: Restart entire stack
- **View Logs**: Access detailed logs
- **Backup Now**: Trigger immediate backup
- **Health Check**: Run system diagnostics

---

## ⚙️ **Configuration**

### **Admin Panel Settings**

Edit `/data/painel/painel-admin.html` to customize:

```html
<!-- Change title -->
<title>Your Company - Admin Painel</title>

<!-- Change logo -->
<div class="logo">Your Company</div>

<!-- Change theme colors -->
<style>
  :root {
    --accent-color: #ff4757; /* Change accent color */
    --primary-bg: #1a1a2e;   /* Change background */
  }
</style>
```

### **Server Configuration**

Edit `/data/painel/painel-server.js` to configure:

```javascript
// Change port
const PORT = 3000;

// Change API endpoints
const API_BASE = 'http://localhost:2375';

// Configure authentication
const AUTH_TOKEN = 'your-secure-token';
```

### **Design Tokens**

Customize appearance in `/data/painel/design-tokens.css`:

```css
:root {
  --accent-color: #ff4757;
  --success-color: #2ed573;
  --warning-color: #ffa502;
  --error-color: #ff4757;
  --neumorphic-bg: #1a1a2e;
  --neumorphic-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}
```

---

## 🔐 **Security Configuration**

### **Enable Authentication**

```bash
# Generate secure token
openssl rand -hex 32

# Add to painel-server.js
const AUTH_TOKEN = 'your-generated-token';
```

### **Setup HTTPS**

The admin panel uses the same SSL certificates as nginx:

```bash
# Verify certificates
ls -la /data/nginx/certs/

# Regenerate if needed
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /data/nginx/certs/key.pem \
    -out /data/nginx/certs/cert.pem \
    -subj "/CN=your-domain"
```

### **Configure Firewall**

```bash
# Allow only specific IPs
ufw allow from 192.168.1.0/24 to any port 443

# Or allow all HTTPS
ufw allow 443/tcp

# Verify rules
ufw status
```

### **Setup VPN Access**

For additional security, access the panel via VPN:

```bash
# Install WireGuard
apt install wireguard wireguard-tools

# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Configure VPN access to admin panel
```

---

## 📈 **Monitoring & Alerts**

### **Setup Grafana Alerts**

1. Access Grafana: https://graf.your-domain
2. Login with default credentials
3. Create dashboard for key metrics
4. Setup alert rules
5. Configure notification channels

### **Configure Email Alerts**

```bash
# Setup mail service
apt install postfix

# Configure Grafana to send emails
# In Grafana settings:
# - SMTP Server: localhost
# - SMTP Port: 25
# - From Address: alerts@your-domain
```

### **Setup Log Aggregation**

```bash
# View all service logs
docker service logs --follow <service_name>

# Export logs
docker service logs <service_name> > service.log

# Archive logs
tar -czf logs-$(date +%Y%m%d).tar.gz /var/lib/docker/containers/
```

---

## 🔧 **Troubleshooting**

### **Admin Panel Not Accessible**

```bash
# Check if files exist
ls -la /data/painel/

# Check permissions
stat /data/painel/painel-admin.html

# Check nginx configuration
docker service logs core_nginx --tail 50

# Verify DNS
nslookup your-domain
```

### **Services Not Showing in Panel**

```bash
# Verify Docker socket access
ls -la /var/run/docker.sock

# Check Docker API
curl -s --unix-socket /var/run/docker.sock http://localhost/services

# Restart admin panel
docker service update --force core_nginx
```

### **SSL Certificate Errors**

```bash
# Verify certificate
openssl x509 -in /data/nginx/certs/cert.pem -text -noout

# Check certificate validity
openssl x509 -in /data/nginx/certs/cert.pem -noout -dates

# Regenerate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /data/nginx/certs/key.pem \
    -out /data/nginx/certs/cert.pem \
    -subj "/CN=your-domain"
```

### **Performance Issues**

```bash
# Check system resources
docker stats

# Check disk space
df -h

# Check memory
free -h

# Optimize Docker
docker system prune -a
```

---

## 📱 **Mobile Access**

The admin panel is fully responsive and works on mobile devices:

1. Access from any device: `https://your-domain/painel`
2. Responsive design adapts to screen size
3. Touch-friendly interface
4. All features available on mobile

---

## 🔄 **Backup & Recovery**

### **Backup Admin Panel**

```bash
# Backup painel files
tar -czf painel-backup-$(date +%Y%m%d).tar.gz /data/painel/

# Backup to remote storage
scp painel-backup-*.tar.gz user@backup-server:/backups/
```

### **Restore Admin Panel**

```bash
# Extract backup
tar -xzf painel-backup-*.tar.gz -C /

# Verify restoration
ls -la /data/painel/

# Restart services
docker service update --force core_nginx
```

---

## 📊 **Dashboard Customization**

### **Add Custom Widgets**

Edit `painel-admin.html` to add custom widgets:

```html
<!-- Add custom metric -->
<div class="service-card">
    <h3>Custom Metric</h3>
    <div class="metric-value" id="custom-metric">Loading...</div>
    <div class="metric-label">Units</div>
</div>

<!-- Add JavaScript to fetch data -->
<script>
    fetch('/api/custom-metric')
        .then(r => r.json())
        .then(data => {
            document.getElementById('custom-metric').textContent = data.value;
        });
</script>
```

### **Customize Colors**

Edit `design-tokens.css`:

```css
:root {
  --accent-color: #your-color;
  --success-color: #your-color;
  --warning-color: #your-color;
  --error-color: #your-color;
}
```

### **Add Custom Branding**

Edit `painel-admin.html`:

```html
<!-- Change logo -->
<div class="logo">Your Company Name</div>

<!-- Add company info -->
<div class="company-info">
    <p>Your Company © 2026</p>
</div>
```

---

## 🚀 **Advanced Features**

### **API Integration**

The admin panel exposes APIs for integration:

```bash
# Get service status
curl -s http://localhost:3000/api/services

# Get system metrics
curl -s http://localhost:3000/api/metrics

# Get logs
curl -s http://localhost:3000/api/logs?service=n8n
```

### **Webhook Integration**

Setup webhooks for alerts:

```bash
# Configure webhook
curl -X POST http://localhost:3000/api/webhooks \
  -H "Content-Type: application/json" \
  -d '{
    "event": "service_down",
    "url": "https://your-webhook-url"
  }'
```

### **CLI Integration**

Access admin functions via CLI:

```bash
# Get service status
docker service ls

# View logs
docker service logs <service_name>

# Restart service
docker service update --force <service_name>

# Check health
docker service ps <service_name>
```

---

## 📞 **Support & Documentation**

### **Getting Help**

1. Check logs: `docker service logs <service_name>`
2. Review documentation: `PRODUCTION_INSTALLER.md`
3. Check GitHub issues: https://github.com/hudsonargollo/caixapreta-stack/issues
4. Contact support: hudsonargollo@gmail.com

### **Documentation Links**

- [Production Installer Guide](PRODUCTION_INSTALLER.md)
- [Deployment Checklist](DEPLOYMENT_CHECKLIST.md)
- [Release Notes v3](RELEASE_NOTES_v3.md)
- [GitHub Repository](https://github.com/hudsonargollo/caixapreta-stack)

---

## ✅ **Setup Verification Checklist**

After setup, verify:

- [ ] Admin panel files are in `/data/painel/`
- [ ] Files have correct permissions (644)
- [ ] Admin panel is accessible at `https://your-domain/painel`
- [ ] All services are visible in the dashboard
- [ ] System metrics are displaying
- [ ] Service logs are accessible
- [ ] Quick links to services work
- [ ] Emergency controls are functional
- [ ] SSL certificate is valid
- [ ] Mobile access works

---

## 🎯 **Next Steps**

1. **Customize Branding**
   - Update logo and company name
   - Customize colors and theme
   - Add custom widgets

2. **Setup Monitoring**
   - Configure Grafana dashboards
   - Setup alert rules
   - Configure notifications

3. **Enable Security**
   - Setup authentication
   - Configure firewall rules
   - Enable VPN access

4. **Integrate Services**
   - Connect to n8n
   - Setup Evolution API
   - Configure Chatwoot

---

**Status**: ✅ Admin Panel is ready for deployment!

*Last Updated: April 27, 2026*

# 🚀 Deploy to Your VPS - Simple Instructions

**Version**: 3.0.0  
**Status**: ✅ Ready to Deploy  
**Time**: 5-10 minutes

---

## 🎯 One-Command Deployment

Copy and paste this command in your VPS terminal (as root):

```bash
git clone https://github.com/hudsonargollo/caixapreta-stack.git && cd caixapreta-stack && bash scripts/install/caixapreta-stack-production.sh
```

---

## 📋 Step-by-Step

### Step 1: SSH to Your VPS
```bash
ssh root@your-vps-ip
```

### Step 2: Clone Repository
```bash
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack
```

### Step 3: Run Installer
```bash
bash scripts/install/caixapreta-stack-production.sh
```

### Step 4: Answer Prompts
```
Enter your domain (e.g., clubemkt.digital): your-domain.com
Enter your email (for reference): your-email@example.com
```

### Step 5: Wait 5-10 Minutes
The installer will:
- Check system requirements
- Install Docker
- Create networks
- Deploy all services
- Configure Nginx
- Generate certificates

### Step 6: Access Your Services
```
n8n:        https://auto.your-domain.com
Evolution:  https://evo.your-domain.com
MinIO:      https://min.your-domain.com
Grafana:    https://graf.your-domain.com
Chatwoot:   https://chat.your-domain.com
Portainer:  https://port.your-domain.com
Admin Panel: https://painel.your-domain.com
```

---

## ✅ Pre-Deployment Checklist

Before running the installer, ensure:

- [ ] VPS with Ubuntu 20.04+ or Debian 11+
- [ ] Minimum 4GB RAM
- [ ] Minimum 40GB disk space
- [ ] Root SSH access
- [ ] Domain registered
- [ ] Domain proxied through Cloudflare (orange cloud)
- [ ] Email address available

---

## 🔐 Default Credentials

All services use:
```
Username: admin
Password: caixapretastack2626
```

**⚠️ CHANGE THESE IMMEDIATELY AFTER LOGIN!**

---

## 📊 What Gets Installed

✅ n8n (automation)  
✅ Evolution API (WhatsApp integration)  
✅ MinIO (file storage)  
✅ Grafana (monitoring)  
✅ Chatwoot (customer communication)  
✅ Portainer (Docker management)  
✅ PostgreSQL (database)  
✅ Redis (cache)  
✅ Nginx (reverse proxy)  
✅ Admin Panel (management interface)

---

## 🐛 If Something Goes Wrong

### Check Installation Logs
```bash
cat /tmp/caixapreta-install.log
```

### View Service Status
```bash
docker service ls
```

### View Service Logs
```bash
docker service logs <service_name>
```

### Restart a Service
```bash
docker service update --force <service_name>
```

---

## 📞 Support

- **Documentation**: Check files in repository
- **Issues**: https://github.com/hudsonargollo/caixapreta-stack/issues
- **Email**: hudsonargollo@gmail.com

---

**That's it! The installer handles everything else automatically.**

Deploy now:
```bash
git clone https://github.com/hudsonargollo/caixapreta-stack.git && cd caixapreta-stack && bash scripts/install/caixapreta-stack-production.sh
```

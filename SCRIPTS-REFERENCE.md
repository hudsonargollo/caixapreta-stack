# 🛠️ CaixaPreta Stack - Scripts Reference Guide

## 📋 Quick Reference

### 🚀 Installation Scripts
| Script | Description | Usage |
|--------|-------------|-------|
| `caixapreta-stack.sh` | Main installation script | `sudo ./caixapreta-stack.sh` |
| `validate-installation.sh` | Validates installation | `./validate-installation.sh` |

### 🔍 Diagnostic Scripts (Analysis Only)
| Script | Purpose | Usage |
|--------|---------|-------|
| `diagnose-all-services.sh` | **Complete system analysis** | `./diagnose-all-services.sh` |
| `diagnose-redis.sh` | Redis services analysis | `./diagnose-redis.sh` |
| `diagnose-postgres.sh` | PostgreSQL database analysis | `./diagnose-postgres.sh` |
| `diagnose-mega.sh` | MEGA (Chatwoot) analysis | `./diagnose-mega.sh` |
| `diagnose-traefik.sh` | SSL/Proxy analysis | `./diagnose-traefik.sh` |
| `diagnose-portainer.sh` | Portainer access analysis | `./diagnose-portainer.sh` |
| `diagnose-connectivity.sh` | Network connectivity test | `./diagnose-connectivity.sh` |
| `diagnose-ssl-dns.sh` | SSL certificates and DNS | `./diagnose-ssl-dns.sh` |
| `diagnose-swarm.sh` | Docker Swarm cluster | `./diagnose-swarm.sh` |

### 🔧 Fix Scripts (Automatic Repair)
| Script | Purpose | Usage |
|--------|---------|-------|
| `fix-and-redeploy.sh` | **Complete system fix** | `sudo ./fix-and-redeploy.sh` |
| `fix-redis-deployment.sh` | Fix Redis services | `sudo ./fix-redis-deployment.sh` |
| `fix-postgres-deployment.sh` | Fix PostgreSQL database | `sudo ./fix-postgres-deployment.sh` |
| `fix-mega.sh` | Fix MEGA 404 errors | `sudo ./fix-mega.sh` |
| `fix-traefik-deployment.sh` | Fix SSL/Proxy issues | `sudo ./fix-traefik-deployment.sh` |
| `fix-network-conflict.sh` | Fix network conflicts | `sudo ./fix-network-conflict.sh` |
| `fix-portainer.sh` | Fix Portainer access | `sudo ./fix-portainer.sh` |

### 🧹 Maintenance Scripts
| Script | Purpose | Usage |
|--------|---------|-------|
| `wipe-vps.sh` | Clean VPS completely | `sudo ./wipe-vps.sh` |
| `manual-deploy.sh` | Manual deployment | `sudo ./manual-deploy.sh` |

## 🚨 Problem-Solving Workflow

### Step 1: Identify the Problem
```bash
# Run comprehensive diagnostic first
./diagnose-all-services.sh

# Or run specific diagnostic for known issues
./diagnose-redis.sh        # If Redis issues
./diagnose-postgres.sh     # If database issues
./diagnose-mega.sh         # If MEGA 404 errors
```

### Step 2: Apply the Fix
```bash
# Use corresponding fix script
sudo ./fix-redis-deployment.sh     # For Redis issues
sudo ./fix-postgres-deployment.sh  # For database issues
sudo ./fix-mega.sh                 # For MEGA issues

# Or use comprehensive fix for multiple issues
sudo ./fix-and-redeploy.sh
```

### Step 3: Verify the Solution
```bash
# Re-run diagnostic to confirm fix
./diagnose-all-services.sh

# Check service status
docker service ls
```

## 🔴 Common Problem Scenarios

### Redis Services Not Working (0/1 replicas)
**Symptoms:** n8n and MEGA don't work, Redis shows 0/1 replicas
```bash
# Diagnose
./diagnose-redis.sh

# Fix
sudo ./fix-redis-deployment.sh

# Verify
docker service ls | grep redis
```

### PostgreSQL Not Starting (0/1 replicas)
**Symptoms:** Database connection errors, dependent services fail
```bash
# Diagnose
./diagnose-postgres.sh

# Fix
sudo ./fix-postgres-deployment.sh

# Verify
docker service logs db_postgres
```

### MEGA Returns 404 Error
**Symptoms:** mega.yourdomain.com shows 404 page
```bash
# Diagnose
./diagnose-mega.sh

# Fix
sudo ./fix-mega.sh

# Verify
curl -I https://mega.yourdomain.com
```

### SSL Certificates Not Working
**Symptoms:** Browser shows "Not Secure" or certificate errors
```bash
# Diagnose
./diagnose-ssl-dns.sh

# Fix
sudo ./fix-traefik-deployment.sh

# Verify
curl -I https://n8n.yourdomain.com
```

### Multiple Services Failing
**Symptoms:** Several services show 0/1 replicas
```bash
# Comprehensive diagnostic
./diagnose-all-services.sh

# Comprehensive fix
sudo ./fix-and-redeploy.sh

# Monitor progress
watch docker service ls
```

## 📥 How to Download Scripts

### Option 1: Clone Complete Repository
```bash
git clone https://github.com/hudsonargollo/caixapreta-stack.git
cd caixapreta-stack
chmod +x *.sh
```

### Option 2: Download Individual Scripts
```bash
# Example: Download Redis diagnostic
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-redis.sh
chmod +x diagnose-redis.sh

# Example: Download PostgreSQL fix
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-postgres-deployment.sh
chmod +x fix-postgres-deployment.sh
```

### Option 3: Download All Diagnostic Scripts
```bash
# Download all diagnostic scripts
for script in diagnose-all-services diagnose-redis diagnose-postgres diagnose-mega diagnose-traefik diagnose-portainer diagnose-connectivity diagnose-ssl-dns diagnose-swarm; do
    wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/${script}.sh
done

chmod +x diagnose-*.sh
```

### Option 4: Download All Fix Scripts
```bash
# Download all fix scripts
for script in fix-and-redeploy fix-redis-deployment fix-postgres-deployment fix-mega fix-traefik-deployment fix-network-conflict fix-portainer; do
    wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/${script}.sh
done

chmod +x fix-*.sh
```

## 🎯 Script Categories Explained

### 🔍 Diagnostic Scripts
- **Purpose:** Analyze and identify problems
- **Safe to run:** Yes, read-only operations
- **When to use:** When you suspect issues or want to check system health
- **Output:** Detailed analysis with recommendations

### 🔧 Fix Scripts
- **Purpose:** Automatically repair identified problems
- **Safe to run:** Generally yes, but make backups first
- **When to use:** After diagnostic scripts identify issues
- **Output:** Step-by-step fix process with verification

### 🚀 Installation Scripts
- **Purpose:** Deploy or redeploy the entire stack
- **Safe to run:** On clean systems or when doing complete reinstall
- **When to use:** Initial installation or complete system rebuild
- **Output:** Full deployment process

## ⚠️ Important Notes

### Before Running Fix Scripts
1. **Always run diagnostic first** to understand the problem
2. **Make backups** of important data if possible
3. **Check system resources** (memory, disk space)
4. **Ensure you have root access** (most fix scripts need sudo)

### Script Execution Order
1. **Diagnostic** → Identify issues
2. **Fix** → Resolve issues  
3. **Validate** → Confirm resolution
4. **Monitor** → Watch for recurring issues

### Emergency Recovery
If multiple scripts fail or system is severely broken:
```bash
# Nuclear option - complete system wipe and reinstall
sudo ./wipe-vps.sh
sudo ./caixapreta-stack.sh
```

## 📞 Support

If scripts don't resolve your issues:
- 📱 **WhatsApp:** [+55 73 98808-3318](https://wa.me/5573988083318)
- 🌐 **Website:** [caixapreta.clubemkt.digital](https://caixapreta.clubemkt.digital/)
- 💬 **Community:** Access via CaixaPreta bundle

---

**💡 Pro Tip:** Always run `./diagnose-all-services.sh` first for a complete system overview before using specific diagnostic or fix scripts.
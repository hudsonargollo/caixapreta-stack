# Moltbot Integration Guide

## Overview
Moltbot has been integrated into the Caixa Preta Stack as an optional service that can be deployed alongside the existing infrastructure.

## Installation

### During Setup
When running the enhanced installer script, you'll be prompted:

```
Do you want to deploy Moltbot? (y/n, default: n):
```

Simply answer `y` or `yes` to include Moltbot in your deployment.

### What Gets Deployed

When Moltbot is enabled, the installer will:

1. **Create Database**: `moltbot_db` in PostgreSQL
2. **Create Data Directory**: `/data/moltbot` with proper permissions (UID 1000)
3. **Deploy Service**: Docker service with Traefik integration
4. **Configure SSL**: Automatic Let's Encrypt certificate via Traefik
5. **Setup Networking**: Connected to both `traefik-public` and `internal-net` networks

## Service Configuration

### Environment Variables
```
MOLTBOT_HOST=moltbot.$domain
MOLTBOT_PORT=3000
MOLTBOT_PROTOCOL=https
NODE_ENV=production
DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/moltbot_db
REDIS_URL=redis://db_redis-n8n:6379/2
API_KEY=caixapretastack2626
WEBHOOK_URL=https://moltbot.$domain
LOG_LEVEL=info
```

### Resource Limits
- **Memory Limit**: 512MB
- **Memory Reservation**: 256MB
- **Restart Policy**: On-failure with 20s delay, max 5 attempts

### Health Check
- **Endpoint**: `http://localhost:3000/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3
- **Start Period**: 60 seconds

## Access

Once deployed, Moltbot will be available at:
```
https://moltbot.$domain
```

Where `$domain` is the domain you specified during installation.

## Database

Moltbot uses a dedicated PostgreSQL database:
- **Database Name**: `moltbot_db`
- **Host**: `db_postgres` (internal network)
- **Port**: 5432
- **User**: `postgres`
- **Password**: `caixapretastack2626`

## Redis

Moltbot uses Redis for caching and sessions:
- **Host**: `db_redis-n8n` (internal network)
- **Port**: 6379
- **Database**: 2 (dedicated to Moltbot)

## Parallel Deployment

Moltbot runs in parallel with:
- n8n (automation)
- Evolution API (WhatsApp integration)
- Gowa WhatsApp API (alternative WhatsApp integration)
- MEGA/Chatwoot (customer support)
- All monitoring and infrastructure services

All services share the same PostgreSQL and Redis instances for efficiency.

## Troubleshooting

### Check Service Status
```bash
docker service ls | grep moltbot
docker service ps automation_moltbot
```

### View Logs
```bash
docker service logs automation_moltbot
```

### Restart Service
```bash
docker service update --force automation_moltbot
```

### Database Issues
```bash
# Connect to PostgreSQL
docker exec -it $(docker ps -q -f "label=com.docker.swarm.service.name=infrastructure_db_postgres") \
  psql -U postgres -d moltbot_db
```

## Security Notes

1. **Change Default Password**: The default API key is `caixapretastack2626`. Change this immediately in production.
2. **SSL Certificates**: Automatically managed by Traefik with Let's Encrypt
3. **Network Isolation**: Moltbot is isolated on internal networks and only exposed via Traefik
4. **Data Persistence**: All data is stored in `/data/moltbot` on the host

## Scaling

To scale Moltbot to multiple replicas:
```bash
docker service update --replicas 3 automation_moltbot
```

Note: Ensure your database and Redis can handle multiple connections.

## Uninstalling Moltbot

To remove Moltbot from an existing deployment:

```bash
# Remove the service
docker service rm automation_moltbot

# Remove the database (optional)
docker exec -it $(docker ps -q -f "label=com.docker.swarm.service.name=infrastructure_db_postgres") \
  psql -U postgres -c "DROP DATABASE moltbot_db;"

# Remove data directory (optional)
rm -rf /data/moltbot
```

## Integration with Other Services

### With n8n
Moltbot can be triggered from n8n workflows via webhooks:
```
https://moltbot.$domain/webhook
```

### With Evolution API
Moltbot can integrate with Evolution API for WhatsApp automation:
```
https://evolution.$domain
```

### With MEGA/Chatwoot
Moltbot can work alongside MEGA for customer support:
```
https://mega.$domain
```

## Support

For issues or questions about Moltbot integration:
1. Check the logs: `docker service logs automation_moltbot`
2. Verify database connectivity
3. Ensure DNS records are properly configured
4. Check SSL certificate status via Traefik dashboard

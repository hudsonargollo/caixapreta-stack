# OpenClaw Integration Guide

## Overview
OpenClaw (formerly Clawdbot, then Moltbot) has been integrated into the Caixa Preta Stack as an optional service that can be deployed alongside the existing infrastructure.

OpenClaw is a free and open-source autonomous AI agent that can execute tasks via large language models (LLMs), using messaging platforms as its main user interface.

## Naming History
- **Clawdbot** (2025) - Original name
- **Moltbot** (late 2025) - First rebrand after trademark issues with Anthropic
- **OpenClaw** (January 2026) - Current and final name

## Installation

### During Setup
When running the enhanced installer script, you'll be prompted:

```
Do you want to deploy OpenClaw (formerly Clawdbot/Moltbot)? (y/n, default: n):
```

Simply answer `y` or `yes` to include OpenClaw in your deployment.

### What Gets Deployed

When OpenClaw is enabled, the installer will:

1. **Create Database**: `openclaw_db` in PostgreSQL
2. **Create Data Directory**: `/data/openclaw` with proper permissions (UID 1000)
3. **Deploy Service**: Docker service with Traefik integration
4. **Configure SSL**: Automatic Let's Encrypt certificate via Traefik
5. **Setup Networking**: Connected to both `traefik-public` and `internal-net` networks

## Service Configuration

### Environment Variables
```
OPENCLAW_HOST=openclaw.$domain
OPENCLAW_PORT=3000
OPENCLAW_PROTOCOL=https
NODE_ENV=production
DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/openclaw_db
REDIS_URL=redis://db_redis-n8n:6379/2
API_KEY=caixapretastack2626
WEBHOOK_URL=https://openclaw.$domain
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

Once deployed, OpenClaw will be available at:
```
https://openclaw.$domain
```

Where `$domain` is the domain you specified during installation.

## Database

OpenClaw uses a dedicated PostgreSQL database:
- **Database Name**: `openclaw_db`
- **Host**: `db_postgres` (internal network)
- **Port**: 5432
- **User**: `postgres`
- **Password**: `caixapretastack2626`

## Redis

OpenClaw uses Redis for caching and sessions:
- **Host**: `db_redis-n8n` (internal network)
- **Port**: 6379
- **Database**: 2 (dedicated to OpenClaw)

## Key Features

OpenClaw is an autonomous AI agent with:
- **Tool Use Capabilities**: Web search, browser automation, file management
- **Messaging Integration**: Works with WhatsApp, Telegram, Discord
- **Self-Hosted**: Runs on your own infrastructure
- **Open Source**: Full control and transparency
- **Spicy Shell Access**: Can execute code and control local environments

## Parallel Deployment

OpenClaw runs in parallel with:
- n8n (automation)
- Evolution API (WhatsApp integration)
- Gowa WhatsApp API (alternative WhatsApp integration)
- MEGA/Chatwoot (customer support)
- All monitoring and infrastructure services

All services share the same PostgreSQL and Redis instances for efficiency.

## Troubleshooting

### Check Service Status
```bash
docker service ls | grep openclaw
docker service ps automation_openclaw
```

### View Logs
```bash
docker service logs automation_openclaw
```

### Restart Service
```bash
docker service update --force automation_openclaw
```

### Database Issues
```bash
# Connect to PostgreSQL
docker exec -it $(docker ps -q -f "label=com.docker.swarm.service.name=infrastructure_db_postgres") \
  psql -U postgres -d openclaw_db
```

## Security Notes

1. **Change Default Password**: The default API key is `caixapretastack2626`. Change this immediately in production.
2. **SSL Certificates**: Automatically managed by Traefik with Let's Encrypt
3. **Network Isolation**: OpenClaw is isolated on internal networks and only exposed via Traefik
4. **Data Persistence**: All data is stored in `/data/openclaw` on the host

## Scaling

To scale OpenClaw to multiple replicas:
```bash
docker service update --replicas 3 automation_openclaw
```

Note: Ensure your database and Redis can handle multiple connections.

## Uninstalling OpenClaw

To remove OpenClaw from an existing deployment:

```bash
# Remove the service
docker service rm automation_openclaw

# Remove the database (optional)
docker exec -it $(docker ps -q -f "label=com.docker.swarm.service.name=infrastructure_db_postgres") \
  psql -U postgres -c "DROP DATABASE openclaw_db;"

# Remove data directory (optional)
rm -rf /data/openclaw
```

## Integration with Other Services

### With n8n
OpenClaw can be triggered from n8n workflows via webhooks:
```
https://openclaw.$domain/webhook
```

### With Evolution API
OpenClaw can integrate with Evolution API for WhatsApp automation:
```
https://evolution.$domain
```

### With MEGA/Chatwoot
OpenClaw can work alongside MEGA for customer support:
```
https://mega.$domain
```

### With Messaging Platforms
OpenClaw connects to:
- WhatsApp (via Evolution API or Gowa)
- Telegram
- Discord

## Support

For issues or questions about OpenClaw integration:
1. Check the logs: `docker service logs automation_openclaw`
2. Verify database connectivity
3. Ensure DNS records are properly configured
4. Check SSL certificate status via Traefik dashboard
5. Visit [OpenClaw GitHub](https://github.com/openclaw/openclaw) for project documentation

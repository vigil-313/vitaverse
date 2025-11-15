# Deployment Guide

Guide for deploying Vitaverse server to production.

## Quick Start

### Deploy to Linux Mini PC (Home Server)

```bash
# 1. Build server on your Mac
cd packages/godot-game
godot --headless --export-release "Linux Server" build/server/vitaverse-server

# 2. Copy to mini PC
scp -r build/server/ user@minipc:/opt/vitaverse/

# 3. SSH to mini PC and run
ssh user@minipc
cd /opt/vitaverse/server
./vitaverse-server --headless
```

### Deploy to Cloud (DigitalOcean, AWS, etc.)

See sections below for detailed instructions.

---

## Deployment Targets

### 1. Linux Mini PC (Recommended for Development/Alpha)

**Pros:**
- Free hosting (after hardware cost)
- Full control
- Good for testing with friends

**Cons:**
- Your responsibility if it goes down
- Limited by home internet upload speed
- Need to configure router port forwarding

**Setup:**

```bash
# On Mini PC (Ubuntu/Debian)
sudo apt update
sudo apt install wget unzip

# Create directory
sudo mkdir -p /opt/vitaverse
sudo chown $USER:$USER /opt/vitaverse

# Copy server files (from your Mac)
# scp -r build/server/* user@minipc:/opt/vitaverse/

# Run server
cd /opt/vitaverse
./vitaverse-server --headless -- --env=production

# Keep running with systemd (see below)
```

**Systemd Service** (`/etc/systemd/system/vitaverse.service`):

```ini
[Unit]
Description=Vitaverse Game Server
After=network.target

[Service]
Type=simple
User=vitaverse
WorkingDirectory=/opt/vitaverse
ExecStart=/opt/vitaverse/vitaverse-server --headless -- --env=production
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable vitaverse
sudo systemctl start vitaverse
sudo systemctl status vitaverse
```

**Port Forwarding:**
- Forward port 9000 TCP to your mini PC's local IP
- Set static IP for mini PC in router settings
- Consider using dynamic DNS (DuckDNS, No-IP) if your ISP IP changes

### 2. Cloud VPS (Production)

**Providers:**
- DigitalOcean ($5-10/month for starter)
- Linode ($5-10/month)
- AWS Lightsail ($3.50-10/month)
- Hetzner (€4-10/month, very cheap)

**Recommended Specs (Starter):**
- 1 CPU core
- 1-2GB RAM
- 25GB SSD
- Ubuntu 22.04 LTS

**Setup:**

```bash
# 1. Create droplet/VPS with Ubuntu 22.04

# 2. SSH to server
ssh root@your-server-ip

# 3. Create vitaverse user
adduser vitaverse
usermod -aG sudo vitaverse
su - vitaverse

# 4. Upload server
scp -r build/server/* vitaverse@your-server-ip:/home/vitaverse/

# 5. Install dependencies (if needed)
sudo apt update
sudo apt install wget unzip

# 6. Run server
cd /home/vitaverse/server
./vitaverse-server --headless -- --env=production
```

**Firewall:**
```bash
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 9000/tcp # Vitaverse
sudo ufw enable
```

### 3. Docker (Any Platform)

**Dockerfile** (create in `packages/infrastructure/docker/`):

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create vitaverse user
RUN useradd -m -s /bin/bash vitaverse

# Copy server files
COPY build/server/ /opt/vitaverse/
RUN chown -R vitaverse:vitaverse /opt/vitaverse

# Switch to vitaverse user
USER vitaverse
WORKDIR /opt/vitaverse

# Expose port
EXPOSE 9000

# Run server
CMD ["./vitaverse-server", "--headless", "--", "--env=production"]
```

**Build and Run:**
```bash
# Build image
docker build -t vitaverse-server -f packages/infrastructure/docker/Dockerfile .

# Run container
docker run -d \
  --name vitaverse \
  -p 9000:9000 \
  -v vitaverse-data:/opt/vitaverse/data \
  --restart unless-stopped \
  vitaverse-server

# View logs
docker logs -f vitaverse
```

**Docker Compose** (`docker-compose.yml`):

```yaml
version: '3.8'

services:
  server:
    build:
      context: .
      dockerfile: packages/infrastructure/docker/Dockerfile
    ports:
      - "9000:9000"
    volumes:
      - vitaverse-data:/opt/vitaverse/data
    restart: unless-stopped
    environment:
      - VITAVERSE_ENV=production

  # Future: Add PostgreSQL
  # db:
  #   image: postgres:15
  #   ...

volumes:
  vitaverse-data:
```

---

## Database Migration

### Phase 1: SQLite (Current)

Data stored in: `server/data/world/vitaverse.db`

**Backup:**
```bash
cp server/data/world/vitaverse.db backups/vitaverse-$(date +%Y%m%d).db
```

### Phase 2: PostgreSQL (Future)

When player count grows, migrate to PostgreSQL:

**Install PostgreSQL:**
```bash
sudo apt install postgresql postgresql-contrib
```

**Create Database:**
```sql
CREATE DATABASE vitaverse;
CREATE USER vitaverse WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE vitaverse TO vitaverse;
```

**Update Config:**
```gdscript
# shared/config.gd
Environment.PRODUCTION: {
    "db_path": "postgresql://vitaverse:password@localhost/vitaverse"
}
```

---

## Monitoring

### Server Logs

```bash
# If running with systemd
sudo journalctl -u vitaverse -f

# If running manually
tail -f vitaverse.log
```

### Performance Monitoring

**Simple Script** (`monitor.sh`):

```bash
#!/bin/bash
while true; do
    echo "=== $(date) ==="
    ps aux | grep vitaverse-server | grep -v grep
    echo ""
    sleep 60
done
```

**Future: Prometheus + Grafana**
- Expose metrics endpoint
- Scrape with Prometheus
- Visualize with Grafana

---

## Backup Strategy

### Automatic Backups

**Backup Script** (`backup.sh`):

```bash
#!/bin/bash
BACKUP_DIR="/backups/vitaverse"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup world data
tar -czf $BACKUP_DIR/world-$DATE.tar.gz \
    /opt/vitaverse/server/data/world/

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup complete: world-$DATE.tar.gz"
```

**Cron Job** (daily at 3 AM):
```bash
crontab -e
# Add:
0 3 * * * /opt/vitaverse/backup.sh >> /var/log/vitaverse-backup.log 2>&1
```

### Cloud Backups

Sync to S3/Backblaze:
```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure (interactive)
rclone config

# Sync backups
rclone sync /backups/vitaverse remote:vitaverse-backups
```

---

## Scaling

### Vertical Scaling (Single Server)

| Players | CPU | RAM | Disk |
|---------|-----|-----|------|
| 10-50 | 1 core | 1GB | 10GB |
| 50-200 | 2 cores | 2GB | 25GB |
| 200-500 | 4 cores | 4GB | 50GB |
| 500+ | 8+ cores | 8GB+ | 100GB+ |

### Horizontal Scaling (Multiple Servers)

**Future Architecture:**

```
[Load Balancer]
    ↓
[Server Fleet]
    ↓
[PostgreSQL Cluster]
```

Each server handles a region/area of the world.

---

## Security

### Firewall

```bash
sudo ufw allow 22/tcp   # SSH (restrict to your IP)
sudo ufw allow 9000/tcp # Game port
sudo ufw enable
```

### Fail2ban (SSH Protection)

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

### SSL/TLS (Future)

Use reverse proxy (nginx) with Let's Encrypt:
```
[Client] --HTTPS--> [Nginx] --WSS--> [Vitaverse Server]
```

---

## Troubleshooting

### Server Won't Start

```bash
# Check logs
sudo journalctl -u vitaverse -n 50

# Check if port is in use
sudo netstat -tulpn | grep 9000

# Check file permissions
ls -la /opt/vitaverse/
```

### High CPU Usage

```bash
# Check server performance
htop

# Reduce tick rate in config
# shared/config.gd: "tick_rate": 30
```

### Players Can't Connect

```bash
# Check if server is listening
sudo netstat -tulpn | grep 9000

# Check firewall
sudo ufw status

# Check from outside network
nc -zv your-public-ip 9000
```

---

## Rollback Procedure

If deployment fails:

```bash
# 1. Stop new server
sudo systemctl stop vitaverse

# 2. Restore previous version
cp /opt/vitaverse/server.backup /opt/vitaverse/vitaverse-server

# 3. Restore world data
tar -xzf /backups/vitaverse/world-latest.tar.gz -C /opt/vitaverse/

# 4. Restart
sudo systemctl start vitaverse
```

---

## Cost Estimates

### Hobby (10-50 players)

- **Option 1**: Linux Mini PC at home - $0/month (after $100-200 initial cost)
- **Option 2**: VPS (DigitalOcean) - $5-10/month

### Small (50-200 players)

- VPS: $10-20/month
- Domain: $12/year
- Total: ~$15/month

### Medium (200-1000 players)

- VPS: $40-80/month
- PostgreSQL managed DB: $15-30/month
- CDN (Cloudflare): $0-20/month
- Total: ~$60-130/month

### Large (1000+ players)

- Multiple servers: $200+/month
- Database cluster: $100+/month
- Load balancer: $20/month
- CDN: $50+/month
- Total: $370+/month

---

**Last Updated**: 2025-11-15

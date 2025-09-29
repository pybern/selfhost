# Complete Deployment & Development Guide

## Overview

This guide covers the complete workflow for developing, deploying, and updating your Next.js application on a VPS.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │───▶│   GitHub Repo    │───▶│   VPS Server    │
│   Environment   │    │  pybern/selfhost │    │  Ubuntu Linux   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────▼─────────┐
                                               │     Nginx         │
                                               │ Reverse Proxy     │
                                               └─────────┬─────────┘
                                                        │
                                               ┌─────────▼─────────┐
                                               │   Docker Compose  │
                                               │                   │
                                               │ ┌─────────────┐   │
                                               │ │  Next.js    │   │
                                               │ │ Container   │   │
                                               │ │   :3000     │   │
                                               │ └─────────────┘   │
                                               │                   │
                                               │ ┌─────────────┐   │
                                               │ │ PostgreSQL  │   │
                                               │ │ Container   │   │
                                               │ │   :5432     │   │
                                               │ └─────────────┘   │
                                               │                   │
                                               │ ┌─────────────┐   │
                                               │ │ Cron Job    │   │
                                               │ │ Container   │   │
                                               │ └─────────────┘   │
                                               └───────────────────┘
```

## Initial Setup Process

### 1. Server Preparation

```bash
# SSH into your server
ssh root@your_server_ip

# Download deployment script
curl -o ~/deploy.sh https://raw.githubusercontent.com/pybern/selfhost/main/deploy.sh

# Make it executable
chmod +x ~/deploy.sh

# Edit the script to customize your environment variables
nano ~/deploy.sh
```

### 2. Environment Variables Configuration

Edit these variables in `deploy.sh` before running:

```bash
TOI_DOMAIN_NAME="your-domain.com"  # or your server IP
TOI_EMAIL="your-email@example.com"
```

### 3. Run Initial Deployment

```bash
./deploy.sh
```

This will:
- Install Docker, Docker Compose, Nginx
- Clone your repository to `~/toiapp`
- Create `.env` file with database credentials
- Build and start all containers
- Configure Nginx reverse proxy

## Development Workflow

### 1. Local Development

```bash
# Clone your repository locally
git clone https://github.com/pybern/selfhost.git
cd selfhost

# Install dependencies
npm install

# Run locally with Docker
docker-compose up -d

# Or run in development mode
npm run dev
```

### 2. Testing Changes

```bash
# Test with Docker (production-like environment)
docker-compose up --build -d

# Check logs
docker-compose logs web

# Access at http://localhost:3000
```

### 3. Deploying Updates

```bash
# Commit your changes
git add .
git commit -m "Add new feature"
git push origin main

# SSH into your server
ssh root@your_server_ip

# Navigate to app directory
cd ~/toiapp

# Run update script
./update.sh
```

## Environment Variables Reference

### Server Environment Variables (set in deploy.sh)

| Variable | Purpose | Example |
|----------|---------|---------|
| `TOI_POSTGRES_USER` | Database username | `toi-user` |
| `TOI_POSTGRES_PASSWORD` | Database password | `auto-generated` |
| `TOI_POSTGRES_DB` | Database name | `toi-db` |
| `TOI_SECRET_KEY` | App secret key | `toi-secret` |
| `NEXT_PUBLIC_TOI_SAFE_KEY` | Client-side env var | `toi-key` |
| `TOI_DOMAIN_NAME` | Your domain/IP | `example.com` |
| `TOI_EMAIL` | Your email | `you@example.com` |

### Generated Environment Variables (in .env file)

| Variable | Purpose |
|----------|---------|
| `TOI_DATABASE_URL` | Internal Docker connection |
| `TOI_DATABASE_URL_EXTERNAL` | External tools connection |

## File Structure on Server

```
~/toiapp/
├── .env                    # Environment variables
├── deploy.sh               # Initial deployment script
├── update.sh              # Update deployment script
├── docker-compose.yml     # Container orchestration
├── Dockerfile             # Next.js container build
├── package.json           # Dependencies
├── next.config.ts         # Next.js configuration
├── app/                   # Next.js application
│   ├── db/               # Database related files
│   │   ├── drizzle.ts    # Database connection
│   │   ├── schema.ts     # Database schema
│   │   └── migrations/   # Database migrations
│   └── ...
└── public/               # Static files
```

## Database Management

### Connecting to Database

```bash
# From server, enter database container
docker exec -it toiapp-db-1 psql -U toi-user -d toi-db

# Run SQL commands
SELECT * FROM todos;

# Exit
\q
```

### Using Drizzle Studio

```bash
# From ~/toiapp directory
npm run db:studio
```

Access at `http://your-server-ip:4983`

### Schema Changes

```bash
# Generate migration after schema changes
npm run db:generate

# Apply migrations
npm run db:push
```

## Monitoring and Troubleshooting

### Container Status

```bash
cd ~/toiapp
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs web
docker-compose logs db
docker-compose logs cron
```

### System Health

```bash
# Check system resources
free -h
df -h
top

# Check nginx status
sudo systemctl status nginx

# Test nginx configuration
sudo nginx -t
```

### Common Issues and Solutions

#### 1. Environment Variable Errors

**Error**: `The "POSTGRES_DB" variable is not set`
**Solution**: Ensure `docker-compose.yml` uses `TOI_` prefixed variables

#### 2. Build Failures

**Error**: `npm run build failed`
**Solution**: 
- Check application code for errors
- Verify all dependencies are installed
- Check Next.js configuration

#### 3. Database Connection Issues

**Error**: Database connection refused
**Solution**:
- Ensure database container is running
- Check `.env` file has correct database URL
- Verify container networking

#### 4. Nginx Errors

**Error**: `nginx.service failed`
**Solution**:
- Check nginx configuration: `sudo nginx -t`
- View logs: `journalctl -xeu nginx.service`
- Restart nginx: `sudo systemctl restart nginx`

## Performance Optimization

### 1. Docker Image Size

- Uses multi-stage builds
- Standalone Next.js output reduces size by 80%

### 2. Nginx Configuration

- Rate limiting (10 requests/second)
- Proxy buffering disabled for streaming
- Gzip compression handled by Nginx

### 3. Database

- Persistent volumes for data
- Automatic cleanup cron job (every 10 minutes for demo)

## Security Considerations

### 1. Environment Variables

- All sensitive data in `.env` file
- Database password auto-generated
- No secrets in repository

### 2. Network Security

- Containers isolated in Docker network
- Nginx rate limiting
- SSL/TLS ready (commented out in current setup)

### 3. Updates

- Regular system updates via `apt update && apt upgrade`
- Container isolation

## SSL/HTTPS Setup (Optional)

To enable SSL, uncomment the certbot sections in `deploy.sh`:

```bash
# Uncomment these lines in deploy.sh
sudo apt install certbot -y
sudo certbot certonly --standalone -d $TOI_DOMAIN_NAME --non-interactive --agree-tos -m $TOI_EMAIL
```

Then update the Nginx configuration to include SSL.

## Backup Strategy

### 1. Database Backup

```bash
# Create backup
docker exec toiapp-db-1 pg_dump -U toi-user toi-db > backup.sql

# Restore backup
docker exec -i toiapp-db-1 psql -U toi-user toi-db < backup.sql
```

### 2. Environment Backup

```bash
# Backup .env file
cp ~/toiapp/.env ~/toiapp-env-backup
```

### 3. Code Backup

Your code is already backed up in your GitHub repository.

## Scaling Considerations

### Horizontal Scaling

- Load balancer in front of multiple app instances
- Separate database server
- Redis for session storage/caching

### Vertical Scaling

- Increase server resources (CPU, RAM)
- Optimize Docker resource limits
- Database performance tuning

## Clean Up

If you need to completely remove the installation:

```bash
# Download and run cleanup script
curl -o ~/cleanup.sh https://raw.githubusercontent.com/pybern/selfhost/main/cleanup.sh
chmod +x ~/cleanup.sh
./cleanup.sh
```

## Support and Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Drizzle ORM Documentation](https://orm.drizzle.team/)

## Changelog

- **v1.0**: Initial setup with TOI_ environment variables
- **v1.1**: Added comprehensive deployment guide
- **v1.2**: Updated for pybern/selfhost repository
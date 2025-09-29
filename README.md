# Next.js Self Hosting Example

This repo shows how to deploy a Next.js app and a PostgreSQL database on a Ubuntu Linux server using Docker and Nginx. It showcases using several features of Next.js like caching, ISR, environment variables, and more.

## Prerequisites

1. Purchase a domain name (optional - can use IP address)
2. Purchase a Linux Ubuntu server (e.g. [DigitalOcean droplet](https://www.digitalocean.com/products/droplets))
3. Create an `A` DNS record pointing to your server IPv4 address (if using domain)

## Quickstart

1. **SSH into your server**:

   ```bash
   ssh root@your_server_ip
   ```

2. **Download the deployment script**:

   ```bash
   curl -o ~/deploy.sh https://raw.githubusercontent.com/pybern/selfhost/main/deploy.sh
   ```

   You can then modify the email, domain name, and other variables inside of the script to use your own.

3. **Run the deployment script**:

   ```bash
   chmod +x ~/deploy.sh
   ./deploy.sh
   ```

## Development Workflow

### Making Code Changes and Deploying

1. **Make changes locally** to your Next.js application
2. **Test locally** using Docker:
   ```bash
   docker-compose up -d
   ```
3. **Commit and push** your changes to your repository:
   ```bash
   git add .
   git commit -m "Your commit message"
   git push origin main
   ```
4. **Deploy updates to your VPS**:
   ```bash
   # SSH into your server
   ssh root@your_server_ip
   
   # Run the update script
   cd ~/toiapp
   chmod +x update.sh
   ./update.sh
   ```

### Environment Variables

All environment variables use the `TOI_` prefix for consistency:

- `TOI_POSTGRES_USER` - Database user
- `TOI_POSTGRES_PASSWORD` - Database password (auto-generated)
- `TOI_POSTGRES_DB` - Database name
- `TOI_DATABASE_URL` - Internal database connection (for Docker containers)
- `TOI_DATABASE_URL_EXTERNAL` - External database connection (for tools like Drizzle Studio)
- `TOI_SECRET_KEY` - Application secret key
- `NEXT_PUBLIC_TOI_SAFE_KEY` - Client-side environment variable
- `TOI_DOMAIN_NAME` - Your domain/IP address
- `TOI_EMAIL` - Your email address

## Supported Features

This demo tries to showcase many different Next.js features.

- Image Optimization
- Streaming
- Talking to a Postgres database
- Caching
- Incremental Static Regeneration
- Reading environment variables
- Using Middleware
- Running code on server startup
- A cron that hits a Route Handler

## Deploy Script

I've included a Bash script which does the following:

1. Installs all the necessary packages for your server
2. Installs Docker, Docker Compose, and Nginx
3. Clones this repository to `~/toiapp`
4. Generates environment variables with `TOI_` prefix
5. Builds your Next.js application from the Dockerfile
6. Sets up Nginx with reverse proxy, rate limiting, and streaming support
7. Sets up a cron which clears the database every 10 minutes
8. Creates a `.env` file with your Postgres database credentials

Once the deployment completes, your Next.js app will be available at:

```
http://your-domain-or-ip
```

Both the Next.js app and PostgreSQL database will be up and running in Docker containers. The database is automatically initialized with the required schema through Drizzle migrations.

## Database Setup

The database is automatically set up during deployment. To manually access or manage the database:

```bash
# Enter the Postgres container
docker exec -it toiapp-db-1 sh

# Connect to the database
psql -U toi-user -d toi-db

# Or run SQL commands directly
docker exec -it toiapp-db-1 psql -U toi-user -d toi-db -c "SELECT * FROM todos;"
```

For database management with Drizzle Studio:

```bash
cd ~/toiapp
npm run db:studio
```

## Update Script

For pushing subsequent updates after making code changes, use the included `update.sh` script:

```bash
cd ~/toiapp
./update.sh
```

This script:
1. Pulls the latest changes from your Git repository
2. Rebuilds and restarts Docker containers
3. Preserves your existing `.env` file and data

## Running Locally

If you want to run this setup locally using Docker, you can follow these steps:

```bash
docker-compose up -d
```

This will start both services and make your Next.js app available at `http://localhost:3000` with the PostgreSQL database running in the background. We also create a network so that our two containers can communicate with each other.

If you want to view the contents of the local database, you can use Drizzle Studio:

```bash
bun run db:studio
```

## Helpful Commands

### Docker Management
- `docker-compose ps` – check status of Docker containers
- `docker-compose logs web` – view Next.js output logs
- `docker-compose logs db` – view PostgreSQL logs
- `docker-compose logs cron` – view cron logs
- `docker-compose down` - shut down the Docker containers
- `docker-compose up -d` - start containers in the background
- `docker-compose restart web` - restart just the web container

### Container Access
- `docker exec -it toiapp-web-1 sh` - enter Next.js Docker container
- `docker exec -it toiapp-db-1 psql -U toi-user -d toi-db` - enter Postgres db

### System Management
- `sudo systemctl restart nginx` - restart nginx
- `sudo systemctl status nginx` - check nginx status
- `journalctl -xeu nginx.service` - view nginx error logs

### Database Management
- `npm run db:studio` - open Drizzle Studio (from ~/toiapp)
- `npm run db:generate` - generate new migrations
- `npm run db:push` - push schema changes

### Troubleshooting
```bash
# Check all container logs
docker-compose logs

# Check specific service health
docker-compose ps

# Test nginx configuration
sudo nginx -t

# Monitor system resources
top
df -h
free -h
```

## Other Resources

- [Kubernetes Example](https://github.com/ezeparziale/nextjs-k8s)
- [Redis Cache Adapter for Next.js](https://github.com/vercel/next.js/tree/canary/examples/cache-handler-redis)
- [ipx – Image optimization library](https://github.com/unjs/ipx)
- [OrbStack - Fast Docker desktop client](https://orbstack.dev/)

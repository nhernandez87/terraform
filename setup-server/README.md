# n8n Setup Script

This directory contains a script to set up n8n with PostgreSQL on your home server.

## Files

- `setup-n8n.sh` - Main setup script that creates docker-compose.yml and .env files

## Usage

1. Copy the setup-server directory to your server:
   ```bash
   scp -r setup-server server:~/setup-server
   ```

2. Run the setup script on the server:
   ```bash
   ssh server
   cd ~/setup-server
   bash setup-n8n.sh
   ```

3. The script will create:
   - `~/n8n/docker-compose.yml` - Docker Compose configuration
   - `~/n8n/.env` - Environment variables (with generated passwords)

4. Start the services:
   ```bash
   cd ~/n8n
   docker-compose up -d
   ```

5. Check the status:
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

6. Access n8n:
   - URL: `https://homeserver.nahuelhernandez.com:5678`
   - Username: `admin` (from .env file)
   - Password: Check the .env file for `N8N_PASSWORD`

## Managing Services

- **Start**: `docker-compose up -d`
- **Stop**: `docker-compose down`
- **Restart**: `docker-compose restart`
- **View logs**: `docker-compose logs -f`
- **View logs (specific service)**: `docker-compose logs -f n8n` or `docker-compose logs -f postgres`

## Configuration

All configuration is in the `.env` file in `~/n8n/`. Edit it to change:
- Database passwords
- n8n admin credentials
- Host settings

## Notes

- PostgreSQL is NOT exposed to the host (only accessible within Docker network)
- n8n is exposed on port 5678
- Data is persisted in Docker volumes
- Services restart automatically (unless-stopped policy)
- Memory limits: n8n (2GB max), PostgreSQL (512MB max)


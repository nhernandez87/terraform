# n8n with HTTPS Setup

This setup runs n8n behind a Caddy reverse proxy with automatic HTTPS/TLS certificates from Let's Encrypt.

## Architecture

- **Caddy**: Reverse proxy handling HTTPS (ports 80 and 443)
- **n8n**: Running internally on port 5678, accessible via HTTPS
- **SQLite**: Default database (no PostgreSQL required)
- **Domain**: `n8n.nahuelhernandez.com`

## Files

- `setup-n8n-https.sh` - Setup script that creates all necessary files
- `docker-compose.yml` - Docker Compose configuration
- `Caddyfile` - Caddy reverse proxy configuration
- `.env` - Environment variables (passwords, etc.)

## Quick Start

1. **Run the setup script:**
   ```bash
   ssh server
   cd ~/setup-server
   bash setup-n8n-https.sh
   ```

2. **Update the password in `.env`:**
   ```bash
   cd ~/n8n-https
   nano .env
   # Update N8N_PASSWORD
   ```

3. **Start the services:**
   ```bash
   cd ~/n8n-https
   docker-compose up -d
   ```

4. **Access n8n:**
   - URL: `https://n8n.nahuelhernandez.com`
   - Username: `admin` (from .env)
   - Password: Check `.env` file

## Verification

1. **Check services are running:**
   ```bash
   cd ~/n8n-https
   docker-compose ps
   ```

2. **Check Caddy logs (certificate acquisition):**
   ```bash
   docker-compose logs caddy
   ```

3. **Check n8n logs:**
   ```bash
   docker-compose logs n8n
   ```

4. **Test HTTPS access:**
   ```bash
   curl -I https://n8n.nahuelhernandez.com
   ```

## Environment Variables

The following n8n environment variables are configured:

- `N8N_HOST=n8n.nahuelhernandez.com`
- `N8N_PORT=5678`
- `N8N_PROTOCOL=https`
- `WEBHOOK_URL=https://n8n.nahuelhernandez.com/`

## Managing Services

- **Start**: `docker-compose up -d`
- **Stop**: `docker-compose down`
- **Restart**: `docker-compose restart`
- **View logs**: `docker-compose logs -f`
- **View logs (specific service)**: `docker-compose logs -f caddy` or `docker-compose logs -f n8n`

## TLS Certificates

Caddy automatically:
- Obtains TLS certificates from Let's Encrypt
- Renews certificates automatically
- Handles HTTP to HTTPS redirects
- Stores certificates in Docker volume `caddy_data`

## Data Persistence

- **n8n data**: Stored in Docker volume `n8n_data`
- **Caddy data**: Stored in Docker volume `caddy_data` (certificates, etc.)
- **Caddy config**: Stored in Docker volume `caddy_config`

## Notes

- n8n runs internally on port 5678 (not exposed to host)
- Only Caddy is exposed on ports 80 and 443
- SQLite is used by default (no PostgreSQL required)
- Telegram webhooks require HTTPS, which is now configured
- All data persists in Docker volumes


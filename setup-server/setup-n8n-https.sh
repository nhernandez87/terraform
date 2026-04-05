#!/bin/bash

# Script to setup n8n with Caddy reverse proxy and HTTPS
# This script creates the necessary files and starts the services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
N8N_DIR="$HOME/n8n-https"

echo "Setting up n8n with Caddy reverse proxy and HTTPS..."

# Create n8n directory
mkdir -p "$N8N_DIR"
cd "$N8N_DIR"

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  # PostgreSQL Database Service
  postgres:
    image: postgres:15-alpine
    container_name: n8n-https-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n-network
    mem_limit: 512m
    mem_reservation: 256m
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Caddy Reverse Proxy
  caddy:
    image: caddy:latest
    container_name: n8n-https-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - n8n-network

  # n8n Service
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-https
    restart: unless-stopped
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - WEBHOOK_URL=${WEBHOOK_URL}
      - NODE_ENV=production
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n-network
    mem_limit: 2g
    mem_reservation: 1g
    depends_on:
      postgres:
        condition: service_healthy
      caddy:
        condition: service_started

# Docker Volumes for Data Persistence
volumes:
  postgres_data:
    driver: local
  n8n_data:
    driver: local
  caddy_data:
    driver: local
  caddy_config:
    driver: local

# Private Docker Network
networks:
  n8n-network:
    driver: bridge
EOF

# Create Caddyfile
cat > Caddyfile << 'CADDYEOF'
n8n.nahuelhernandez.com {
    reverse_proxy n8n:5678
}
CADDYEOF

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    cat > .env << 'ENVEOF'
# PostgreSQL Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=change_me_secure_password_123
POSTGRES_DB=n8n

# n8n Configuration
N8N_USER=admin
N8N_PASSWORD=change_me_admin_password_123
N8N_HOST=n8n.nahuelhernandez.com
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.nahuelhernandez.com/
ENVEOF
    echo "Created .env file. Please update the password before starting!"
else
    echo ".env file already exists, skipping creation."
fi

# Set proper permissions
chmod 600 .env
chmod 644 docker-compose.yml
chmod 644 Caddyfile

echo ""
echo "Setup complete! Files created in: $N8N_DIR"
echo ""
echo "Next steps:"
echo "1. Edit .env file and update the password:"
echo "   cd $N8N_DIR"
echo "   nano .env"
echo ""
echo "2. Start the services:"
echo "   docker-compose up -d"
echo ""
echo "3. Check the logs:"
echo "   docker-compose logs -f"
echo ""
echo "4. Access n8n at: https://n8n.nahuelhernandez.com"
echo ""
echo "5. Stop the services:"
echo "   docker-compose down"


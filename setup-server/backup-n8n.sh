#!/bin/bash

# n8n Backup Script
# This script creates a backup of the n8n PostgreSQL database
# Keeps only the last 4 backups (weekly retention)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
N8N_DIR="$HOME/n8n"
BACKUP_DIR="$HOME/n8n-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting n8n backup at $(date)"

# Check if n8n containers are running
if ! docker-compose -f "$N8N_DIR/docker-compose.yml" ps postgres | grep -q "Up"; then
    echo "ERROR: PostgreSQL container is not running!"
    exit 1
fi

# Create backup
echo "Creating database backup..."
cd "$N8N_DIR"
docker-compose exec -T postgres pg_dump -U n8n n8n > "$BACKUP_FILE"

# Compress the backup
echo "Compressing backup..."
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Check if backup was created successfully
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file was not created!"
    exit 1
fi

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup created successfully: $BACKUP_FILE ($BACKUP_SIZE)"

# Keep only the last 4 backups
echo "Cleaning old backups (keeping last 4)..."
cd "$BACKUP_DIR"
ls -t n8n_backup_*.sql.gz 2>/dev/null | tail -n +5 | while read old_backup; do
    echo "Removing old backup: $old_backup"
    rm -f "$old_backup"
done

# List remaining backups
echo ""
echo "Remaining backups:"
ls -lh "$BACKUP_DIR"/n8n_backup_*.sql.gz 2>/dev/null | awk '{print $9, "(" $5 ")"}' || echo "No backups found"

echo ""
echo "Backup completed successfully at $(date)"


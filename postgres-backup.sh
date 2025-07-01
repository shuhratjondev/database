#!/bin/bash

# set variables
DB_HOST="localhost"                 # replace db_host
DB_PORT=5432                        # replace db_port
DB_NAME="db_name"                   # replace db_name
DB_USER="db_user"                   # replace db_user
DB_PASSWORD="db_password"           # replace db_password

DAILY_BACKUP_DIR="backup_path/by_days"
MONTHLY_BACKUP_DIR="backup_path/by_months"


DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H-%M-%S")
MONTH=$(date +"%Y-%m")

DAILY_BACKUP_SQL_FILE="$DAILY_BACKUP_DIR/backup_${DATE}_${TIME}.sql"
DAILY_BACKUP_FILE="$DAILY_BACKUP_SQL_FILE.gz"

# create backup folders
mkdir -p "$DAILY_BACKUP_DIR"
mkdir -p "$MONTHLY_BACKUP_DIR"

# set password with environment and create backup with gzip
PGPASSWORD="$DB_PASSWORD" pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" | gzip > "$DAILY_BACKUP_FILE"
echo "Daily backup created: $DAILY_BACKUP_FILE"

# set password with environment and create monthly backup with gzip
if [ "$(date +%d)" -eq 1 ]; then
    MONTHLY_BACKUP_FILE="$MONTHLY_BACKUP_DIR/backup_$MONTH.sql.gz"
    PGPASSWORD="$DB_PASSWORD" pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" | gzip > "$MONTHLY_BACKUP_FILE"
    echo "Monthly backup created: $MONTHLY_BACKUP_FILE"
fi

# unset password from RAM
unset PGPASSWORD
unset DB_PASSWORD

# delete old backup files
# delete daily backups older than 7 days
find "$DAILY_BACKUP_DIR" -type f -name "backup_*.sql.gz" -mtime +7 -delete
echo "3 kundan eski har kunlik backup fayllari o‘chirildi."

# delete monthly backups older than 3 months
find "$MONTHLY_BACKUP_DIR" -type f -name "backup_*.sql.gz" -mtime +90 -delete
echo "3 oydan eski har oylik backup fayllari o‘chirildi."

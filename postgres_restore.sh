#!/bin/bash

# set variables
DB_HOST="localhost"                 # replace db_host
DB_PORT=5432                        # replace db_port
DB_NAME="db_name"                   # replace db_name
DB_USER="db_user"                   # replace db_user
DB_PASSWORD="db_password"           # replace db_password

BACKUP_FILE="path/backup.sql.gz"    # replace backup file path

echo "drop old database"
PGPASSWORD="$DB_PASSWORD" dropdb -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" "$DB_NAME"

echo "create new database"
PGPASSWORD="$DB_PASSWORD" createdb -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" --owner="${DB_USER}" "$DB_NAME"

echo "backup restore begin"
gunzip -c "$BACKUP_FILE" | PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME"
echo "backup restore finished"

unset PGPASSWORD
unset DB_PASSWORD

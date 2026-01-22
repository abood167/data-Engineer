#!/bin/bash
set -e

DB_HOST="db"
DB_PORT="5432"
DB_USER="abin_saa"
DB_NAME="piscineds"
DB_PASS="mysecretpassword"

export PGPASSWORD="$DB_PASS"

echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
  sleep 2
done
echo "PostgreSQL is ready."

for csv_file in /customer/*.csv; do
  [ -e "$csv_file" ] || { echo "No CSV files found in /customer"; exit 0; }

  table_name=$(basename "$csv_file" .csv)

  # Safety: allow only letters, numbers, underscore
  if [[ ! "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Skipping invalid file name: $csv_file"
    continue
  fi

  echo "Importing $csv_file -> table $table_name"

  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS $table_name (
  event_time TIMESTAMP,
  event_type VARCHAR(50),
  product_id INTEGER,
  price DECIMAL(10,2),
  user_id BIGINT,
  user_session TEXT
);

\\copy $table_name FROM '$csv_file' WITH (FORMAT csv, HEADER true);
EOF

done

echo "All CSV files imported successfully."

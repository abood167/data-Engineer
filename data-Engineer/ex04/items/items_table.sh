#!/bin/bash
set -e

DB_HOST="db"
DB_PORT="5432"
DB_USER="abin_saa"
DB_NAME="piscineds"
DB_PASS="mysecretpassword"

export PGPASSWORD="$DB_PASS"

echo "Waiting for PostgreSQL..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
  sleep 2
done
echo "PostgreSQL is ready."

CSV="/items/items.csv"
if [ ! -f "$CSV" ]; then
  CSV="/items/item.csv"
fi

if [ ! -f "$CSV" ]; then
  echo "ERROR: items.csv (or item.csv) not found in /items"
  exit 1
fi

psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS items (
  product_id INTEGER,
  category_id BIGINT,
  category_code TEXT,
  brand TEXT
);

\\copy items FROM '$CSV' WITH (FORMAT csv, HEADER true, NULL '');
EOF

echo "Done importing items."

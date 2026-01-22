#!/bin/bash
set -e

PGPASSWORD=mysecretpassword psql -U abin-saa -d piscineds <<'EOF'
CREATE TABLE IF NOT EXISTS data_2022_oct (
  event_time TIMESTAMP,      -- DATETIME (لازم أول عمود)
  event_type VARCHAR(50),    -- نوع 1
  product_id INTEGER,        -- نوع 2
  price NUMERIC(10,2),       -- نوع 3
  user_id BIGINT,            -- نوع 4
  user_session TEXT          -- نوع 5
);

\copy data_2022_oct FROM '/customer/data_2022_oct.csv' WITH (FORMAT csv, HEADER true);
EOF

#!/usr/bin/env bash
# Initialize a real local database (SQLite by default)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_tools

if [[ "$DB_ENGINE" == "sqlite" ]]; then
  rm -f "$SQLITE_DB"
  ensure_sqlite_db
  COUNT="$(sql_exec "SELECT COUNT(*) FROM services;")"
  log OK "SQLite DB ready: $SQLITE_DB (services=$COUNT)"
  sqlite3 "$SQLITE_DB" ".tables"
  exit 0
fi

log INFO "Initializing MySQL database '$DB_NAME' on $DB_HOST:$DB_PORT"
# shellcheck disable=SC2086
eval mysql $(mysql_args) -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
# Convert minimal MySQL-friendly load from concept schema via inline SQL
# shellcheck disable=SC2086
eval mysql $(mysql_args) "$DB_NAME" <<'SQL'
CREATE TABLE IF NOT EXISTS services (
  service_id INT PRIMARY KEY AUTO_INCREMENT,
  service_name VARCHAR(100) NOT NULL,
  owner_team VARCHAR(100) NOT NULL,
  criticality VARCHAR(20) NOT NULL DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS incidents (
  incident_id INT PRIMARY KEY AUTO_INCREMENT,
  service_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  severity VARCHAR(5) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'open',
  opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMP NULL,
  FOREIGN KEY (service_id) REFERENCES services(service_id)
);
CREATE TABLE IF NOT EXISTS db_checks (
  check_id INT PRIMARY KEY AUTO_INCREMENT,
  check_name VARCHAR(100) NOT NULL,
  result VARCHAR(10) NOT NULL,
  checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes VARCHAR(255)
);
INSERT INTO services (service_name, owner_team, criticality)
SELECT 'citizen-portal', 'platform', 'high' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM services WHERE service_name='citizen-portal');
INSERT INTO services (service_name, owner_team, criticality)
SELECT 'billing-batch', 'data', 'medium' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM services WHERE service_name='billing-batch');
SQL
log OK "MySQL database '$DB_NAME' initialized"

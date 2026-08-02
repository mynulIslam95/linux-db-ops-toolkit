#!/usr/bin/env bash
# Availability and basic health check for MySQL/MariaDB on Linux
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_client
FAIL=0

log INFO "Starting health check (host=$DB_HOST port=$DB_PORT db=$DB_NAME mock=$MOCK_MODE)"

if [[ "$MOCK_MODE" == "1" ]]; then
  log OK "Mock: process check passed"
  log OK "Mock: port $DB_PORT reachable"
  log OK "Mock: SQL connectivity OK"
  log OK "Mock: database '$DB_NAME' exists"
  log INFO "Health check finished with exit code 0"
  exit 0
fi

# Process check (best effort on Linux/macOS)
if pgrep -x mysqld >/dev/null 2>&1 || pgrep -x mariadbd >/dev/null 2>&1; then
  log OK "Database process is running"
else
  log WARN "mysqld/mariadbd process not found (may still be remote)"
fi

# Port check
if command -v nc >/dev/null 2>&1; then
  if nc -z -w 2 "$DB_HOST" "$DB_PORT" >/dev/null 2>&1; then
    log OK "Port $DB_PORT is open on $DB_HOST"
  else
    log ERROR "Port $DB_PORT is not reachable on $DB_HOST"
    FAIL=1
  fi
fi

# SQL connectivity
# shellcheck disable=SC2046
if mysql $(mysql_base) -e "SELECT 1;" >/dev/null 2>&1; then
  log OK "SQL connectivity OK"
else
  log ERROR "SQL connectivity failed"
  FAIL=1
fi

# Database exists
# shellcheck disable=SC2046
if mysql $(mysql_base) -e "USE \`$DB_NAME\`;" >/dev/null 2>&1; then
  log OK "Database '$DB_NAME' is accessible"
else
  log ERROR "Database '$DB_NAME' is not accessible"
  FAIL=1
fi

# Simple status snapshot
# shellcheck disable=SC2046
mysql $(mysql_base) -N -e "SHOW STATUS WHERE Variable_name IN ('Threads_connected','Uptime','Questions');" 2>/dev/null \
  | while read -r name value; do log INFO "status $name=$value"; done || true

if [[ "$FAIL" -eq 0 ]]; then
  log INFO "Health check finished with exit code 0"
  exit 0
fi
log ERROR "Health check finished with exit code 1"
exit 1

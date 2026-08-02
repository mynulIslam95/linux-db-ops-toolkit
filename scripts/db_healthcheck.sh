#!/usr/bin/env bash
# Health check against a real database
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_tools
FAIL=0
log INFO "Health check start (engine=$DB_ENGINE)"

if [[ "$DB_ENGINE" == "sqlite" ]]; then
  ensure_sqlite_db
  if [[ -f "$SQLITE_DB" ]]; then
    log OK "Database file exists: $SQLITE_DB"
  else
    log ERROR "Database file missing"; FAIL=1
  fi

  if sql_exec "SELECT 1;" >/dev/null; then
    log OK "SQL connectivity OK"
  else
    log ERROR "SQL connectivity failed"; FAIL=1
  fi

  TABLES="$(sql_exec ".tables" 2>/dev/null || sql_exec "SELECT name FROM sqlite_master WHERE type='table';")"
  log INFO "Tables: $TABLES"

  SERVICES="$(sql_exec "SELECT COUNT(*) FROM services;")"
  OPEN_INC="$(sql_exec "SELECT COUNT(*) FROM incidents WHERE status='open';")"
  log INFO "services=$SERVICES open_incidents=$OPEN_INC"

  sql_exec "INSERT INTO db_checks (check_name, result, notes) VALUES ('healthcheck', 'OK', 'automated run');" >/dev/null
  log OK "Wrote healthcheck row into db_checks"
else
  # shellcheck disable=SC2086
  if eval mysql $(mysql_args) -e "SELECT 1;" >/dev/null 2>&1; then
    log OK "SQL connectivity OK"
  else
    log ERROR "SQL connectivity failed"; FAIL=1
  fi
  # shellcheck disable=SC2086
  if eval mysql $(mysql_args) -e "USE \`$DB_NAME\`;" >/dev/null 2>&1; then
    log OK "Database '$DB_NAME' accessible"
  else
    log ERROR "Database '$DB_NAME' not accessible"; FAIL=1
  fi
fi

if [[ "$FAIL" -eq 0 ]]; then
  log INFO "Health check finished with exit code 0"
  exit 0
fi
log ERROR "Health check finished with exit code 1"
exit 1

#!/usr/bin/env bash
# Daily ops report using real DB counts + local backup inventory
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_tools
REPORT="$LOG_DIR/daily_ops_report_$(date '+%Y%m%d').txt"
BACKUP_COUNT="$(find "$BACKUP_DIR" -type f -name '*.sql' 2>/dev/null | wc -l | tr -d ' ')"
LAST_BACKUP="$(ls -t "$BACKUP_DIR"/*.sql 2>/dev/null | head -1 || true)"

if [[ "$DB_ENGINE" == "sqlite" ]]; then
  ensure_sqlite_db
  SERVICES="$(sql_exec "SELECT COUNT(*) FROM services;")"
  OPEN_INC="$(sql_exec "SELECT COUNT(*) FROM incidents WHERE status='open';")"
  CHECKS="$(sql_exec "SELECT COUNT(*) FROM db_checks;")"
  DB_LABEL="$SQLITE_DB"
else
  SERVICES="n/a"
  OPEN_INC="n/a"
  CHECKS="n/a"
  DB_LABEL="$DB_NAME@$DB_HOST:$DB_PORT"
fi

{
  echo "Linux DB Ops Daily Report"
  echo "Generated: $(ts)"
  echo "Engine: $DB_ENGINE"
  echo "Database: $DB_LABEL"
  echo
  echo "services: $SERVICES"
  echo "open_incidents: $OPEN_INC"
  echo "db_checks_logged: $CHECKS"
  echo "backup_files: $BACKUP_COUNT"
  echo "latest_backup: ${LAST_BACKUP:-none}"
  echo
  echo "Recommended next checks:"
  echo "1. Run ./scripts/db_healthcheck.sh"
  echo "2. Validate latest backup with db_restore_dryrun.sh"
  echo "3. Review open incidents in the database"
} > "$REPORT"

log OK "Report written: $REPORT"
cat "$REPORT"

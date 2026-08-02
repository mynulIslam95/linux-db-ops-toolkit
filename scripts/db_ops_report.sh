#!/usr/bin/env bash
# Short daily operations summary from local logs/backups
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

REPORT="$LOG_DIR/daily_ops_report_$(date '+%Y%m%d').txt"
BACKUP_COUNT="$(find "$BACKUP_DIR" -type f -name '*.sql' 2>/dev/null | wc -l | tr -d ' ')"
LAST_BACKUP="$(ls -t "$BACKUP_DIR"/*.sql 2>/dev/null | head -1 || true)"
METRIC_LINES="$(wc -l < "$LOG_DIR/db_metrics.log" 2>/dev/null | tr -d ' ' || echo 0)"

{
  echo "Linux DB Ops Daily Report"
  echo "Generated: $(ts)"
  echo "Database: $DB_NAME @ $DB_HOST:$DB_PORT"
  echo "Mock mode: $MOCK_MODE"
  echo
  echo "Backup files available: $BACKUP_COUNT"
  echo "Latest backup: ${LAST_BACKUP:-none}"
  echo "Metric log lines: ${METRIC_LINES:-0}"
  echo
  echo "Recommended next checks:"
  echo "1. Run healthcheck and confirm exit code 0"
  echo "2. Validate latest backup with restore dry-run"
  echo "3. Review open incidents / capacity notes"
} > "$REPORT"

log OK "Report written: $REPORT"
cat "$REPORT"

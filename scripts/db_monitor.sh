#!/usr/bin/env bash
# Collect metrics from the real database into a log file
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_tools
METRIC_LOG="$LOG_DIR/db_metrics.log"
log INFO "Collecting metrics into $METRIC_LOG"

if [[ "$DB_ENGINE" == "sqlite" ]]; then
  ensure_sqlite_db
  SERVICES="$(sql_exec "SELECT COUNT(*) FROM services;")"
  OPEN_INC="$(sql_exec "SELECT COUNT(*) FROM incidents WHERE status='open';")"
  CHECKS="$(sql_exec "SELECT COUNT(*) FROM db_checks;")"
  SIZE_BYTES="$(wc -c < "$SQLITE_DB" | tr -d ' ')"
  {
    echo "timestamp=$(ts)"
    echo "engine=sqlite"
    echo "db_path=$SQLITE_DB"
    echo "status=UP"
    echo "services=$SERVICES"
    echo "open_incidents=$OPEN_INC"
    echo "db_checks=$CHECKS"
    echo "db_size_bytes=$SIZE_BYTES"
    echo "---"
  } >> "$METRIC_LOG"
  sql_exec "INSERT INTO db_checks (check_name, result, notes) VALUES ('monitor', 'OK', 'services=$SERVICES open=$OPEN_INC');" >/dev/null
  log OK "Metrics from real SQLite DB (services=$SERVICES open_incidents=$OPEN_INC size=$SIZE_BYTES)"
else
  # shellcheck disable=SC2086
  THREADS="$(eval mysql $(mysql_args) -N -e "SHOW STATUS LIKE 'Threads_connected';" | awk '{print $2}')"
  # shellcheck disable=SC2086
  SIZE_MB="$(eval mysql $(mysql_args) -N -e "SELECT ROUND(SUM(data_length+index_length)/1024/1024,2) FROM information_schema.tables WHERE table_schema='$DB_NAME';")"
  {
    echo "timestamp=$(ts)"
    echo "engine=mysql"
    echo "db=$DB_NAME"
    echo "status=UP"
    echo "threads_connected=${THREADS:-n/a}"
    echo "data_length_mb=${SIZE_MB:-n/a}"
    echo "---"
  } >> "$METRIC_LOG"
  log OK "Metrics from MySQL (threads=${THREADS:-n/a}, size_mb=${SIZE_MB:-n/a})"
fi
exit 0

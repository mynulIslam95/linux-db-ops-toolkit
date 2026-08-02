#!/usr/bin/env bash
# Collect simple availability / size metrics into a log file
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_client
METRIC_LOG="$LOG_DIR/db_metrics.log"

log INFO "Collecting metrics into $METRIC_LOG"

if [[ "$MOCK_MODE" == "1" ]]; then
  {
    echo "timestamp=$(ts)"
    echo "host=$DB_HOST"
    echo "db=$DB_NAME"
    echo "status=UP"
    echo "threads_connected=3"
    echo "data_length_mb=12.4"
    echo "uptime_sec=86400"
  } >> "$METRIC_LOG"
  log OK "Mock metrics appended"
  exit 0
fi

# shellcheck disable=SC2046
THREADS="$(mysql $(mysql_base) -N -e "SHOW STATUS LIKE 'Threads_connected';" | awk '{print $2}')"
# shellcheck disable=SC2046
UPTIME="$(mysql $(mysql_base) -N -e "SHOW STATUS LIKE 'Uptime';" | awk '{print $2}')"
# shellcheck disable=SC2046
SIZE_MB="$(mysql $(mysql_base) -N -e "SELECT ROUND(SUM(data_length+index_length)/1024/1024,2) FROM information_schema.tables WHERE table_schema='$DB_NAME';")"

{
  echo "timestamp=$(ts)"
  echo "host=$DB_HOST"
  echo "db=$DB_NAME"
  echo "status=UP"
  echo "threads_connected=${THREADS:-n/a}"
  echo "data_length_mb=${SIZE_MB:-n/a}"
  echo "uptime_sec=${UPTIME:-n/a}"
  echo "---"
} >> "$METRIC_LOG"

log OK "Metrics appended (threads=${THREADS:-n/a}, size_mb=${SIZE_MB:-n/a})"
exit 0

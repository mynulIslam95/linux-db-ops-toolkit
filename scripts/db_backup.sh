#!/usr/bin/env bash
# Logical backup of the real database
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

require_tools
STAMP="$(date '+%Y%m%d_%H%M%S')"

if [[ "$DB_ENGINE" == "sqlite" ]]; then
  ensure_sqlite_db
  OUT_FILE="$BACKUP_DIR/ops_lab_${STAMP}.sql"
  log INFO "Backing up SQLite DB $SQLITE_DB -> $OUT_FILE"
  sqlite3 "$SQLITE_DB" .dump > "$OUT_FILE"
else
  OUT_FILE="$BACKUP_DIR/${DB_NAME}_${STAMP}.sql"
  log INFO "Backing up MySQL DB $DB_NAME -> $OUT_FILE"
  # shellcheck disable=SC2086
  eval mysqldump $(mysql_args) --single-transaction --routines --triggers --databases "$DB_NAME" > "$OUT_FILE"
fi

BYTES="$(wc -c < "$OUT_FILE" | tr -d ' ')"
if [[ "$BYTES" -lt 50 ]]; then
  log ERROR "Backup looks empty ($BYTES bytes)"
  exit 1
fi
log OK "Backup complete: $OUT_FILE ($BYTES bytes)"
echo "$OUT_FILE"

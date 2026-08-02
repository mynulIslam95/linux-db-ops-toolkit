#!/usr/bin/env bash
# Validate a SQL dump without restoring over the live DB
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

BACKUP_FILE="${1:-}"
if [[ -z "$BACKUP_FILE" ]]; then
  log ERROR "Usage: $0 <backup.sql>"
  exit 2
fi
if [[ ! -f "$BACKUP_FILE" ]]; then
  log ERROR "Backup file not found: $BACKUP_FILE"
  exit 1
fi

BYTES="$(wc -c < "$BACKUP_FILE" | tr -d ' ')"
log INFO "Dry-run validate: $BACKUP_FILE ($BYTES bytes)"

if ! grep -Eqi 'CREATE TABLE|INSERT INTO|BEGIN TRANSACTION|PRAGMA' "$BACKUP_FILE"; then
  log ERROR "Backup does not look like a SQL dump"
  exit 1
fi

# Restore into a temporary SQLite DB to prove the dump is loadable
TMP_DB="$(mktemp /tmp/ops_lab_restore_XXXXXX.db)"
trap 'rm -f "$TMP_DB"' EXIT

if sqlite3 "$TMP_DB" < "$BACKUP_FILE"; then
  TABLES="$(sqlite3 "$TMP_DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';")"
  log OK "Dump loaded into temp DB successfully (tables=$TABLES)"
else
  log ERROR "Dump failed to load into temp DB"
  exit 1
fi

log OK "Dry-run validation passed (live DB not modified)"
exit 0

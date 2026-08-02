#!/usr/bin/env bash
# Validate a logical backup without applying it to production
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

if [[ "$BYTES" -lt 20 ]]; then
  log ERROR "File too small to be a valid dump"
  exit 1
fi

# Basic content checks for mysqldump-style files
if grep -Eqi 'CREATE TABLE|INSERT INTO|-- Dump|-- Mock' "$BACKUP_FILE"; then
  log OK "Backup contains expected SQL markers"
else
  log ERROR "Backup does not look like a SQL dump"
  exit 1
fi

# Count statements (rough)
TABLES="$(grep -cEi '^CREATE TABLE' "$BACKUP_FILE" || true)"
INSERTS="$(grep -cEi '^INSERT INTO' "$BACKUP_FILE" || true)"
log INFO "Detected CREATE TABLE statements: $TABLES"
log INFO "Detected INSERT statements: $INSERTS"
log OK "Dry-run validation passed (no restore applied)"
exit 0

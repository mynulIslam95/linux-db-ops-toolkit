#!/usr/bin/env bash
# Shared helpers for Linux DB Ops Toolkit
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
MOCK_MODE="${DB_OPS_MOCK:-0}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_NAME="${DB_NAME:-ops_lab}"
DB_PASSWORD="${DB_PASSWORD:-}"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
  local level="$1"; shift
  echo "[$(ts)] [$level] $*"
}

mysql_base() {
  local args=(-h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER")
  if [[ -n "$DB_PASSWORD" ]]; then
    args+=(-p"$DB_PASSWORD")
  fi
  echo "${args[@]}"
}

require_client() {
  if [[ "$MOCK_MODE" == "1" ]]; then
    return 0
  fi
  command -v mysql >/dev/null 2>&1 || { log ERROR "mysql client not found"; exit 2; }
  command -v mysqldump >/dev/null 2>&1 || { log ERROR "mysqldump not found"; exit 2; }
}

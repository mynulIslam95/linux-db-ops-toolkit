#!/usr/bin/env bash
# Shared helpers — default engine is a real SQLite database
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
DATA_DIR="${DATA_DIR:-$ROOT_DIR/data}"

# sqlite (default) | mysql
DB_ENGINE="${DB_ENGINE:-sqlite}"
SQLITE_DB="${SQLITE_DB:-$DATA_DIR/ops_lab.db}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_NAME="${DB_NAME:-ops_lab}"
DB_PASSWORD="${DB_PASSWORD:-}"

mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$DATA_DIR"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
  local level="$1"; shift
  echo "[$(ts)] [$level] $*"
}

require_tools() {
  if [[ "$DB_ENGINE" == "sqlite" ]]; then
    command -v sqlite3 >/dev/null 2>&1 || { log ERROR "sqlite3 not found"; exit 2; }
  elif [[ "$DB_ENGINE" == "mysql" ]]; then
    command -v mysql >/dev/null 2>&1 || { log ERROR "mysql client not found"; exit 2; }
    command -v mysqldump >/dev/null 2>&1 || { log ERROR "mysqldump not found"; exit 2; }
  else
    log ERROR "Unsupported DB_ENGINE='$DB_ENGINE' (use sqlite or mysql)"
    exit 2
  fi
}

mysql_args() {
  local args=(-h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER")
  if [[ -n "$DB_PASSWORD" ]]; then
    args+=(-p"$DB_PASSWORD")
  fi
  printf '%q ' "${args[@]}"
}

ensure_sqlite_db() {
  if [[ ! -f "$SQLITE_DB" ]]; then
    log INFO "Creating SQLite database: $SQLITE_DB"
    sqlite3 "$SQLITE_DB" < "$ROOT_DIR/sql/01_schema.sql"
  fi
}

sql_exec() {
  local sql="$1"
  if [[ "$DB_ENGINE" == "sqlite" ]]; then
    ensure_sqlite_db
    sqlite3 "$SQLITE_DB" "$sql"
  else
    # shellcheck disable=SC2086
    eval mysql $(mysql_args) -N -e "$sql"
  fi
}

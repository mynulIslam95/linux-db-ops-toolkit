# Linux DB Ops Toolkit

Shell-based operations toolkit for **MySQL / MariaDB on Linux**.

Built to practice the day-to-day work of a junior database / Linux operator:
health checks, backup, restore dry-run, simple monitoring, and operational documentation.

## What it does

| Script | Purpose |
|--------|---------|
| `scripts/db_healthcheck.sh` | Checks DB process, port, connectivity, and basic status |
| `scripts/db_backup.sh` | Creates a timestamped logical backup (`mysqldump`) |
| `scripts/db_restore_dryrun.sh` | Validates a backup file without applying it |
| `scripts/db_monitor.sh` | Collects simple availability / size metrics into a log |
| `scripts/db_ops_report.sh` | Writes a short daily ops summary |

## Requirements

- Linux or macOS with Bash
- MySQL or MariaDB client tools (`mysql`, `mysqldump`)
- Optional: a local MySQL/MariaDB instance for live tests

## Quick start (safe / offline)

Scripts support a **mock mode** so you can demo without a real database:

```bash
export DB_OPS_MOCK=1
./scripts/db_healthcheck.sh
./scripts/db_backup.sh
./scripts/db_restore_dryrun.sh ./backups/mock_demo.sql
./scripts/db_monitor.sh
./scripts/db_ops_report.sh
```

## Live mode (local DB)

```bash
export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_USER=root
export DB_NAME=ops_lab
# export DB_PASSWORD=...   # prefer ~/.my.cnf in real use
./scripts/db_healthcheck.sh
./scripts/db_backup.sh
```

## Project layout

```
scripts/     operational Bash scripts
sql/         sample schema for a small ops lab database
docs/        runbooks (backup, incident, failover checklist)
examples/    sample output
```

## Learning focus (maps to DBA work)

- Availability checks and clear exit codes
- Backup / restore discipline
- Shell automation for recurring ops tasks
- Short runbooks for incidents and failover tests
- Logging and ops reporting

## Notes

This is a **learning / portfolio project**, not a production Dataport deployment.
It demonstrates Linux + shell automation + relational DB operations habits.

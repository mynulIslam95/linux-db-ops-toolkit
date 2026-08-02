# Linux DB Ops Toolkit

Shell-based operations toolkit that works against a **real relational database**.

Default engine: **SQLite** (`data/ops_lab.db`)  
Optional engine: **MySQL / MariaDB** (`DB_ENGINE=mysql`)

## What it does

| Script | Purpose |
|--------|---------|
| `scripts/db_init.sh` | Creates the real DB + schema + sample rows |
| `scripts/db_healthcheck.sh` | SQL connectivity + table/row checks |
| `scripts/db_backup.sh` | Logical dump of the live DB |
| `scripts/db_restore_dryrun.sh` | Loads dump into a temp DB to prove restore works |
| `scripts/db_monitor.sh` | Reads live metrics and writes `db_checks` rows |
| `scripts/db_ops_report.sh` | Daily ops summary from DB + backups |

## Quick start (real SQLite DB)

```bash
chmod +x scripts/*.sh
./scripts/db_init.sh
./scripts/db_healthcheck.sh
./scripts/db_backup.sh
./scripts/db_restore_dryrun.sh backups/*.sql
./scripts/db_monitor.sh
./scripts/db_ops_report.sh

# Inspect the real database
sqlite3 data/ops_lab.db "SELECT * FROM services;"
sqlite3 data/ops_lab.db "SELECT * FROM incidents;"
sqlite3 data/ops_lab.db "SELECT * FROM db_checks;"
```

## Optional: MySQL / MariaDB

If you have a local MySQL server and credentials:

```bash
export DB_ENGINE=mysql
export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD='your-password'
export DB_NAME=ops_lab
./scripts/db_init.sh
./scripts/db_healthcheck.sh
```

## Project layout

```
data/        live SQLite database (created by db_init)
sql/         schema + seed data
scripts/     operational Bash scripts
docs/        backup / incident / failover runbooks
backups/     logical dumps
logs/        metrics + daily reports
```

## Learning focus

- Real DB init, SQL checks, backup/restore validation
- Linux shell automation around database operations
- Short Betriebs-/DR documentation for availability work

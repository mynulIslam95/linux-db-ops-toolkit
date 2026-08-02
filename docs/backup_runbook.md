# Backup Runbook

## Goal
Create a consistent logical backup and prove it can be validated.

## Steps
1. Confirm database is reachable: `./scripts/db_healthcheck.sh`
2. Create backup: `./scripts/db_backup.sh`
3. Validate dump file: `./scripts/db_restore_dryrun.sh <backup.sql>`
4. Store backup path and size in the daily ops report

## Acceptance criteria
- Healthcheck exit code `0`
- Backup file > 0 bytes and contains SQL markers
- Dry-run validation passes

## Notes
- Prefer `--single-transaction` for InnoDB consistency
- In production, also define retention and off-host copy

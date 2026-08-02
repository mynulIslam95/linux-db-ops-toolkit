# Incident Runbook (DB unavailable / degraded)

## Symptoms
- Application timeouts
- Healthcheck fails on connectivity or process
- Sudden spike in threads / connection errors

## First actions (15 minutes)
1. Run `./scripts/db_healthcheck.sh` and capture output
2. Check host load, disk space, and DB process
3. Confirm latest successful backup exists
4. Open / update incident ticket with timestamp and impact

## Escalation data to collect
- Exact error messages
- Healthcheck exit code
- Last good backup path and time
- Whether issue is host, network, credentials, or SQL layer

## Recovery options (decision tree)
- Restart DB service only if approved and safe
- Fail over only after checklist in `failover_checklist.md`
- Restore only from validated backup and only to approved target

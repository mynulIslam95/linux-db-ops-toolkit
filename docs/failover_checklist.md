# Failover / Disaster Recovery Checklist (Lab)

Use this as a practice checklist for DR tests (not a production Dataport procedure).

## Before test
- [ ] Document primary and standby roles
- [ ] Confirm latest validated backup
- [ ] Freeze non-critical changes
- [ ] Inform stakeholders of test window

## During test
- [ ] Stop or isolate primary (lab only)
- [ ] Promote / activate standby according to agreed plan
- [ ] Run application smoke checks
- [ ] Run DB healthcheck on new primary
- [ ] Record RTO / RPO observations

## After test
- [ ] Fail back or leave in new state (as planned)
- [ ] Write short test report (what worked / what failed)
- [ ] Update runbooks and scripts if gaps were found

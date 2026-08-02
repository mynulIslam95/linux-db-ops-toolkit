-- Real relational schema for the ops lab (SQLite default; also works as MySQL concept model)
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS services (
  service_id INTEGER PRIMARY KEY AUTOINCREMENT,
  service_name TEXT NOT NULL,
  owner_team TEXT NOT NULL,
  criticality TEXT NOT NULL DEFAULT 'medium',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS incidents (
  incident_id INTEGER PRIMARY KEY AUTOINCREMENT,
  service_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  severity TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  opened_at TEXT DEFAULT CURRENT_TIMESTAMP,
  closed_at TEXT,
  FOREIGN KEY (service_id) REFERENCES services(service_id)
);

CREATE TABLE IF NOT EXISTS db_checks (
  check_id INTEGER PRIMARY KEY AUTOINCREMENT,
  check_name TEXT NOT NULL,
  result TEXT NOT NULL,
  checked_at TEXT DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);

INSERT INTO services (service_name, owner_team, criticality)
SELECT 'citizen-portal', 'platform', 'high'
WHERE NOT EXISTS (SELECT 1 FROM services WHERE service_name = 'citizen-portal');

INSERT INTO services (service_name, owner_team, criticality)
SELECT 'billing-batch', 'data', 'medium'
WHERE NOT EXISTS (SELECT 1 FROM services WHERE service_name = 'billing-batch');

INSERT INTO incidents (service_id, title, severity, status)
SELECT s.service_id, 'Disk usage warning on reporting volume', 'P3', 'open'
FROM services s
WHERE s.service_name = 'billing-batch'
  AND NOT EXISTS (SELECT 1 FROM incidents WHERE title LIKE 'Disk usage warning%');

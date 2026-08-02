-- Sample ops lab schema (MySQL / MariaDB)
CREATE DATABASE IF NOT EXISTS ops_lab;
USE ops_lab;

CREATE TABLE IF NOT EXISTS services (
  service_id INT PRIMARY KEY AUTO_INCREMENT,
  service_name VARCHAR(100) NOT NULL,
  owner_team VARCHAR(100) NOT NULL,
  criticality ENUM('low','medium','high') NOT NULL DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS incidents (
  incident_id INT PRIMARY KEY AUTO_INCREMENT,
  service_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  severity ENUM('P1','P2','P3','P4') NOT NULL,
  status ENUM('open','in_progress','resolved') NOT NULL DEFAULT 'open',
  opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMP NULL,
  CONSTRAINT fk_inc_service FOREIGN KEY (service_id) REFERENCES services(service_id)
);

CREATE TABLE IF NOT EXISTS db_checks (
  check_id INT PRIMARY KEY AUTO_INCREMENT,
  check_name VARCHAR(100) NOT NULL,
  result ENUM('OK','WARN','FAIL') NOT NULL,
  checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes VARCHAR(255)
);

INSERT INTO services (service_name, owner_team, criticality) VALUES
('citizen-portal', 'platform', 'high'),
('billing-batch', 'data', 'medium');

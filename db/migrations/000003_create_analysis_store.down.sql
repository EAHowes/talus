-- 000003_create_analysis_store.down.sql
-- Reverses 000003_create_analysis_store.up.sql

DROP TABLE IF EXISTS alert_events;
DROP TABLE IF EXISTS alert_configs;
DROP TABLE IF EXISTS freeze_thaw_windows;
DROP TABLE IF EXISTS route_risk_assessments;

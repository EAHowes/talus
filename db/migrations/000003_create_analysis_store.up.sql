-- 000003_create_analysis_store.up.sql
-- Creates the tables Service 4 (Hazard Analysis and Alerts) writes to.

-- Prototype version. Contain Monte Carlo for later integration with the full project
CREATE TABLE route_risk_assessments (
    id                    SERIAL PRIMARY KEY,
    route_id              INTEGER REFERENCES routes(id),
    source_zone_id        INTEGER REFERENCES source_zones(id),
    nearest_source_m      FLOAT NOT NULL,
    exposed_length_m      FLOAT, 				-- NULL until Monte Carlo corridors exist
    max_passage_prob      FLOAT, 				-- NULL until Monte Carlo simulation exists
    intersection_geom     GEOMETRY(MULTILINESTRING, 4326), 	-- NULL until Monte Carlo simulation exists
    risk_score            FLOAT NOT NULL, 			-- proximity_weight x slope_weight x freeze_thaw_multiplier
    assessed_at           TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE freeze_thaw_windows (
    id                  SERIAL PRIMARY KEY,
    source_zone_id      INTEGER REFERENCES source_zones(id),
    forecast_date       DATE NOT NULL,
    overnight_low_c     FLOAT NOT NULL,
    sun_exposure_time   TIME NOT NULL,
    freeze_thaw_active  BOOLEAN NOT NULL,
    risk_level          VARCHAR(20) NOT NULL -- low/moderate/high/extreme
);

CREATE TABLE alert_configs (
    id              SERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    route_id        INTEGER REFERENCES routes(id),
    risk_threshold  FLOAT NOT NULL,
    freeze_thaw_trigger BOOLEAN DEFAULT TRUE,
    webhook_url     TEXT NOT NULL DEFAULT '',
    enabled         BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE alert_events (
    id              SERIAL PRIMARY KEY,
    config_id       INTEGER REFERENCES alert_configs(id),
    route_id        INTEGER REFERENCES routes(id),
    triggered_at    TIMESTAMPTZ DEFAULT NOW(),
    risk_score      FLOAT NOT NULL,
    summary         TEXT NOT NULL,
    freeze_thaw_active BOOLEAN NOT NULL
);

-- Spatial index for the prototype's intersection geometry column.
CREATE INDEX idx_route_risk_assessments_intersection_geom
    ON route_risk_assessments USING GIST (intersection_geom);

-- Foreign key lookup indexes for common access
CREATE INDEX idx_route_risk_assessments_route_id ON route_risk_assessments (route_id);
CREATE INDEX idx_route_risk_assessments_source_zone_id ON route_risk_assessments (source_zone_id);
CREATE INDEX idx_freeze_thaw_windows_source_zone_id ON freeze_thaw_windows (source_zone_id);
CREATE INDEX idx_alert_configs_route_id ON alert_configs (route_id);
CREATE INDEX idx_alert_events_config_id ON alert_events (config_id);
CREATE INDEX idx_alert_events_route_id ON alert_events (route_id);

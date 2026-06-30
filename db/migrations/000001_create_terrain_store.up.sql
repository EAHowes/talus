-- 000001_create_terrain_store.up.sql
-- Creates the tables Service 1 (DEM Ingestion) writes to.
-- Requires the PostGIS extension to be enabled on this database.

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE dem_tiles (
    id              SERIAL PRIMARY KEY,
    filename        TEXT NOT NULL,
    bounding_box    GEOMETRY(POLYGON, 4326) NOT NULL,
    crs             VARCHAR(40) NOT NULL,
    resolution_m    FLOAT NOT NULL,
    rows            INTEGER NOT NULL,
    cols            INTEGER NOT NULL,
    file_path       TEXT NOT NULL,
    source          VARCHAR(40) NOT NULL,
    ingested_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE geology (
    id              SERIAL PRIMARY KEY,
    dem_tile_id     INTEGER REFERENCES dem_tiles(id),
    geometry        GEOMETRY(MULTIPOLYGON, 4326) NOT NULL,
    rock_type       VARCHAR(80) NOT NULL,
    bounce_coeff    FLOAT NOT NULL,
    friction_coeff  FLOAT NOT NULL,
    fragmentation_k FLOAT NOT NULL
);

CREATE TABLE routes (
    id              SERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    geometry        GEOMETRY(LINESTRING, 4326) NOT NULL,
    source          VARCHAR(40),
    uploaded_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial indexes — these are what make ST_Intersects / ST_DWithin / ST_Distance
-- queries against these geometries fast instead of doing a full table scan.
CREATE INDEX idx_dem_tiles_bounding_box ON dem_tiles USING GIST (bounding_box);
CREATE INDEX idx_geology_geometry ON geology USING GIST (geometry);
CREATE INDEX idx_routes_geometry ON routes USING GIST (geometry);

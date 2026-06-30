-- 000002_create_derivative_store.up.sql
-- Creates the tables Service 2 (GPU Terrain Preprocessing) writes to,
-- Tables are used after the CUDA binary returns slope/aspect/curvature/TRI rasters.

CREATE TABLE terrain_derivatives (
    id              SERIAL PRIMARY KEY,
    dem_tile_id     INTEGER REFERENCES dem_tiles(id),
    slope_path      TEXT NOT NULL,
    aspect_path     TEXT NOT NULL,
    curvature_path  TEXT NOT NULL,
    tri_path        TEXT NOT NULL,
    computed_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE source_zones (
    id              SERIAL PRIMARY KEY,
    dem_tile_id     INTEGER REFERENCES dem_tiles(id),
    geometry        GEOMETRY(POLYGON, 4326) NOT NULL,
    centroid        GEOMETRY(POINT, 4326) NOT NULL,
    mean_slope_deg  FLOAT NOT NULL,
    mean_aspect_deg FLOAT NOT NULL,
    area_m2         FLOAT NOT NULL,
    geology_id      INTEGER REFERENCES geology(id)
);

CREATE TABLE terrain_metrics (
    id              SERIAL PRIMARY KEY,
    dem_tile_id     INTEGER REFERENCES dem_tiles(id),
    kernel_name     VARCHAR(80) NOT NULL,
    cells_processed BIGINT NOT NULL,
    gpu_time_ms     FLOAT NOT NULL,
    cpu_time_ms     FLOAT NOT NULL,
    throughput_mcps FLOAT NOT NULL,
    recorded_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial indexes for source_zones queried heavily by Service 4
-- (ST_DWithin against route geometry) and later by hazard corridor logic.
CREATE INDEX idx_source_zones_geometry ON source_zones USING GIST (geometry);
CREATE INDEX idx_source_zones_centroid ON source_zones USING GIST (centroid);

-- Non-spatial indexes that support common lookup patterns.
CREATE INDEX idx_terrain_derivatives_dem_tile_id ON terrain_derivatives (dem_tile_id);
CREATE INDEX idx_source_zones_dem_tile_id ON source_zones (dem_tile_id);
CREATE INDEX idx_terrain_metrics_dem_tile_id ON terrain_metrics (dem_tile_id);

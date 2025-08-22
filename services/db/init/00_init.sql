CREATE TABLE IF NOT EXISTS devices (
  id TEXT PRIMARY KEY,
  name TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS telemetry (
  id BIGSERIAL PRIMARY KEY,
  device_id TEXT REFERENCES devices(id),
  ts TIMESTAMP DEFAULT now(),
  payload JSONB
);

CREATE INDEX IF NOT EXISTS telemetry_device_ts_idx ON telemetry(device_id, ts DESC);

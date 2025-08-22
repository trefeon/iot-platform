# Secure IoT + CPS Platform (Starter)

End-to-end template: ESP32 → MQTT → FastAPI → Postgres → Grafana, with Nginx reverse proxy.

## Quick start (dev)
1. Copy `.env.example` to `.env` and fill values.
2. `docker compose up -d`
3. Open API docs: http://localhost:8080/docs
4. Flash ESP32 firmware from `firmware/esp32` (PlatformIO) and watch it publish telemetry.
5. Open Grafana: http://localhost:3000 (user/pass in `.env`).

## Production notes
- Put Nginx behind a domain, enable TLS, and move MQTT to 8883 (TLS). 
- Create per-device credentials and ACLs (see `services/broker/aclfile`).
- Add TimescaleDB extension for efficient time-series.
- Add CI/CD (GitHub Actions) and secrets management (sops/age).

## Useful endpoints
- `POST /api/devices/register` — create device entry and (optionally) MQTT creds
- `POST /api/telemetry/{device_id}` — ingest telemetry (alternative to MQTT bridge)
- `GET /api/devices` — list devices
- `POST /api/commands/{device_id}` — publish command via MQTT (topic: `devices/<id>/cmd`)

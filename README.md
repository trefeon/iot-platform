# Simple IoT Platform

A minimal web server for displaying sensor data.

## Features
- Web dashboard
- JSON API
- Docker support

## Quick Start

```bash
pip install flask
python main.py
```

Open http://localhost:5000

## Docker
```bash
docker-compose up
```

## API
- `GET /` - Dashboard
- `GET /api/data` - JSON data

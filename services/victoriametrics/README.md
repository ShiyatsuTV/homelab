# VictoriaMetrics

Prometheus + Graphite compatible time-series database.

## What it does
Local metrics storage for the homelab. Receives Graphite plain text and exposes an HTTP UI/API.

## Running
```bash
./run.sh
```

## Access
- HTTP / UI: http://localhost:8428
- Graphite ingestion: `localhost:2003`

## Data
Docker volume: `victoriametrics-v1.143.0-8428-2003-data` (pattern `victoriametrics-<version>-<ports>-data`).

## Notes
- Version pinned in `run.sh` (variable `VICTORIA_VERSION`)
- `--restart=always`: the container restarts on Docker boot
- The script does `docker rm -f` on the existing container before relaunching

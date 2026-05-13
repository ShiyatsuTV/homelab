# Redpeaks

Application monitoring/supervision tool (private image `redpeaks:*`).

## What it does
Tomcat-based container to run Redpeaks locally.

## Running
```bash
./run.sh
```

## Access
- HTTP: http://localhost:8888
- HTTPS: https://localhost:8883

## Data (named Docker volumes)
- `redpeaks-8888-certificates`
- `redpeaks-8888-drivers`
- `redpeaks-8888-db`
- `redpeaks-8888-import`
- `redpeaks-8888-logs`
- `redpeaks-8888-snapshots`
- `redpeaks-8888-tmp-drivers`
- `redpeaks-8888-update`
- `redpeaks-8888-worker-libs`
- `redpeaks-8888-workers`

## Notes
- Image version pinned in `run.sh` (variable `IMAGE`)
- `--add-host=host.docker.internal:host-gateway` lets the container reach the host machine
- To wipe everything (containers + images + volumes): `../../scripts/docker-clean.sh redpeaks`

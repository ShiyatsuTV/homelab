# Dokuwiki

Self-hosted personal wiki in Docker.

## What it does
Browser-accessible note storage as a wiki. GUI alternative to a Git repo of markdown.

## Running
```bash
./run.sh
```

## Access
- HTTP: http://localhost:8080

## Data
Docker volume: `dokuwiki_data` (mapped to `/storage` inside the container).

## Notes
- Image `dokuwiki/dokuwiki:2024-02-06b` (pinned tag, update manually)
- Container runs as `--user 1000:1000` (not root)
- No `--name` or `--restart=always` for now — enrich if needed

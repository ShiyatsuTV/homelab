# Redpeaks

Outil de monitoring/supervision applicatif (image privée `redpeaks:*`).

## À quoi ça sert
Container Tomcat-based pour faire tourner Redpeaks en local.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP : http://localhost:8888
- HTTPS : https://localhost:8883

## Données (volumes Docker nommés)
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
- Version d'image pinnée dans `run.sh` (variable `IMAGE`)
- `--add-host=host.docker.internal:host-gateway` permet au container d'atteindre la machine hôte
- Pour nettoyer entièrement (containers + images + volumes) : `../../scripts/docker-clean.sh redpeaks`

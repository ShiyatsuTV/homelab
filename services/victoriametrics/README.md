# VictoriaMetrics

Base de données time-series compatible Prometheus + Graphite.

## À quoi ça sert
Stockage local de métriques pour le homelab. Reçoit en Graphite plain text et expose une UI/API HTTP.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP / UI : http://localhost:8428
- Ingestion Graphite : `localhost:2003`

## Données
Volume Docker : `victoriametrics-v1.143.0-8428-2003-data` (pattern `victoriametrics-<version>-<ports>-data`)

## Notes
- Version pinnée dans `run.sh` (variable `VICTORIA_VERSION`)
- `--restart=always` : le container redémarre au boot Docker
- Le script fait un `docker rm -f` du container existant avant de relancer

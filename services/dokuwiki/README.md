# Dokuwiki

Wiki personnel auto-hébergé en Docker.

## À quoi ça sert
Stockage de notes en wiki accessible via navigateur. Alternative GUI à un repo Git de markdown.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP : http://localhost:8080

## Données
Volume Docker : `dokuwiki_data` (mappé sur `/storage` dans le container)

## Notes
- Image `dokuwiki/dokuwiki:2024-02-06b` (tag pinné, à mettre à jour manuellement)
- Le container tourne en `--user 1000:1000` (pas root)
- Pas de `--name` ni `--restart=always` pour l'instant — à enrichir si besoin

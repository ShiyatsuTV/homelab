# homelab

Repo personnel de centralisation : notes, documentation et scripts perso.

## Organisation

| Dossier | Contenu |
|---|---|
| [`setup/`](setup/) | Procédures d'install machine (WSL, Docker, Git, terminal, VPN…) |
| [`services/`](services/) | Services auto-hébergés en Docker (VictoriaMetrics, Redpeaks, Dokuwiki, Jenkins) |
| [`scripts/`](scripts/) | Scripts utilitaires transverses |
| [`tools/`](tools/) | Setup et config d'outils utilisés (Claude Code, etc.) |
| [`notes/`](notes/) | Cheatsheets et mémos divers (à remplir au fil de l'eau) |
| [`assets/`](assets/) | Binaires et archives (polices, etc.) |
| [`docs/`](docs/) | Specs et plans internes (workflow Superpowers) |

## Conventions

- Documentation en **Markdown**, scripts en **Bash `.sh`**
- **Kebab-case** pour noms de dossiers et fichiers (`docker-clean.sh`, `wsl-fedora/`)
- Un **`README.md`** par sous-dossier dès qu'il contient du contenu
- Templates de README : voir [`docs/superpowers/specs/2026-05-13-repo-organization-design.md`](docs/superpowers/specs/2026-05-13-repo-organization-design.md#conventions-internes)

## Zones grises courantes

- `setup/` = procédure d'install (à faire une fois)
- `notes/` = référence rapide (cheatsheet, mémo)
- Un sujet (Docker, Git, …) peut donc apparaître dans les **deux**.
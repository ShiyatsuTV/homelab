# homelab

Personal repo centralizing notes, documentation, and scripts.

## Layout

| Folder | Content |
|---|---|
| [`setup/`](setup/) | Machine install procedures (WSL, Docker, Git, terminal, VPN…) |
| [`services/`](services/) | Self-hosted Docker services (VictoriaMetrics, Redpeaks, Dokuwiki, Jenkins) |
| [`scripts/`](scripts/) | Generic utility scripts |
| [`tools/`](tools/) | Setup and config of tools I use (Claude Code, etc.) |
| [`notes/`](notes/) | Cheatsheets and memos (Oracle, [Steam on Fedora](notes/steam/)…) |
| [`assets/`](assets/) | Binaries and archives (fonts, etc.) |
| [`docs/`](docs/) | Internal specs and plans (Superpowers workflow) |

## Conventions

- Documentation in **Markdown**, scripts in **Bash `.sh`**
- **Kebab-case** for folder and file names (`docker-clean.sh`, `wsl-fedora/`)
- One **`README.md`** per subfolder as soon as it has content
- README templates: see [`docs/superpowers/specs/2026-05-13-repo-organization-design.md`](docs/superpowers/specs/2026-05-13-repo-organization-design.md#conventions-internes)

## Common grey areas

- `setup/` = install procedure (one-off)
- `notes/` = quick reference (cheatsheet, memo)
- A topic (Docker, Git, …) can therefore appear in **both**.

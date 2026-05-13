# Claude Code — Setup

Setup de [Claude Code](https://claude.com/claude-code) (CLI Anthropic) avec les plugins perso.

## Pré-requis
- Claude Code installé (`claude` disponible dans le PATH)

## Installer la liste de plugins perso
```bash
./install-plugins.sh
```

Le script installe tous les plugins listés dans le tableau `plugins` (superpowers, code-review, frontend-design, feature-dev, etc.).

## Ajouter un nouveau plugin
Éditer `install-plugins.sh` et ajouter une ligne au tableau `plugins` au format `"nom@registre"`. Puis relancer le script.

## Vérification
Run :
```bash
claude plugin list
```
Tous les plugins du tableau doivent apparaître.

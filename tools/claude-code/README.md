# Claude Code — Setup

Setup of [Claude Code](https://claude.com/claude-code) (Anthropic's CLI) with my personal plugins.

## Prerequisites
- Claude Code installed (`claude` available in `PATH`)

## Install the personal plugin list
```bash
./install-plugins.sh
```

The script installs every plugin listed in the `plugins` array (superpowers, code-review, frontend-design, feature-dev, etc.).

## Add a new plugin
Edit `install-plugins.sh` and append a line to the `plugins` array in the format `"name@registry"`. Then re-run the script.

## Verification
Run:
```bash
claude plugin list
```
Every plugin in the array should appear.

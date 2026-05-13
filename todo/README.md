# todo/

A capture folder for raw material that hasn't yet been integrated into the repo's structured layout (`setup/`, `services/`, `scripts/`, `tools/`, `notes/`, `assets/`).

## What goes here

Anything you want to integrate later but don't want to file right now:

- Bash scripts (`.sh`)
- `docker run` snippets for new self-hosted services
- Install/setup notes (`.txt`, `.md`)
- Config fragments (`.toml`, `.conf`, `.yml`)
- Cheatsheets, command memos
- Multi-topic text dumps
- Binary assets (fonts, etc.)

Drop the file in `todo/`. Add short inline comments (e.g. `# grafana for dashboards over victoriametrics`) to give the classifier a hint about what the file is for. The hint also seeds the generated README's intro sentence.

## How to integrate

In Claude Code, type:

```
/process-todo
```

The command will:

1. Read every file in `todo/` (ignoring this README and `.gitkeep`).
2. Classify each file: where it should live, whether it needs to be split into multiple destinations, whether the proposed filename is appropriate.
3. Show you a numbered plan of proposed actions.
4. Wait for your approval. You can accept, skip items, rename targets, redirect destinations, or cancel.
5. On approval, execute item-by-item: one commit per top-level source file, source removed from `todo/` in the same commit.

## What `/process-todo` will NOT do

- Touch files outside the categories listed above.
- Silently overwrite existing files (`OVERWRITE` is always flagged in the plan).
- Process anything if there are uncommitted staged changes in the working tree.
- Process items that look like they contain secrets (private keys, tokens, passwords) — those are blocked and surfaced for manual review.

## Tip

Keep entries small and self-contained. A `todo/` file that does one thing (one script, one note, one config fragment) classifies cleanly. A file that mixes 5 topics will still work — it gets split — but you'll review more decisions in the plan.

# Design — `/process-todo` Workflow

**Date:** 2026-05-13
**Status:** Approved for implementation
**Author:** Serkan (ShiyatsuTV)

## Context

The owner of the `homelab` repo wants a low-friction way to capture raw material (scripts, notes, configuration snippets, multi-topic text dumps) and have Claude turn it into properly classified, documented, and committed content that fits the repo's hybrid 5-category layout (`setup/` / `services/` / `scripts/` / `tools/` / `notes/` + `assets/`).

The capture surface is a single top-level folder named `todo/`. The user drops files there with brief inline comments. When ready, the user invokes a slash command and Claude turns the dump into structured commits.

This spec defines:
- The slash command's surface (`/process-todo`)
- How Claude classifies items, splits multi-topic files, and decides destinations
- The plan-first / execute-after-approval workflow
- Commit and source-deletion semantics
- Edge cases (conflicts, secrets, unclassifiable items)
- Where the slash command definition lives in the repo

## Goals

1. **Zero ceremony on capture.** The user drops anything (`.sh`, `.txt`, `.toml`, `.md`, …) into `todo/` with optional one-line comments and never has to think about where it belongs.
2. **Deterministic classification with explicit reasoning.** Claude reads content (not just extensions), decides where each item belongs based on the repo's category logic, and explains its reasoning in the plan.
3. **No silent writes.** Every action is presented in a plan and requires user approval before execution. Conflicts and ambiguities surface in the plan, never resolved silently.
4. **Atomic per-item commits.** Each top-level `todo/` item produces one commit that creates the destination(s) and removes the source. Failures roll back; successes are durable.
5. **Self-cleaning capture.** After successful integration, the source file in `todo/` is removed in the same commit. Audit trail lives in git.

## Non-goals

- Two-way sync between `todo/` and the rest of the repo. `todo/` is one-way: capture → integration.
- Restructuring already-integrated content. The slash command does not touch files outside its declared destinations; cross-cutting refactors are a separate flow.
- Cross-repo behavior. The slash command is project-scoped; it knows the `homelab` layout. A future user-level version would be a separate effort.

## Architecture

### Surface

A project-level Claude Code slash command at `.claude/commands/process-todo.md`. Invoked by the user typing `/process-todo` (no arguments).

### Lifecycle

```
/process-todo
    │
    ▼
1. Scan todo/  ────────────────►  empty / missing → "Nothing to process"
    │                                                  (exit cleanly)
    ▼
2. Read & classify each file
    │
    ▼
3. Build a consolidated plan (proposed actions per item)
    │
    ▼
4. Present plan to user, wait for approval / adjustments
    │
    ├─ rejected     ────────────►  abort, todo/ untouched
    ├─ adjustments  ────────────►  revise plan, re-present
    └─ approved     ────────────►  continue
    │
    ▼
5. Execute item-by-item, one commit per top-level item:
       a. Write target file(s)
       b. `rm` source file(s) from todo/
       c. `git add` + `git commit` with auto-generated conventional message
    │
    ▼
6. Final report:
       - Commits created
       - Items skipped (per user instruction)
       - Items that failed (source preserved in todo/, error explained)
       - Items still UNCLASSIFIED (source preserved in todo/)
```

### File structure introduced by this design

- `.claude/commands/process-todo.md` — Slash command definition (system-style prompt that instructs Claude how to behave when invoked).
- `todo/README.md` — Human-facing docs on how to use `todo/`.
- `todo/.gitkeep` — So the (otherwise empty) `todo/` folder is versioned.

No changes to any of the existing repo categories (`setup/` / `services/` / `scripts/` / `tools/` / `notes/` / `assets/`).

## Classification logic

Claude reads each file's content (header bytes, shebang, file shape, inline comments) and classifies it into one of the existing repo categories. Extension is a weak signal; content is the strong one.

### Decision table

| Content signal | Destination |
|---|---|
| Bash script (shebang), generic utility (not tied to one service) | `scripts/<name>.sh` |
| `docker run` for a named service X (single command or short script) | `services/<X>/run.sh` (wrapped with `#!/usr/bin/env bash` and `set -euo pipefail` if missing) + a generated `services/<X>/README.md` |
| Install/setup procedure for a system tool (`dnf install`, `apt install`, etc.) | `setup/<topic>/README.md` (+ associated config files alongside if present) |
| Setup/config of a tool the user **uses** (CLI, IDE, plugin manager) | `tools/<tool>/...` |
| Standalone note, cheatsheet, "syntax of X" memo | `notes/<topic>.md` |
| Multi-topic dump (sections clearly separated by headers, comment blocks, or topic shifts) | **Split** — one source becomes N destinations, each classified individually |
| Raw configuration file (`.toml`, `.conf`, `.yml`) with no clear owning service | Surfaced as ambiguous in the plan; user picks destination |
| Binary (zip, tarball, image) | `assets/<…>/` (subfolder chosen by user or proposed by Claude) |

### Filename normalization

- All created files/folders use **kebab-case**.
- A source named `Docker Cleanup Script.sh` becomes `docker-cleanup-script.sh` (or shorter if obvious).
- The proposed filename is always shown in the plan and can be overridden in the approval step.

### Use of user comments as input

Inline comments in the source file (e.g., `# grafana for dashboards over victoriametrics`) act as both:
- **A classification hint** when content alone is ambiguous.
- **Seed text for the generated README** — typically the first sentence of "What it does" / "À quoi ça sert" replacement once docs are translated to English.

### Conflicts

Claude does not silently overwrite or merge with existing files. When the proposed destination already exists, the plan explicitly says `OVERWRITE` (with current file size) or `APPEND` (with the section/anchor it will be added under), and the user confirms in the approval step.

### Unclassifiable items

If a source cannot be confidently mapped, the plan shows it as `UNCLASSIFIED` with no proposed action. Options at approval time: provide a destination, leave in `todo/`, or drop. Claude never invents a destination for an unclassifiable item.

### Secret detection

If a source contains content that looks like a secret (private key blocks, recognizable token patterns, password assignments), the item is flagged `BLOCKED: possible secret` in the plan and no action is proposed. The user decides: sanitize, move out of `todo/`, or drop. This applies even though the repo is private — capture surfaces should not become accidental secret stores.

## Plan format

The plan is presented as a numbered list. Items that are split become hierarchical (`3a`, `3b`, …). Each entry contains:

- **Type** — Claude's classification label
- **Source** — original filename in `todo/` + relevant shape info (line count, key signals)
- **Action** — one or more verbs: `CREATE`, `APPEND`, `OVERWRITE`, `RENAME`, `NONE`
- **Note** — optional explanation, especially for split items or items where user comments shaped the destination
- **Delete** — when the source file in `todo/` will be removed (always "after commit succeeds")

A literal example is shown in the canonical reference at the end of this spec.

### Approval vocabulary

The user can respond in natural language. Recognized intents:
- `OK` / `go` / `yes` → execute all approved items.
- `skip N` / `skip Na` → drop a specific item or sub-item from execution.
- `rename N <new-name>` → change a proposed filename.
- `merge N into <path>` → redirect to a different destination.
- `edit N` → request Claude revise the proposed content before writing.
- Any other natural-language adjustment is parsed as best-effort and re-presented for confirmation.

A bare refusal (`no`, `cancel`, `stop`) aborts execution entirely. `todo/` stays untouched.

## Execution semantics

### Ordering

Items execute in plan order (`1`, `2`, `3a`, `3b`, `3c`, …). Sequential, not parallel, to keep commits clean.

### Commit granularity

One commit per **top-level** item. A split item (`3a/3b/3c` all sourced from `todo/random-notes.txt`) produces a single commit that:
- Writes all sub-destinations
- Removes the single source
- Has one consolidated commit message

This means `git revert <commit>` undoes everything traceable to a single source file.

### Commit messages

Auto-generated using conventional commit style. Type and scope match the destination category:

| Destination | Type / scope |
|---|---|
| `services/<x>/...` | `feat(services): add <x> service from todo` |
| `setup/<topic>/...` | `docs(setup): add <topic> procedure from todo` |
| `scripts/...` | `feat(scripts): add <script-name> from todo` |
| `tools/<tool>/...` | `feat(tools): add <tool> config from todo` |
| `notes/...` | `docs(notes): add <topic> from todo` |
| `assets/...` | `chore(assets): add <name> from todo` |
| Split (mixed types) | Use the highest-priority type in the mix; cite all destinations in the body |

Commit messages are always written in **English** (repo-wide convention going forward).

### Language of generated content

All written artifacts in the repo are in English (`README.md`, headers, prose, commit messages). When the user drops a source file in French (or any other language), the workflow paraphrases the prose into English while keeping language-agnostic elements (shell commands, code blocks, paths, identifiers, version numbers) verbatim. The user's inline source comments act as hints; the final generated text is English.

This matches the repo-wide convention. A French sentence in a source `todo/` file is not preserved as-is in the generated README.

### Source deletion

The `rm todo/<source>` happens in the same commit that writes the destination(s). If anything in the item's write phase fails, the entire item rolls back: destinations not written, source not deleted, error surfaced in the final report.

### Failures

- A failed item leaves its source in `todo/` and an explanation in the final report.
- Earlier successful items remain committed (no global rollback).
- The user can re-run `/process-todo` and the remaining sources are re-evaluated.

## Edge cases

| Situation | Behavior |
|---|---|
| `todo/` does not exist | Create it (with `.gitkeep`), report "Nothing to process". |
| `todo/` is empty (only `.gitkeep` / `README.md`) | Report "Nothing to process. Drop files into `todo/` first." |
| `todo/README.md` or `todo/.gitkeep` | Always ignored — not candidates for classification. |
| Source is a binary file | Detected via byte inspection; routed to `assets/...` discussion in the plan. Never read as text. |
| Destination file already exists | Plan shows `OVERWRITE` or `APPEND` explicitly with current file size and the anchor (for `APPEND`). |
| Two source items target the same destination filename | Detected at plan time; Claude proposes distinct names or an `APPEND` for one, surfaces it for confirmation. |
| Source looks like a secret | Item marked `BLOCKED: possible secret`. No action proposed. User decides. |
| Pre-existing untracked files outside `todo/` | Plan still runs. Execution does not stage them. The final report lists them so the user knows they're still hanging around. |
| Pre-existing **staged** changes (anything in `git diff --cached`) | Execution is **refused** until the user commits or stashes those changes. Prevents `/process-todo` commits from accidentally including unrelated work. |

## Success criteria

- [ ] `.claude/commands/process-todo.md` exists with a working slash command definition.
- [ ] `todo/` exists at repo root with a `README.md` explaining usage.
- [ ] `todo/.gitkeep` keeps the folder versioned when empty.
- [ ] Running `/process-todo` on an empty `todo/` reports cleanly without touching anything.
- [ ] Running `/process-todo` on a `todo/` with one well-classifiable item produces:
  - A plan with that item
  - On approval: one commit with the destination created, the source removed, conventional commit message in English
- [ ] Running `/process-todo` on a `todo/` with a multi-topic file produces a plan that splits the file into per-topic destinations under one consolidated commit.
- [ ] Conflicts (existing destination, name collision, possible secret) are surfaced in the plan, not silently resolved.
- [ ] The slash command definition is itself in English (project conventions apply to it too).

## Out of scope

- Translating the existing French READMEs / spec / plan in the repo to English. That's a separate chantier, tracked outside this spec.
- A user-level (`~/.claude/commands/`) variant of the command. Project-level only for now.
- Automatic post-integration follow-ups (e.g., updating root `README.md`'s table when a new top-level category appears). The user adjusts the root README manually if needed.
- Anything that operates outside the `todo/`, `setup/`, `services/`, `scripts/`, `tools/`, `notes/`, `assets/` paths. The slash command stays within the documented surface.

## Canonical plan example

```
Found 4 items in todo/. Proposed actions:

┌─ 1. cleanup-images.sh
│    Type:     Standalone bash utility (no service-specific context)
│    Source:   todo/cleanup-images.sh (47 lines, has shebang + set -e)
│    Action:   CREATE scripts/cleanup-images.sh (+x)
│    Naming:   kebab-case OK as-is
│    Delete:   todo/cleanup-images.sh after commit
│
├─ 2. grafana-run.txt
│    Type:     Docker run for a new self-hosted service
│    Source:   todo/grafana-run.txt (single `docker run` block)
│    Action:   CREATE services/grafana/run.sh (wrap in bash header)
│              CREATE services/grafana/README.md (from your inline comments)
│    Note:     You wrote "# grafana for dashboards over victoria" — I'll use
│              that as the README intro and add a cross-reference to
│              services/victoriametrics/
│    Delete:   todo/grafana-run.txt after commit
│
├─ 3. random-notes.txt
│    Type:     Multi-topic dump → SPLIT
│    Source:   todo/random-notes.txt (88 lines, 3 distinct sections)
│    Action:   3 destinations, single commit:
│              a) "## git rebase" block → CREATE notes/git-rebase.md
│              b) "## docker network commands" block → CREATE notes/docker-network.md
│              c) "## fix for jenkins volume bug" block → APPEND to
│                 services/jenkins/README.md under new "## Troubleshooting"
│    Delete:   todo/random-notes.txt after commit
│
└─ 4. weird-config.conf
    Type:     UNCLASSIFIED — no clear owning context
    Source:   todo/weird-config.conf (looks like an haproxy fragment?)
    Action:   NONE proposed. Options at approval time:
              - Tell me which service/setup it belongs to
              - Keep in todo/ for now
              - Drop it

Reply:
- "OK" / "go" / "yes"  → execute all approved items
- "skip N" / "skip Na" → drop a specific item or sub-item
- "rename N <name>"    → change a proposed filename
- "merge N into <path>" → redirect to a different destination
- "edit N"             → revise proposed content before writing
- anything else, in natural language, to adjust
```

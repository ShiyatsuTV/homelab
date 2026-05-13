---
description: Read todo/, classify items, propose a plan, execute on approval
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# /process-todo

You are processing the `todo/` folder of the homelab repo. Your job is to turn free-form captures (scripts, notes, configs, multi-topic dumps) into structured commits in the repo's hybrid 5-category layout.

You operate in **plan-first** mode: read everything, propose actions, wait for user approval, then execute. Never write to destinations or delete sources before the user approves.

## Hard rules

1. **English only for generated artifacts.** All `README.md`, prose, commit messages, and inline comments you generate go in English, regardless of the source language. Shell commands, paths, identifiers, and code blocks pass through verbatim.
2. **One commit per top-level `todo/` item.** A source file that splits into multiple destinations still produces one commit covering all destinations plus the source deletion.
3. **Source deletion is part of the same commit as the destinations.** Never delete a source before its content is committed elsewhere.
4. **No silent overwrites.** If a destination already exists, the plan must say `OVERWRITE` or `APPEND` explicitly, with current file size.
5. **No secret leakage.** If a source looks like it contains a private key, token, password assignment, or similar, mark the item `BLOCKED: possible secret` and propose no action.
6. **Kebab-case for all created filenames and folders.**
7. **Refuse to run if `git diff --cached` is non-empty.** Tell the user to commit or stash first.

## Repo layout reference

| Category | Goes in | When |
|---|---|---|
| `setup/<topic>/` | README.md (+ config files if relevant) | One-time install / setup procedure |
| `services/<name>/` | README.md + run.sh | A self-hosted Docker service (1 folder = 1 service) |
| `scripts/` | `<name>.sh` (kebab-case) | Standalone bash utility, not tied to a specific service |
| `tools/<tool>/` | README.md (+ config or install script) | Setup/config for a tool the user **uses** (CLI, IDE, plugin manager) |
| `notes/` | `<topic>.md` | Cheatsheets, memos, "syntax of X" references |
| `assets/<sub>/` | binary file | Fonts, archives, images we deliberately version |

## Workflow

### Step 1: Pre-flight

Run `git diff --cached --quiet || echo HAS_STAGED`.

- If `HAS_STAGED` appears: STOP. Tell the user: "There are staged changes. Commit or stash them, then re-run `/process-todo`." Exit.

Run `ls -A todo/ 2>/dev/null | grep -v -E '^(README\.md|\.gitkeep)$'`.

- If `todo/` doesn't exist: create it (`mkdir -p todo && touch todo/.gitkeep`), tell the user "`todo/` was missing — created it. Nothing to process." Exit.
- If the listing is empty: tell the user "Nothing to process. Drop files into `todo/` first." Exit.
- Otherwise: continue.

### Step 2: Read every candidate

For each filename in the listing above:

- Read the file content (use the `Read` tool, not `cat`).
- Detect if it's binary (non-printable bytes, looks like an archive header). If binary, classify it as `assets/` candidate without trying to interpret content.
- For text files: identify shape signals — shebang line, presence of `docker run`, `dnf install` / `apt install` / `brew install` patterns, multi-section structure (markdown headers, separator comments like `----- xxx -----`, blank-line-delimited topic blocks), config-file shape (TOML/YAML/INI), free-form prose, etc.
- Note any inline comments the user wrote (lines starting with `#` outside code, or markdown blockquotes). These are classification hints and seed text for generated READMEs.

### Step 3: Classify

For each source file, produce one classification using this decision logic (apply in order — first match wins):

1. **Multi-topic dump** (2+ clearly distinct sections — markdown headers, comment dividers, or topic jumps) → **SPLIT**. Each section becomes its own sub-item. Re-classify each section using rules 2–7.
2. **Has shebang AND content is `docker run` for a named service X** → `services/<X>/run.sh` + generated `services/<X>/README.md`.
3. **Has shebang, generic utility (no obvious single-service focus)** → `scripts/<kebab-name>.sh`.
4. **No shebang, content is install/setup commands (dnf, apt, brew, system config edits)** → `setup/<topic>/README.md`. If config files are present, add them alongside.
5. **No shebang, content is setup/config of a CLI/IDE/plugin manager the user uses** → `tools/<tool>/...`.
6. **No shebang, free-form notes / cheatsheet / "how to do X" memo** → `notes/<topic>.md`.
7. **Raw config file (`.toml`, `.conf`, `.yml`) with no clear owning context** → ambiguous — surface in plan with no auto-destination.
8. **Binary** → `assets/<sub>/<name>` (propose `fonts/`, `images/`, or surface for user to pick).
9. **None of the above** → `UNCLASSIFIED`, no action proposed.

For each destination, also check:

- Does the file already exist? → mark `OVERWRITE` (with current size) or propose `APPEND` (with the anchor heading).
- Does another item in the same batch target the same path? → mark name collision in plan, propose distinct names.
- Does content look like a secret? → mark `BLOCKED: possible secret`, no action.

### Step 4: Build the plan

Present the plan in this exact format. Use box-drawing characters, numbered items with sub-items where files are split (`3a`, `3b`, …), and finish with the approval vocabulary block.

```
Found <N> items in todo/. Proposed actions:

┌─ 1. <source filename>
│    Type:     <one-line classification label>
│    Source:   todo/<source> (<shape info — line count, key signals>)
│    Action:   <VERB> <destination path> [(extra: +x, append anchor, overwrite size)]
│              <VERB> <destination path> [(extra)]
│    Note:     <optional: why this classification, what user comment seeded the README>
│    Delete:   todo/<source> after commit
│
├─ 2. ...
│
└─ N. ...

Reply:
- "OK" / "go" / "yes"  → execute all approved items
- "skip N" / "skip Na" → drop a specific item or sub-item
- "rename N <name>"    → change a proposed filename
- "merge N into <path>" → redirect to a different destination
- "edit N"             → revise proposed content before writing
- anything else, in natural language, to adjust
```

Action verbs:
- `CREATE` — new file
- `APPEND` — add to an existing file under a specific anchor heading (always specify the heading)
- `OVERWRITE` — replace existing file content (always state current file size)
- `NONE` — no action proposed (UNCLASSIFIED or BLOCKED)

Then **stop and wait for the user's reply**. Do not execute anything yet.

### Step 5: Process the user's reply

If the reply is a clean approval (`OK`, `go`, `yes`, `proceed`, etc.) → continue to Step 6.

If the reply is a rejection (`no`, `cancel`, `stop`, `abort`) → report "Aborted, todo/ untouched" and exit. Make no file changes.

Otherwise → parse adjustments (`skip N`, `rename N <name>`, `merge N into <path>`, `edit N`, free-form). Apply them to the plan, present the revised plan, wait for approval again. Loop until clean approval or rejection.

### Step 6: Execute

For each approved item in plan order:

1. Read source content from `todo/<source>` once more (it might have been edited between plan and approval).
2. For each destination of this item:
   - Generate the target content. For READMEs and prose, write **English** (translate / paraphrase any non-English source prose; preserve commands and code verbatim).
   - For service `run.sh` files: if the source is a raw `docker run`, wrap it with `#!/usr/bin/env bash` and `set -euo pipefail`. Add a trailing newline.
   - For service `README.md` files: use the user's inline comment as seed for the "What it does" section. Fill ports, volumes, image tag from the `docker run` parameters. Add a `## Running` section pointing to `./run.sh`.
   - Use the `Write` tool for `CREATE`, `Edit` (with anchor-based replacement) for `APPEND`, `Write` for `OVERWRITE`.
3. `chmod +x` any new `.sh` files (Bash: `chmod +x <path>`).
4. `rm todo/<source>` (only the top-level source — split sub-destinations all derive from the same source).
5. `git add` all destinations and the source removal.
6. Build the commit message using this table:

   | Primary destination | Message |
   |---|---|
   | `services/<x>/` | `feat(services): add <x> service from todo` |
   | `setup/<topic>/` | `docs(setup): add <topic> procedure from todo` |
   | `scripts/<name>.sh` | `feat(scripts): add <name> from todo` |
   | `tools/<tool>/` | `feat(tools): add <tool> config from todo` |
   | `notes/<topic>.md` | `docs(notes): add <topic> cheatsheet from todo` |
   | `assets/<sub>/<name>` | `chore(assets): add <name> from todo` |

   For a split item with mixed types, pick the highest-priority type (services > setup > scripts > tools > notes > assets) and list all destinations in the commit body.

7. Commit with `git commit -m "<subject>"` (or HEREDOC for body when needed). Always append the standard `Co-Authored-By` footer used in this repo:
   ```
   Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
   ```

8. If anything in steps 1–7 fails for this item: do not commit it, `git restore --staged` and `git restore` any partial changes, restore the source if you already deleted it (`git checkout HEAD -- todo/<source>` or recreate from the in-memory copy), record the failure for the final report, move on to the next item.

### Step 7: Final report

Print a summary:

```
Done.

Commits created (<count>):
  <sha-short> <subject>
  ...

Skipped (per your instruction):
  - <item>: <reason>

Blocked:
  - <item>: <reason — secret, name collision, etc.>

Failed:
  - <item>: <what failed, source preserved in todo/>

Still UNCLASSIFIED in todo/:
  - <filename>
```

Empty sections are omitted.

## Style guidelines for generated content

- **README templates**: short, factual, action-oriented. Mimic existing READMEs in `services/` and `setup/`. Section headers in English: `## What it does`, `## Running`, `## Access`, `## Data`, `## Notes` for services; `## Prerequisites`, `## Steps`, `## Verification` for setup procedures.
- **Code blocks**: always tagged (` ```bash `, ` ```toml `, etc.).
- **Commands**: one per line, no `&&` chains in docs.
- **Sources / links**: link to upstream docs if the user mentioned a URL in the source file.
- **Be terse**: no marketing copy, no "this is a great way to…" filler.

## Refuse loudly

If the user resists adjusting a `BLOCKED` item (e.g., insists on processing a file with what looks like a secret), explain the risk and let them confirm again. If they confirm explicitly with awareness, proceed — they own the repo.

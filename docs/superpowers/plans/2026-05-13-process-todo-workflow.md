# `/process-todo` Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a project-level `/process-todo` Claude Code slash command that reads the `todo/` capture folder, classifies its contents, presents a plan to the user, and on approval integrates everything into the homelab repo's hybrid 5-category layout with one commit per top-level item.

**Architecture:** Project-scoped slash command. Three new files: `.claude/commands/process-todo.md` (the LLM behavior definition), `todo/.gitkeep` (so the folder is versioned), `todo/README.md` (human-facing docs). No runtime code, no tests — the slash command body is a prompt loaded into Claude's context at invocation time. Verification is done by reading the prompt against the spec, plus optional smoke tests via real invocation.

**Tech Stack:** Markdown, Bash, Git, Claude Code project-level slash commands.

**Spec:** [`docs/superpowers/specs/2026-05-13-todo-workflow-design.md`](../specs/2026-05-13-todo-workflow-design.md)

---

## File Structure

### Files created

- `.claude/commands/process-todo.md` — Slash command definition (frontmatter + prompt body). This is the only "behavior" file; everything about the workflow lives here.
- `todo/.gitkeep` — Empty file so an otherwise empty `todo/` directory can be committed.
- `todo/README.md` — Short human-facing usage docs (what `todo/` is, how to use it, what `/process-todo` will do).

### Files NOT modified

- The existing `.gitignore`, the repo `README.md`, any `setup/*`, `services/*`, `scripts/*`, `tools/*`, `notes/*`, or `assets/*` content. The slash command will write to those at runtime when invoked, but the plan itself does not touch them.

### Pre-task state

- Current branch: `main`
- Current HEAD: `e039fc9` (spec for this feature, just committed)
- Working tree clean
- `git status --short` is empty

---

## Task 1: Scaffold the `todo/` folder

**Files:**
- Create: `todo/.gitkeep` (empty)
- Create: `todo/README.md`

**Step 1: Create `todo/` directory and `.gitkeep`**

Run from repo root:
```bash
mkdir -p todo
touch todo/.gitkeep
```

Expected: `todo/` exists, `todo/.gitkeep` is a 0-byte file.

**Step 2: Create `todo/README.md`** with this EXACT content:

````markdown
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
````

**Step 3: Verify**

Run:
```bash
ls -la todo/
test -f todo/.gitkeep && echo "gitkeep OK"
test -f todo/README.md && echo "README OK"
head -3 todo/README.md
```

Expected: both files exist, README starts with `# todo/`.

**Step 4: Commit**

```bash
git add todo/
git commit -m "chore(todo): scaffold capture folder with usage README"
```

Expected: one commit with exactly 2 files (`todo/.gitkeep`, `todo/README.md`).

---

## Task 2: Create `.claude/commands/process-todo.md` (the slash command)

**Files:**
- Create: `.claude/commands/process-todo.md`

This task creates the actual slash command. The file's body is the prompt Claude loads when the user types `/process-todo`. The frontmatter declares the command's description and the tools it needs.

**Step 1: Create `.claude/commands/` directory if missing**

Run:
```bash
mkdir -p .claude/commands
```

(The `.claude/` directory may already exist from earlier Claude Code activity. `mkdir -p` is a no-op if so.)

**Step 2: Create `.claude/commands/process-todo.md`** with this EXACT content:

````markdown
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
````

**Step 3: Verify the file was created correctly**

Run:
```bash
test -f .claude/commands/process-todo.md && echo "OK"
head -10 .claude/commands/process-todo.md
wc -l .claude/commands/process-todo.md
```

Expected: file exists, starts with `---` frontmatter, well over 100 lines.

**Step 4: Commit**

```bash
git add .claude/commands/process-todo.md
git commit -m "feat(commands): add /process-todo project slash command"
```

Expected: one commit, one file.

---

## Task 3: Spec coverage audit

This task is a **read-only verification** — no code changes, no commit. Confirm the slash command file covers every requirement in the spec.

**Files:**
- Read: `docs/superpowers/specs/2026-05-13-todo-workflow-design.md`
- Read: `.claude/commands/process-todo.md`

**Step 1: Re-read the spec, section by section**

Open `docs/superpowers/specs/2026-05-13-todo-workflow-design.md`.

**Step 2: Verify each spec requirement is reflected in the slash command file**

For each row below, search `.claude/commands/process-todo.md` for the corresponding behavior. If a row has no match in the slash command file, that's a gap to fix.

| Spec section | Required behavior | Where in slash command? |
|---|---|---|
| Goals #1 (zero ceremony on capture) | No required structure on input — anything goes | Step 1 + Step 2 |
| Goals #2 (deterministic classification with reasoning) | Decision logic + "Note" line in plan format | Step 3 + plan format |
| Goals #3 (no silent writes) | Plan-first, wait for approval, conflicts flagged | Step 4 + Step 5 + hard rule #4 |
| Goals #4 (atomic per-item commits) | One commit per top-level item, rollback on failure | Hard rule #2 + Step 6.8 |
| Goals #5 (self-cleaning capture) | Source deleted in same commit as destinations | Hard rule #3 + Step 6.4-7 |
| Classification: bash utility | scripts/ | Rule 3 |
| Classification: docker run named service | services/<X>/{run.sh, README.md} | Rule 2 + Step 6.2 wrapping |
| Classification: install procedure | setup/<topic>/ | Rule 4 |
| Classification: user-tool setup | tools/ | Rule 5 |
| Classification: standalone note | notes/ | Rule 6 |
| Classification: multi-topic dump | SPLIT, re-classify each section | Rule 1 |
| Classification: raw config no context | ambiguous, no auto-destination | Rule 7 |
| Classification: binary | assets/ | Rule 8 |
| Classification: unclassifiable | UNCLASSIFIED | Rule 9 |
| Filename normalization (kebab-case) | All created files kebab-case | Hard rule #6 |
| Conflicts (destination exists) | OVERWRITE/APPEND, current size, user confirms | Step 3 final checks + plan format |
| Two items target same path | name collision flagged, propose distinct | Step 3 final checks |
| Possible secrets | BLOCKED, no action proposed | Hard rule #5 + Step 3 final checks |
| Inline source comments as hints | both classification hint and README seed | Step 2 last bullet + Step 6.2 README |
| Plan format (numbered, hierarchical for splits, action verbs) | Plan layout exact | Step 4 plan format |
| Approval vocabulary | OK / skip / rename / merge / edit / cancel | Step 5 + plan format footer |
| Commit granularity (one per top-level) | One commit per item | Hard rule #2 + Step 6 |
| Commit message format (conventional, English, scope by category) | Table mapping destination to message | Step 6.6 table |
| Source deletion in same commit | rm todo/<source> before commit | Step 6.4 |
| Failure rollback | Restore staged/unstaged, preserve source, continue | Step 6.8 |
| Empty `todo/` → "Nothing to process" | Empty-listing branch | Step 1 |
| Missing `todo/` → create + report | Missing-dir branch | Step 1 |
| Ignore `todo/.gitkeep` and `todo/README.md` | Exclusion in listing grep | Step 1 |
| Refuse on staged changes | git diff --cached check | Step 1 + hard rule #7 |
| Pre-existing untracked files outside todo/ | Plan runs, report lists them | Step 7 (implicit — they're not modified, no action needed) |
| Final report | Commits created / skipped / blocked / failed / unclassified | Step 7 format |
| English-only generated content | Translate prose, preserve commands | Hard rule #1 + Step 6.2 prose generation |

**Step 3: Fix any gaps**

If a requirement is not reflected in `.claude/commands/process-todo.md`, edit the file to add it. Re-commit with message `fix(commands): cover <missing-thing> in /process-todo`.

If no gaps: no action needed.

**Step 4: No commit if no changes**

This task may end without producing a commit. That's expected if Task 2 was complete and correct.

---

## Task 4: Smoke test — empty `todo/`

This task verifies the empty-folder branch works. It's interactive (requires invoking the slash command), so the steps describe the user-visible expected behavior.

**Files:**
- No files created or modified.

**Step 1: Ensure `todo/` is empty (except for the README and .gitkeep)**

Run:
```bash
ls -A todo/ | grep -v -E '^(README\.md|\.gitkeep)$'
```

Expected: empty output (no extra files).

If there are extra files, move them aside temporarily — this test requires an empty `todo/`.

**Step 2: Invoke `/process-todo` in Claude Code**

In a Claude Code session, type:
```
/process-todo
```

**Step 3: Verify the response**

Expected: Claude reports something like "Nothing to process. Drop files into `todo/` first." and makes no changes.

Run after the response:
```bash
git status
```

Expected: clean working tree, no new commits.

**Step 4: No commit**

This task is verification only.

---

## Task 5: Smoke test — single classifiable item

Verify the happy path on the simplest case.

**Files:**
- Create (temporary): `todo/sample-cleanup.sh`
- Will be removed by `/process-todo` and replaced by `scripts/sample-cleanup.sh`

**Step 1: Create a sample script in `todo/`**

Create `todo/sample-cleanup.sh`:

```bash
#!/usr/bin/env bash
# Quick disk cleanup — clears /tmp older than 7 days
set -euo pipefail

find /tmp -type f -atime +7 -print -delete
echo "Cleanup done."
```

Run:
```bash
chmod +x todo/sample-cleanup.sh
ls -la todo/sample-cleanup.sh
```

Expected: file exists, executable.

**Step 2: Invoke `/process-todo`**

In Claude Code, type:
```
/process-todo
```

**Step 3: Verify the plan output**

Expected: a plan with a single item, classified as a standalone bash utility, proposing `CREATE scripts/sample-cleanup.sh (+x)` and `Delete: todo/sample-cleanup.sh after commit`.

**Step 4: Approve**

Reply `OK`.

**Step 5: Verify execution**

Run:
```bash
test -f scripts/sample-cleanup.sh && echo "moved OK"
test ! -f todo/sample-cleanup.sh && echo "source removed"
ls -l scripts/sample-cleanup.sh
git log -1 --format='%s%n%n%b'
```

Expected:
- `moved OK` and `source removed` both printed
- `scripts/sample-cleanup.sh` is executable
- Last commit subject is exactly `feat(scripts): add sample-cleanup from todo` (per the table in `.claude/commands/process-todo.md` Step 6.6)
- Commit body includes `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`

**Step 6: Clean up the test artifact**

Since this was a smoke test, remove the sample script:

```bash
git rm scripts/sample-cleanup.sh
git commit -m "chore: drop sample-cleanup.sh smoke-test artifact"
```

Or, if you want to keep it as a real utility, leave it. Your call.

---

## Task 6: Smoke test — split multi-topic file

Verify the SPLIT behavior produces a single consolidated commit.

**Files:**
- Create (temporary): `todo/mixed-bag.txt`
- Will be removed by `/process-todo` and produce 2+ destinations

**Step 1: Create a mixed-topic source**

Create `todo/mixed-bag.txt` with this content:

```
# Two unrelated things below — split them.

----- git rebase quick reference -----

# Squash last N commits interactively
git rebase -i HEAD~N

# Continue after resolving a conflict
git add <files>
git rebase --continue

# Abort and go back
git rebase --abort

----- docker network basics -----

# List networks
docker network ls

# Inspect a network
docker network inspect <name>

# Create a user-defined bridge
docker network create --driver bridge my-net

# Connect a running container
docker network connect my-net <container>
```

**Step 2: Invoke `/process-todo`**

In Claude Code, type:
```
/process-todo
```

**Step 3: Verify the plan**

Expected: a single top-level item `1. mixed-bag.txt` flagged as **SPLIT** with two sub-items:
- `1a` → `CREATE notes/git-rebase.md` (or similar kebab-case name)
- `1b` → `CREATE notes/docker-network.md` (or similar)

Both delete `todo/mixed-bag.txt` after a single commit.

**Step 4: Approve**

Reply `OK`.

**Step 5: Verify execution produced ONE commit covering both files**

Run:
```bash
test -f notes/git-rebase.md && echo "git-rebase OK"
test -f notes/docker-network.md && echo "docker-network OK"
test ! -f todo/mixed-bag.txt && echo "source removed"
git log -1 --stat
```

Expected:
- Both notes files exist
- Source removed
- `git log -1 --stat` shows exactly one commit with three file changes (two new notes + one source deletion)
- Commit subject like `docs(notes): add git-rebase + docker-network from todo` or similar consolidated form

**Step 6: Clean up smoke-test artifacts (optional)**

If you don't want the test notes to remain:

```bash
git rm notes/git-rebase.md notes/docker-network.md
git commit -m "chore: drop split smoke-test artifacts"
```

Or keep them — they're real notes.

---

## Task 7: Final repo state verification

**Files:**
- No changes — read-only audit.

**Step 1: Verify all introduced files are committed**

Run:
```bash
git status
```

Expected: `nothing to commit, working tree clean`.

**Step 2: Verify the new files are in the repo**

Run:
```bash
test -f .claude/commands/process-todo.md && echo "slash command OK"
test -f todo/.gitkeep && echo "gitkeep OK"
test -f todo/README.md && echo "todo README OK"
```

Expected: all three print "OK".

**Step 3: Verify recent commit history**

Run:
```bash
git log --oneline -10
```

Expected: at minimum, two commits with the subjects:
- `chore(todo): scaffold capture folder with usage README`
- `feat(commands): add /process-todo project slash command`

Plus any smoke-test commits if you ran Tasks 5/6.

**Step 4: Confirm Claude Code sees the new slash command**

This requires opening Claude Code and typing `/` to see the command list. Confirm `/process-todo` appears in the project-level commands. If not, the file path or frontmatter is wrong.

If `/process-todo` is missing from the list:
- Verify the file path is exactly `.claude/commands/process-todo.md`
- Verify the frontmatter parses cleanly (YAML between `---` lines, no syntax errors)
- Restart the Claude Code session if needed

---

## Notes for the implementer

- **No tests, no runtime code.** This plan creates 3 documentation/configuration files. The "verification" is reading the prompt against the spec (Task 3) and optional smoke tests (Tasks 4–6).
- **The slash command's prompt is the implementation.** Quality matters there. If the prompt is vague, the runtime behavior will be inconsistent. Keep it explicit and rule-driven.
- **English-only enforcement.** The user has an active memory that all repo-resident artifacts must be in English. This includes the slash command prompt, the `todo/README.md`, commit messages, and any content the slash command itself generates at runtime.
- **Smoke tests are interactive.** Tasks 4–6 require invoking the command in Claude Code and reviewing its output. They can be skipped if the user is comfortable trusting the audit in Task 3, but they're the only way to catch runtime prompt issues (e.g., the slash command being too vague to produce a plan, or producing wrong commit messages).

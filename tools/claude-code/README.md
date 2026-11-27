# Claude Code — Setup

Setup of [Claude Code](https://claude.com/claude-code) (Anthropic's CLI) with my personal plugins, on Windows and Fedora.

- [Install the plugin list](#install-the-plugin-list)
- [What each plugin needs](#what-each-plugin-needs)
- [Windows](#windows) — portable Node 24 next to an old work Node, Java 25 for jdtls
- [Fedora](#fedora)

## Prerequisites
- Claude Code installed (`claude` available in `PATH`)
- The `claude-plugins-official` marketplace (configured by default; check with `claude plugin marketplace list`)

## Install the plugin list

Fedora / Git Bash:
```bash
./install-plugins.sh
```

Windows (`cmd` or double-click):
```bat
install-plugins.bat
```

Both scripts install the same list of plugins at user scope (available in every project). They can be re-run: plugins already installed are skipped. A plugin that fails does not stop the others, and the failed ones are listed at the end.

After installing, run `/reload-plugins` in Claude Code or restart it.

The plugins only install the Claude Code side. The LSP plugins and Playwright also need tools installed on the machine: see [What each plugin needs](#what-each-plugin-needs).

### What the plugins are for

| Plugin | Use |
|---|---|
| superpowers | Workflow skills: brainstorming, plans, TDD, systematic debugging, verification before "done" |
| feature-dev | `/feature-dev`: guided feature work with explorer, architect and reviewer agents |
| code-review | `/code-review`: multi-agent review of a pull request |
| pr-review-toolkit | Specialized review agents: comments, tests, error handling, type design, code quality |
| code-simplifier | Agent that cleans up recently changed code without changing behavior |
| security-guidance | Security warnings while Claude edits, diff review when it stops |
| claude-security | `/claude-security`: in-depth vulnerability scan by a team of agents that challenge each finding |
| code-modernization | `/code-modernization:modernize`: assessment, code map, business rules mined from the code and migration plan for a legacy codebase |
| claude-md-management | Audit `CLAUDE.md` files and add what a session learned |
| hookify | Create hooks from a plain sentence ("never run `mvn deploy`") |
| session-report | `/session-report`: HTML report of Claude Code usage (tokens, cache efficiency, subagents, skills, most expensive prompts). For the current session: `/cost`; for plan limits: `/usage` |
| claude-code-setup | Recommends hooks, skills and MCP servers for a codebase |
| skill-creator | Create, test and tune skills |
| frontend-design | Distinctive UI design instead of templated defaults |
| ralph-loop | `/ralph-loop`: Claude repeats the same task until it is done |
| context7 | Up-to-date library documentation |
| playwright | Drive a browser: test pages, screenshots, forms |
| pyright-lsp, typescript-lsp, jdtls-lsp | Language servers: type errors and navigation for Python, TypeScript/JavaScript, Java |

All of them come from the official `claude-plugins-official` marketplace. Most are written by Anthropic. superpowers (Jesse Vincent), playwright (Microsoft) and context7 (Upstash) are third-party plugins listed there.

Review overlaps: superpowers, `code-review`, `pr-review-toolkit` and Claude Code's built-in `/code-review` all do code review. `pr-review-toolkit` is the most detailed.

### Plugin settings
code-modernization and claude-security have settings with working defaults: `/plugin configure <plugin>@claude-plugins-official` in Claude Code changes them. Both send usage counts (whole numbers: which command ran, how many findings…) through Claude Code's telemetry. Turn it off with the `telemetry` setting of code-modernization, or for everything with the `DISABLE_TELEMETRY=1` environment variable.

### Add a new plugin
Add a line in the format `name@marketplace` to **both** scripts (`plugins` array in `install-plugins.sh`, `for` list in `install-plugins.bat`), then re-run the script.

### `qodo-skills` is gone
`qodo-skills@claude-plugins-official` no longer exists in the marketplace (`Plugin "qodo-skills" not found`), so it was removed from the list. The marketplace now has `qodo` (Qodo codebase intelligence, coding standards and code review), probably its replacement, and `qodo-standards`. Neither is installed for now.

## What each plugin needs

| Plugin | Needs on the machine |
|---|---|
| superpowers, code-simplifier, code-review, frontend-design, ralph-loop, claude-code-setup, skill-creator, security-guidance, feature-dev, pr-review-toolkit, claude-md-management, session-report | Nothing |
| hookify | `python3` in `PATH` (its hooks run `python3 .../pretooluse.py`) |
| claude-security | Python 3.9+ in `PATH`. A git checkout to scan changes. Reading findings from hosted Claude Security needs the Claude Security connector from claude.ai |
| code-modernization | Nothing required. Optional: `python3` (map, report), [`scc`](https://github.com/boyter/scc) or `cloc` (size metrics), the legacy project's build toolchain (runs old and new side by side). `/code-modernization:modernize-preflight` checks them |
| context7 | Nothing: hosted remote MCP server. Authenticate once when Claude Code asks (`/mcp`) |
| playwright | **Node 20+** (starts `npx @playwright/mcp@latest`) and Chrome |
| pyright-lsp | `pyright-langserver` in `PATH` (npm package `pyright`, Node 14+) |
| typescript-lsp | `typescript-language-server` in `PATH` (npm packages `typescript-language-server` and `typescript`). `typescript-language-server` 6.x needs **Node 22.22.2+** |

Node versions above come from the `engines` field of each npm package (November 2026). Check one with `npm view <package> engines`.
| jdtls-lsp | `jdtls` in `PATH`, Python 3, and **Java 25** for the current jdtls snapshots (November 2026). Older releases ran on Java 21 |

## Windows

The work PC must keep **Node 12** (`node -v` → `v12.22.12`), too old for Playwright and the language servers. A second, portable Node 24 is added next to it, without changing which `node` the terminal uses.

### 1. Two portable Node versions
Download the **Windows x64 zip** of Node 24 LTS from <https://nodejs.org/dist/latest-v24.x/> (`node-v24.x.x-win-x64.zip`, not the `.msi`) and extract it next to the existing one:
```
C:\Users\<user>\Documents\work\Programs\node\node-v12.22.12-win-x64
C:\Users\<user>\Documents\work\Programs\node\node-v24.22.3-win-x64
```

Create two system variables and put both in the system `Path`, **work Node first**:

| Variable | Value |
|---|---|
| `NODE_REDPEAKS` | `...\Programs\node\node-v12.22.12-win-x64` |
| `NODE_CLAUDE` | `...\Programs\node\node-v24.22.3-win-x64` |

```
Path: ...;%NODE_REDPEAKS%;%NODE_CLAUDE%;...
```

How it works: Windows uses the first `Path` folder that contains the command.
- `node`, `npm`, `npx` exist in both folders → the Node 12 ones win, so work projects are unchanged.
- The tools below are installed **only** in the Node 24 folder → found there. Their `.cmd` launchers start the `node.exe` sitting next to them, so they run on Node 24 even though `node` is Node 12.

To install something on the Node 24 side, call its npm by full path (a plain `npm install -g` would use Node 12 and install into the Node 12 folder):
```bat
"%NODE_CLAUDE%\npm.cmd" install -g <package>
```

### 2. pyright and TypeScript language servers
```bat
"%NODE_CLAUDE%\npm.cmd" install -g pyright typescript typescript-language-server
```
They land in `%NODE_CLAUDE%` (`pyright-langserver.cmd`, `typescript-language-server.cmd`, `tsc.cmd`).

### 3. Playwright MCP on Node 24
The plugin starts `npx @playwright/mcp@latest`: here `npx` is the Node 12 one and the server crashes (`/mcp` shows `Connection closed`). Calling the Node 24 `npx.cmd` by full path is **not** enough either: the package's launcher starts the `node` from `Path`, still Node 12 (`SyntaxError: Unexpected token '.'`).

Install the server in the Node 24 folder, register it as a user MCP server, and disable the plugin's copy:
```bat
"%NODE_CLAUDE%\npm.cmd" install -g @playwright/mcp@latest
claude mcp add -s user playwright -- "C:\Users\<user>\Documents\work\Programs\node\node-v24.22.3-win-x64\playwright-mcp.cmd"
claude plugin disable playwright@claude-plugins-official
```
Update later with the same `npm install -g @playwright/mcp@latest`.

> **Re-running `install-plugins.bat` re-enables the plugin** (`claude plugin install` on an installed but disabled plugin turns it back on). Run the `claude plugin disable` line again afterwards.

> On a Windows machine whose `node` is already 20+, skip this step: the plugin works as is.

### 4. jdtls (Java)
Java 25 is needed by the current jdtls (the work JDK 21 is not enough). Extract a JDK 25 zip (e.g. [Temurin 25](https://adoptium.net/temurin/releases/?version=25&os=windows&arch=x64&package=jdk)) to `...\Programs\java\` and point `JAVA_HOME` to it.

Download jdtls and extract it to `...\Programs\jdt-language-server-latest`:
- latest snapshot: <https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz>
- or a stable release: <https://download.eclipse.org/jdtls/milestones/>
```bat
mkdir C:\Users\<user>\Documents\work\Programs\jdt-language-server-latest
tar -xzf jdt-language-server-latest.tar.gz -C C:\Users\<user>\Documents\work\Programs\jdt-language-server-latest
```

Create a launcher `...\Programs\jdtls-launcher\jdtls.cmd`:
```bat
@echo off
python "C:\Users\<user>\Documents\work\Programs\jdt-language-server-latest\bin\jdtls" %*
```
and add `...\Programs\jdtls-launcher` to the system `Path`.

Don't add the jdtls `bin` folder to `Path` instead: its `jdtls.bat` ends with `pause`, which waits for a key press when the server stops.

> If `JAVA_HOME` must stay on Java 21 for work, make the launcher pick Java 25 itself: add `--java-executable "C:\...\Programs\java\jdk-25...\bin\java.exe"` after the `jdtls` path.

### 5. Restart Claude Code
It reads `Path` and `JAVA_HOME` when it starts.

## Fedora

Fedora's own packages are recent enough: no second Node needed.

### 1. Node and the language servers
```bash
sudo dnf install -y nodejs npm
node -v
```
`node -v` must show 22.22.2 or later (needed by `typescript-language-server`).

Install global npm packages in `~/.local` (already in `PATH` on Fedora) to avoid `sudo npm`:
```bash
npm config set prefix ~/.local
npm install -g pyright typescript typescript-language-server
```

### 2. Playwright
The plugin works as is with Fedora's Node. It drives Chrome, which comes from Google's repository:
```bash
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager setopt google-chrome.enabled=1
sudo dnf install -y google-chrome-stable
```
Under WSL, the browser window opens through WSLg.

### 3. jdtls (Java)
Java 25 next to the default Java 21 (check the available versions with `dnf list 'java-*-openjdk-devel'`):
```bash
sudo dnf install -y java-25-openjdk-devel python3
```

Download and extract jdtls:
```bash
mkdir -p ~/.local/share/jdtls
curl -L -o /tmp/jdtls.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
tar -xzf /tmp/jdtls.tar.gz -C ~/.local/share/jdtls
```

Create a launcher that uses Java 25 without changing the system `java`:
```bash
cat > ~/.local/bin/jdtls <<'EOF'
#!/usr/bin/env bash
exec "$HOME/.local/share/jdtls/bin/jdtls" --java-executable /usr/lib/jvm/java-25-openjdk/bin/java "$@"
EOF
chmod +x ~/.local/bin/jdtls
```

### 4. Restart Claude Code

## Verification
- `claude plugin list`: every plugin of the scripts is listed and enabled (except `playwright` on the Windows work PC, disabled on purpose)
- `/mcp` in Claude Code: `playwright` and `context7` are connected
- The language servers are found:
  ```bash
  pyright --version
  typescript-language-server --version
  ```
  On Windows, `where pyright-langserver typescript-language-server jdtls` must show the Node 24 folder and `jdtls-launcher`.
- Open a `.py`, `.ts` or `.java` file with Claude Code: type errors show up as diagnostics after an edit

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `Plugin "<name>" not found in marketplace` | Renamed or removed plugin. Refresh with `claude plugin marketplace update claude-plugins-official`, then look for the new name in `~/.claude/plugins/marketplaces/claude-plugins-official/.claude-plugin/marketplace.json` |
| `/mcp`: `playwright` → `Connection closed` | `node` in `PATH` is too old. Run the server by hand to see the error: `npx -y @playwright/mcp@latest --version`. On Windows, see [Playwright MCP on Node 24](#3-playwright-mcp-on-node-24) |
| `SyntaxError: Unexpected token '.'` from a Node tool | It runs on Node 12 (no `?.` support): it was started with the `node` from `PATH` instead of Node 24 |
| jdtls prints `An error has occurred. See the log file` | Read the `.log` file in the `configuration` folder that appears in the jdtls folder. `Require-Capability: osgi.ee; filter:="(&(osgi.ee=JavaSE)(version=25))"` means jdtls needs Java 25. Delete that `configuration` folder after fixing |
| `jdtls requires at least Java 21` | `JAVA_HOME` (or `--java-executable`) points to an older JDK |
| A language server is not used | Claude Code was started before `PATH` changed: restart it |

## Sources
- Claude Code plugins: <https://code.claude.com/docs/en/plugins>
- Eclipse JDT Language Server: <https://github.com/eclipse-jdtls/eclipse.jdt.ls>
- Playwright MCP: <https://github.com/microsoft/playwright-mcp>

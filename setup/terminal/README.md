# Terminal — Starship + JetBrains Mono

Setup of the [Starship](https://starship.rs/) prompt and the JetBrains Mono font (Nerd Font for icons).

- [Fedora (WSL)](#steps) — bash + Starship
- [Windows — WezTerm + Git Bash](#windows--wezterm--git-bash) — same look on Windows

## Steps

### 1. JetBrains Mono font (Fedora package)
```bash
sudo dnf install jetbrains-mono-fonts-all
```

### 2. Install Starship
```bash
command -v starship || echo "starship absent"
dnf copr enable atim/starship -y
dnf install starship -y
```

### 3. Enable Starship in bash
Add to `~/.bashrc`:
```bash
eval "$(starship init bash)"
```

### 4. Starship config
Copy the `starship.toml` file and the `maven-version.sh` script (next to this README):
```bash
mkdir -p ~/.config/starship
cp starship.toml ~/.config/starship.toml
cp maven-version.sh ~/.config/starship/maven-version.sh
```
See [Starship modules](#starship-modules) for what the custom modules do.

### 5. (Optional) Nerd Font for icons
If you see squares instead of Java / Git / etc. icons:
```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
cd /tmp
curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont
sudo fc-cache -fv
```

> A local copy of the Nerd Font archive is also in [`../../assets/fonts/JetBrainsMono-2.304.zip`](../../assets/fonts/JetBrainsMono-2.304.zip).

## Verification
- New shell → Starship prompt visible
- `starship --version` responds
- Nerd Font characters (e.g. ` java`) render correctly in the terminal

## Windows — WezTerm + Git Bash

[WezTerm](https://wezterm.org/) opens Git Bash by default, with JetBrains Mono, the Starship prompt and a Catppuccin-based dark theme.

### Pre-requisites
- [Git for Windows](https://git-scm.com/download/win) (provides Git Bash at `C:\Program Files\Git\bin\bash.exe`)
- **WezTerm nightly** (see below)
- JetBrains Mono installed on Windows (the plain font is enough: WezTerm ships its own Nerd Font symbols as fallback)

#### Use the nightly build, not the stable one
The last stable WezTerm release is `20240203-110809-5046fc22` (February 2024), and no stable release has been published since: every fix ships in the nightly build only (985 commits between that stable and nightly `20261123`). On Windows the stable build freezes when the window is resized or a pane is split, especially with WSL panes.

Install the nightly, either:
- with winget: `winget install wez.wezterm.nightly` (update later with `winget upgrade wez.wezterm.nightly`)
- or with the installer from the [official page](https://wezterm.org/install/windows.html): [`WezTerm-nightly-setup.exe`](https://github.com/wezterm/wezterm/releases/download/nightly/WezTerm-nightly-setup.exe). This link always points to the latest nightly build. Re-run it to update.

If the stable build is installed, uninstall it first. The config (`~/.wezterm.lua`) lives in the home folder and is not removed by the uninstaller, but keep a copy if you use a cleaner such as Revo Uninstaller.

Check: `wezterm --version` shows a date-based version from the current year (e.g. `20261126-084800-c41674ce`), not `20240203`.

### 1. WezTerm config
Copy the `wezterm.lua` file (next to this README) to `~/.wezterm.lua` (`C:\Users\<user>\.wezterm.lua`):
```bash
cp wezterm.lua ~/.wezterm.lua
```
WezTerm reloads the config automatically on save.

> Don't use `default_prog = { "/usr/bin/bash" }` on Windows: that path only exists in Linux/WSL, and WezTerm fails with `Process "/usr/bin/bash" ... didn't exit cleanly. Exited with code 1`.

### 2. Starship in Git Bash
```bash
winget install --id Starship.Starship -e
mkdir -p ~/.config/starship
cp starship.toml ~/.config/starship.toml
cp maven-version.sh ~/.config/starship/maven-version.sh
```
Add to `~/.bashrc` (the PATH fallback covers shells started before the installer updated the Windows PATH):
```bash
# Prompt Starship (voir homelab/setup/terminal)
if ! command -v starship >/dev/null 2>&1 && [ -x "/c/Program Files/starship/bin/starship.exe" ]; then
  export PATH="$PATH:/c/Program Files/starship/bin"
fi
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
```

### What the config sets
- **Shell**: `C:\Program Files\Git\bin\bash.exe --login -i`, started in the home folder
- **Font**: JetBrains Mono 12.5, line height 1.1, ligatures on, `Symbols Nerd Font Mono` fallback for icons
- **Theme**: custom "Hyprland inspired" colors (background `#0F111A`, Catppuccin palette), 0.90 opacity, blinking bar cursor
- **Tabs**: bar at the bottom, hidden when only one tab is open
- **Rendering**: OpenGL front end, 120 fps max

> **Why OpenGL and not WebGpu**: with `front_end = 'WebGpu'`, WezTerm froze on every resize. The machine has two AMD GPUs (Radeon iGPU + RX 7900 XTX) and the window uses 0.90 opacity, and WebGpu has to rebuild its swapchain on each resize. OpenGL is stable. To try WebGpu again on the nightly build, replace the `front_end` line with:
> ```lua
> config.front_end = 'WebGpu'
> config.webgpu_power_preference = 'HighPerformance'
> ```
> If it freezes again, also try `window_background_opacity = 1.0`, or force `wezterm-gui.exe` on the high-performance GPU in Windows Settings → Display → Graphics.

### Shortcuts

| Shortcut | Action |
|---|---|
| `Alt+H` | Split horizontal (panes side by side) |
| `Alt+V` | Split vertical (panes stacked) |
| `Alt+←` `→` `↑` `↓` | Move between panes |
| `Alt+Q` | Close current pane (no confirmation) |
| `Ctrl+Shift+T` | New tab |
| `Alt` + left click drag | Move the window |

Alt is used instead of Ctrl because `Ctrl+H` (backspace), `Ctrl+V` (quoted insert) and `Ctrl+Q` (XON) are taken by the terminal. `Alt+T` is left to bash (transpose words).

### Verification
- `wezterm --version` shows a nightly version (not `20240203`)
- Launch WezTerm → Git Bash opens with the Starship prompt
- `wezterm ls-fonts --text "abc"` shows `JetBrains Mono` being used
- `Alt+H` / `Alt+V` split the window; resizing the window or going fullscreen with split panes does not freeze

## Starship modules

`starship.toml` is shared by Fedora (WSL) and Git Bash. On top of the defaults, it sets:

| Module | What it does | Why |
|---|---|---|
| `format` | Explicit order: user, directory, git, svn, package version, Java, then everything else (`$all`) | Keeps svn next to git and the versions in their usual place, since custom modules are otherwise added at the end |
| `custom.svn` | Shows the SVN relative URL in SVN working copies | No built-in SVN module |
| `java` (disabled) → `custom.java` | Reads `JAVA_VERSION` from `$JAVA_HOME/release` (or, without `JAVA_HOME`, from the JDK the `java` on the `PATH` points to) | The built-in module runs `java -Xinternalversion` on every prompt: ~1 s on Windows, which made each `cd` into a Java project slow (2.1 s prompt → 0.13 s). Same source as before (`JAVA_HOME`), just without starting a JVM |
| `maven` | Symbol set to the Nerd Font Maven icon (`U+E674`) | The default `🅼` (`U+1F17C`) exists in none of the fonts WezTerm loads and was not displayed |
| `custom.mvnversion` | Shows the Maven project version when `pom.xml` uses a `${property}` or inherits it from the parent, using `maven-version.sh` | The built-in `package` module only reads a literal `<version>` in `pom.xml` and shows nothing otherwise |

### `maven-version.sh`
Pure bash (no external process, ~30 ms under Git Bash). When the project version is a literal, it prints nothing and the built-in `package` module shows it, so there is no duplicate. Otherwise it resolves the property from, in order:
1. `.mvn/maven.config` (`-Dprop=value`)
2. the project `pom.xml`
3. the parent POMs, up to 5 levels: `relativePath` (default `../pom.xml`) if its `artifactId` matches, else `~/.m2/repository`

Example: `redpeaks-collector` has `<version>${application.version}</version>` and the value (`7.0.15`) is defined in the parent `com.redpeaks.core:com-redpeaks-core:2.1.0`.

Limit: if the parent POM was never downloaded to `~/.m2` (project never built), the version cannot be resolved and nothing is shown. `mvn help:evaluate` would always work but takes several seconds per prompt.

## Troubleshooting

| Symptom | Check |
|---|---|
| WezTerm freezes on resize / split | `wezterm --version`: install the nightly build; keep `front_end = 'OpenGL'` |
| Prompt slow in some folders | `starship timings` in that folder lists the time per module |
| An icon is missing (empty or square) | `wezterm ls-fonts --text "<char>"`: `glyph=.notdef` means no loaded font has it, pick a Nerd Font icon instead |
| `maven-version.sh` errors with `$'\r'` | The script got CRLF line endings: it must be LF (enforced by `.gitattributes` in this folder) |

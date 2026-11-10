# IntelliJ IDEA — application menu entry (tarball install in /opt, Fedora KDE)

IntelliJ IDEA Ultimate installed from the JetBrains tarball in `/opt/intellij/`, with a menu entry
that survives IntelliJ restarts and version upgrades.

## Layout

```
/opt/intellij/
├── idea-IU-<version>/          # extracted tarball, one folder per version
└── current -> idea-IU-<version>  # symlink used by the menu entry
```

## Menu entry

File: `~/.local/share/applications/jetbrains-idea.desktop`

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA
Icon=/opt/intellij/current/bin/idea.svg
Exec="/opt/intellij/current/bin/idea" %f
Comment=The Leading IDE for Professional Development in Java and Kotlin
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
StartupNotify=true
```

Refresh the menu database (as the user, **without sudo**):

```bash
update-desktop-database ~/.local/share/applications/
```

## Upgrade to a new version

```bash
sudo tar -xzf ~/Downloads/idea-<version>.tar.gz -C /opt/intellij/
sudo ln -sfn /opt/intellij/idea-IU-<build> /opt/intellij/current
```

The menu entry does not change: it always points to `/opt/intellij/current`.

## Pitfall: never use `jetbrainsd.desktop`

The IntelliJ entry used to disappear from the menu every time IntelliJ was closed.

- Cause: the entry was written to `~/.local/share/applications/jetbrainsd.desktop`. That file
  belongs to the **JetBrains Daemon** (`~/.local/share/JetBrains/Daemon/`), the handler for
  `jetbrains://` links. On each IntelliJ run, the daemon rewrites it with its own content
  (`Name=JetBrains`, `NoDisplay=true`, `MimeType=x-scheme-handler/jetbrains`), which hides the entry.
- Fix: keep the IntelliJ entry in its own file (`jetbrains-idea.desktop`) and leave
  `jetbrainsd.desktop` to the daemon (needed for `jetbrains://` links).
- Do not run `update-desktop-database` with sudo: it makes `mimeinfo.cache` owned by root.

Diagnosed and verified on 2026-11-05 (start/close test, entry stays in the menu).

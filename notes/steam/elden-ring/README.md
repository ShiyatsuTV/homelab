# Elden Ring — Fedora KDE Plasma (Steam Flatpak)

Notes for my Elden Ring install, launched through **Steam as a Flatpak** on
**Fedora 44 KDE Plasma**. Anti-cheat disabled + Seamless Coop.

> Everything about the **controller** (DualSense / Steam Input / uinput) lives in
> a separate note: [`../controller-dualsense.md`](../controller-dualsense.md).

---

## Important paths

**Game folder:**

```
~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/ELDEN RING/Game
```

**Save folder** (the number is my SteamID):

```
~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/76561198172308146
```

Handy shortcuts (paste into a terminal):

```bash
GAME="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/ELDEN RING/Game"
SAVES="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/76561198172308146"
```

---

## Key files in the game folder

| File                                | Approx. size | Role                                     |
|-------------------------------------|--------------|------------------------------------------|
| `eldenring.exe`                     | ~87 MB       | The actual game                          |
| `eldenring.exe.original`            | ~87 MB       | My backup copy of the game               |
| `start_protected_game.exe`          | variable     | **What Steam launches** (see states below) |
| `start_protected_game.exe.original` | ~3.9 MB      | The **real EAC launcher**, saved         |
| `ersc_launcher.exe`                 | ~175 KB      | The Seamless Coop mod launcher           |
| `SeamlessCoop/` (folder)            | —            | Holds `ersc.dll` + `ersc_settings.ini`   |

**The file that decides everything is `start_protected_game.exe`.** Steam always
executes that one; its content determines the play mode:

| Size of `start_protected_game.exe` | What launches                            |
|------------------------------------|------------------------------------------|
| ~3.9 MB (copy of `.original`)      | **Vanilla + EAC** (official online)       |
| ~175 KB (copy of `ersc_launcher`)  | **Seamless Coop**                         |
| ~87 MB (copy of `eldenring.exe`)   | Vanilla **without** EAC (offline, no mod) |

Check the current state:

```bash
cd "$GAME"
ls -l start_protected_game.exe*
```

---

## Anti-cheat (EAC) — disable / re-enable

EAC blocks mods. The principle: Steam always launches
`start_protected_game.exe`, so that file gets swapped depending on what should run.

### Disable EAC (vanilla game, no anti-cheat, no mod)

```bash
cd "$GAME"
mv start_protected_game.exe start_protected_game.exe.original   # save the real EAC (if not done yet)
cp eldenring.exe start_protected_game.exe                        # the game takes its place
```

### Re-enable EAC (official online)

```bash
cd "$GAME"
cp start_protected_game.exe.original start_protected_game.exe    # restore the real EAC
```

> ⚠️ **Never play official online with EAC disabled or the mod active — risk of a
> ban.** EAC off means offline, or coop through the mod only.

---

## Seamless Coop — enable / disable

Mod: **Elden Ring Seamless Co-op** (ersc), installed version **v1.9.8**.
Official repo: https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease/releases/latest

### Enable the mod

```bash
cd "$GAME"
# if the original EAC has not been saved yet:
[ -f start_protected_game.exe.original ] || mv start_protected_game.exe start_protected_game.exe.original
# the mod launcher takes its place
cp ersc_launcher.exe start_protected_game.exe
```

Then launch **Elden Ring normally from Steam** (no launch option to change, the
controller line stays untouched). On the main menu, a **Seamless Coop** label
plus its version number appears at the bottom of the screen when the mod is active.

### Disable the mod (back to vanilla + official online)

```bash
cd "$GAME"
cp start_protected_game.exe.original start_protected_game.exe
```

Equally valid alternative: Steam → right-click Elden Ring → Properties →
Installed Files → **Verify integrity of game files** (restores the original exe).

### Configure coop (password)

Edit the mod settings file:

```bash
nano "$GAME/SeamlessCoop/ersc_settings.ini"
```

Under `[PASSWORD]`, set `cooppassword = <shared_password>`.
**Every player needs the same password AND the same mod version (1.9.8).**

### Update the mod later

1. Download the new `ersc.zip` from the releases page linked above, under **Assets**.
2. Extract it into the game folder:

   ```bash
   unzip -o ~/Downloads/ersc.zip -d "$GAME"
   ```

3. Re-apply the activation (copy the launcher again):

   ```bash
   cp "$GAME/ersc_launcher.exe" "$GAME/start_protected_game.exe"
   ```

4. `ersc_settings.ini` may get overwritten — check the password again.

---

## Saves

Two distinct files, inside `$SAVES`:

- `ER0000.sl2` → **vanilla** save (solo / official online)
- `ER0000.co2` → **Seamless Coop** save (created by the mod)

The mod only writes to the `.co2`, so the vanilla `.sl2` is never touched by coop.

### Import a save from another PC

I imported my `.co2` from my Windows PC by dropping it straight into:

```
$SAVES
```

(the folder named after the SteamID). Works as-is.

### Manual safety backup (do this before any manipulation)

```bash
cp -r "$SAVES" "$HOME/eldenring-saves-backup-$(date +%Y%m%d)"
```

> The `.co2` only shows up after launching the mod and creating or loading a coop
> character at least once.

---

## Summary of the possible states

Switching modes is a single command — replace `start_protected_game.exe` with the
right source:

```bash
cd "$GAME"

# --- Official online (vanilla + EAC) ---
cp start_protected_game.exe.original start_protected_game.exe

# --- Seamless Coop ---
cp ersc_launcher.exe start_protected_game.exe

# --- Vanilla without EAC (offline, no mod) ---
cp eldenring.exe start_protected_game.exe
```

Check which one is active:

```bash
ls -l "$GAME"/start_protected_game.exe*
# ~3.9 MB = EAC | ~175 KB = coop mod | ~87 MB = vanilla no-EAC
```

---

## Notes / pitfalls

- **After a game update by Steam**, `start_protected_game.exe` can be rewritten with
  the real EAC — the wanted mode has to be re-applied.
- **The Steam launch line never changes** between modes; it is always the controller
  line (see [`../controller-dualsense.md`](../controller-dualsense.md)). Do NOT use
  the `sed`-based EAC bypass in the Launch Options, it breaks the launch together
  with the SDL variables.
- **Never play official online with the mod or EAC off** — ban.
- All coop players: same mod version + same password.

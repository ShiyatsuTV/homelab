# DualSense controllers + Steam (Flatpak) + Elden Ring — Fedora KDE Plasma

Troubleshooting notes to get a DualSense controller working inside a game launched
through Steam installed as a **Flatpak**, on **Fedora 44 KDE Plasma**.

Original symptom: the controller is recognised in the Steam UI but **not in the game**.

---

## My controllers (USB IDs)

| Controller           | Vendor:Product | Launch option format |
|----------------------|----------------|----------------------|
| DualSense (standard) | `054c:0ce6`    | `0x054c/0x0ce6`      |
| DualSense Edge (pro) | `054c:0df2`    | `0x054c/0x0df2`      |

To find the ID of a controller (plugged in):

```bash
lsusb | grep -iE "sony|microsoft|nintendo|8bitdo|controller|gamepad"
```

The returned line contains `ID xxxx:yyyy` → `xxxx` is the vendor, `yyyy` the product.
In the launch option it becomes `0xxxxx/0xyyyy`.

---

## Elden Ring launch option (the final setting)

In Steam: **right-click Elden Ring → Properties → General → Launch Options**, paste
on **a single line**:

```
SDL_JOYSTICK_HIDAPI_PS5=0 SDL_GAMECONTROLLER_IGNORE_DEVICES=0x054c/0x0ce6,0x054c/0x0df2 %command%
```

This covers **both controllers** — either one can be plugged in with no change.

### What each part does

- `SDL_JOYSTICK_HIDAPI_PS5=0`: forces SDL not to read the DualSense through its raw
  HID driver.
- `SDL_GAMECONTROLLER_IGNORE_DEVICES=0x054c/0x0ce6,0x054c/0x0df2`: hides the
  **physical** DualSense devices from SDL, so the game only sees the virtual
  X-Box 360 controller created by Steam Input.
- Multiple IDs are separated by a **comma with no space**.

### Adding a new controller later

1. Plug it in, get its ID with the `lsusb` command above.
2. Append it to the list, comma-separated. Example with a third controller
   `045e/028e`:

   ```
   SDL_JOYSTICK_HIDAPI_PS5=0 SDL_GAMECONTROLLER_IGNORE_DEVICES=0x054c/0x0ce6,0x054c/0x0df2,0x045e/0x028e %command%
   ```

> Note: a native **Xbox / XInput** controller is often recognised directly by Elden
> Ring without Steam Input, so it does not necessarily need to be ignored.

---

## System setup (to redo after a reinstall)

These three links must all be in place for Steam Input to be able to **create** its
virtual controller. This was the root cause of the problem.

### 1. Flatpak overrides — give Steam access to devices and `/dev/uinput`

```bash
flatpak override --user --device=all com.valvesoftware.Steam
flatpak override --user --filesystem=/dev/uinput com.valvesoftware.Steam
```

Check:

```bash
cat ~/.local/share/flatpak/overrides/com.valvesoftware.Steam
```

Should contain:

```
[Context]
devices=all;
filesystems=/dev/uinput;
```

### 2. udev rule — give the right permissions to `/dev/uinput`

By default `/dev/uinput` belongs to `root:root` with no group permissions. Switch it
to `root:input` with read/write for the group:

```bash
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo modprobe uinput
```

Check:

```bash
ls -l /dev/uinput
# expected: crw-rw----. 1 root input ...
```

### 3. `input` group — add the user

```bash
sudo usermod -aG input serkan
```

**Requires logging out and back in (or a reboot)** to take effect.

Check after reboot:

```bash
groups
# must contain: input
```

---

## Steam Input settings (UI)

### Global — Steam → Settings → Controller

- **PlayStation controller support: Enabled** ← mandatory
- The rest (Xbox / Switch Pro / generic) can stay unchecked.

### Per game — Elden Ring → Properties → Controller

- **Override for Elden Ring: Enable Steam Input** (forced, not "default")
- Expected status: blue dot **"PlayStation: Enabled, per-game override"**

After any Steam Input setting change: **quit Steam completely** (Steam menu → Exit,
not just closing the window), then relaunch.

---

## Diagnostics — check each link

### Is the physical controller seen by the system?

```bash
lsusb                                    # shows up in the USB list
grep -iE -A5 "dualsense|sony" /proc/bus/input/devices   # look for Handlers=eventXX jsX
```

The real gamepad is the one whose `N: Name=` is the main name (not "Motion Sensors",
"Touchpad" or "Headset Jack") and that has a `jsX` handler.

### Test buttons and sticks at system level (game closed)

```bash
sudo dnf install evtest   # once
sudo evtest /dev/input/eventXX   # replace XX with the gamepad event
```

Press buttons and sticks → should print `BTN_SOUTH`, `ABS_X`, etc.
(Events scrolling without touching anything means stick **drift**.)

### Is the Steam Input virtual controller created? (game running)

```bash
watch -n 1 'grep -iE -A1 "steam|x-box|xbox|360 pad" /proc/bus/input/devices'
```

Launch Elden Ring. Once **in game** (past the EasyAntiCheat screen), a
**"Microsoft X-Box 360 pad"** line must appear.

- **It appears** → Steam Input works. If the game still does not respond, it is the
  **duplicate** problem (physical + virtual controller seen at the same time) — the
  `SDL_GAMECONTROLLER_IGNORE_DEVICES` option fixes that.
- **It does not appear** → `/dev/uinput` problem (go back over the three system setup
  steps).

> Do not filter on the word "virtual": many devices have `/devices/virtual/` in their
> Sysfs path, which creates false positives.

---

## If it still does not work — alternative leads

- **Try stable Proton (9.0-4) instead of Experimental**: Experimental sometimes has
  controller regressions. (Elden Ring → Properties → Compatibility)
- **Opposite strategy — fully native, no Steam Input**: disable Steam Input for Elden
  Ring, disable "PlayStation controller support" in Steam, and let the kernel
  (`hid_playstation`) drive the DualSense directly. In that case, remove the
  `SDL_GAMECONTROLLER_IGNORE_DEVICES` option.
- **Test with and without EasyAntiCheat** when launching the game.
- **PS button in game**: if it opens the Steam overlay, Steam Input does capture the
  controller (the issue is then the mapping); otherwise the game runs outside the
  Steam Input scope.

---

## Note on stick drift

Masking drift (it does not physically repair it): Steam → Elden Ring controller
config → increase the **deadzone** of the affected stick. The DualSense Edge also has
hardware deadzone settings in its own parameters.

---

## Root cause summary

Three stacked problems:

1. Steam's Flatpak sandbox had no access to `/dev/uinput` → the virtual controller
   could not be created.
2. `/dev/uinput` was `root:root` with no group permissions, and the user was not in
   the `input` group.
3. Once the virtual controller existed, the game saw **two** controllers (physical +
   virtual) and locked onto the wrong one.

All three had to be fixed for the chain **uinput → Steam Input → game** to work
end to end.

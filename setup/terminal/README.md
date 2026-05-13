# Terminal — Starship + JetBrains Mono

Setup of the [Starship](https://starship.rs/) prompt and the JetBrains Mono font (Nerd Font for icons).

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
Copy the `starship.toml` file (next to this README) to `~/.config/starship.toml`:
```bash
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml
```

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

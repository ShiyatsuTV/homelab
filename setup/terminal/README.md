# Terminal — Starship + JetBrains Mono

Setup du prompt [Starship](https://starship.rs/) et de la police JetBrains Mono (Nerd Font pour les icônes).

## Étapes

### 1. Police JetBrains Mono (paquet Fedora)
```bash
sudo dnf install jetbrains-mono-fonts-all
```

### 2. Installer Starship
```bash
command -v starship || echo "starship absent"
dnf copr enable atim/starship -y
dnf install starship -y
```

### 3. Activer Starship dans bash
Ajouter à `~/.bashrc` :
```bash
eval "$(starship init bash)"
```

### 4. Config Starship
Copier le fichier `starship.toml` (à côté de ce README) dans `~/.config/starship.toml` :
```bash
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml
```

### 5. (Optionnel) Nerd Font pour les icônes
Si tu vois des carrés à la place des icônes Java / Git / etc. :
```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
cd /tmp
curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont
sudo fc-cache -fv
```

> Une copie locale de l'archive Nerd Font est aussi dans [`../../assets/fonts/JetBrainsMono-2.304.zip`](../../assets/fonts/JetBrainsMono-2.304.zip).

## Vérification
- Nouveau shell → prompt Starship visible
- `starship --version` répond
- Caractères Nerd Font (ex: ` java`) s'affichent correctement dans le terminal

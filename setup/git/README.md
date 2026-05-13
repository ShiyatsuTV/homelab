# Git — Install + config globale

## Install
```bash
sudo dnf install git -y
```

## Config globale
```bash
git config --global user.name "ShiyatsuTV"
git config --global user.email "shiyatsu70@gmail.com"
git config --global credential.helper store
```

> `credential.helper store` stocke les credentials en clair dans `~/.git-credentials`. OK pour usage perso sur machine de confiance.

## Vérification
```bash
git config --global --list
```
Doit afficher `user.name`, `user.email`, `credential.helper`.

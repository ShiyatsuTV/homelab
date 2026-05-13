# WSL + Fedora — Install

Procédure d'installation de WSL2 et de Fedora 42 sur Windows, avec les paquets de base.

## Pré-requis
- Windows 10/11 avec WSL2 supporté

## Étapes

### 1. Installer WSL (PowerShell, Windows)
```powershell
wsl --install
```
Redémarrer le PC, puis :
```powershell
wsl --status
wsl --list --online
wsl --install FedoraLinux-42
```

### 2. Paquets de base (dans Fedora)
```bash
sudo dnf install update
sudo dnf install -y ncurses util-linux coreutils
sudo dnf install -y fastfetch
sudo dnf install -y htop
sudo dnf install java-21-openjdk
sudo dnf install java-21-openjdk-devel
```

## Vérification
- `wsl --list -v` (Windows) doit afficher `FedoraLinux-42` en running
- `fastfetch` s'exécute correctement dans Fedora

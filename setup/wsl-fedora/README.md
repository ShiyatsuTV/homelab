# WSL + Fedora — Install

Procedure to install WSL2 and Fedora 42 on Windows, with the baseline packages.

## Prerequisites
- Windows 10/11 with WSL2 support

## Steps

### 1. Install WSL (PowerShell, Windows)
```powershell
wsl --install
```
Reboot, then:
```powershell
wsl --status
wsl --list --online
wsl --install FedoraLinux-42
```

### 2. Baseline packages (inside Fedora)
```bash
sudo dnf install update
sudo dnf install -y ncurses util-linux coreutils
sudo dnf install -y fastfetch
sudo dnf install -y htop
sudo dnf install java-21-openjdk
sudo dnf install java-21-openjdk-devel
```

## Verification
- `wsl --list -v` (Windows) must show `FedoraLinux-42` as running
- `fastfetch` runs correctly inside Fedora

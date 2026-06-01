# Citrix Workspace App (Linux)

Install procedure for the Citrix Workspace app from the tarball package, tested on Fedora 44 (KDE Plasma).

## Prerequisites
Download the latest tarball package from the official page:
<https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html>

## Steps

### 1. Extract and install
```bash
mkdir ~/citrix-tarball && cd ~/citrix-tarball
tar -xzf ~/Downloads/linuxx86_64-*.tar.gz
sudo ./setupwfc
```
Keep all defaults during setup.

### 2. Fix ownership
```bash
chown -R serkan:serkan /opt/Citrix/ICAClient
```

### 3. Install missing libraries (Fedora 44 / KDE Plasma)
Required on Fedora 44 during installation:
```bash
sudo dnf install libsoup webkit2gtk4.0
```

### 4. (Optional) Associate `.ica` files with wfica
```bash
xdg-mime default wfica.desktop application/x-ica
```

## Verification
Launch a session from an `.ica` file:
```bash
/opt/Citrix/ICAClient/wfica YOUR_FILE.ica
```

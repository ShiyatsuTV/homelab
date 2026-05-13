# FortiClient VPN — openfortivpn

CLI client for FortiClient VPN on Linux.

## Install
```bash
sudo dnf install openfortivpn
```

## Config
Edit `/etc/openfortivpn/config`:
```bash
sudo nano /etc/openfortivpn/config
```

Minimal content (the cert hash is specific to my endpoint):
```
trusted-cert = 0502f1d6af02dad9b7d46c6cfc1bc247af07e7c22ad5febda43d3c3752cabf02
```

Then add the `host`, `port`, `username`, `password` options as needed.

## Run
```bash
sudo openfortivpn
```

## Verification
- Connection established without error
- `ip a` shows the `ppp0` interface (or equivalent)

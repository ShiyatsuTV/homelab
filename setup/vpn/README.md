# FortiClient VPN — openfortivpn

Client CLI pour VPN FortiClient sur Linux.

## Install
```bash
sudo dnf install openfortivpn
```

## Config
Éditer `/etc/openfortivpn/config` :
```bash
sudo nano /etc/openfortivpn/config
```

Contenu minimal (le cert hash est spécifique à mon endpoint) :
```
trusted-cert = 0502f1d6af02dad9b7d46c6cfc1bc247af07e7c22ad5febda43d3c3752cabf02
```

Ajouter ensuite les options `host`, `port`, `username`, `password` selon le besoin.

## Lancer
```bash
sudo openfortivpn
```

## Vérification
- Connexion établie sans erreur
- `ip a` montre l'interface `ppp0` (ou équivalent)

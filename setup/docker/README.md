# Docker — Install sur Fedora

Installation de Docker CE sur Fedora avec ajout de l'utilisateur au groupe `docker`.

## Étapes

### 1. Supprimer les anciennes versions
```bash
sudo dnf remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine
```

### 2. Installer Docker CE
```bash
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

### 3. Ajouter ton user au groupe docker
```bash
sudo groupadd docker
sudo usermod -aG docker shiyatsu
getent group docker
```

Se déconnecter / reconnecter pour activer le groupe dans la session.

## Vérification
- `docker run hello-world` fonctionne **sans `sudo`**
- `docker --version` répond

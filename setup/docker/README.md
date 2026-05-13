# Docker — Install on Fedora

Docker CE install on Fedora, with the user added to the `docker` group.

## Steps

### 1. Remove old versions
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

### 2. Install Docker CE
```bash
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

### 3. Add your user to the docker group
```bash
sudo groupadd docker
sudo usermod -aG docker shiyatsu
getent group docker
```

Log out / log back in to activate the group in the session.

## Verification
- `docker run hello-world` works **without `sudo`**
- `docker --version` responds

# Jenkins

Placeholder for self-hosted Jenkins in Docker.

## What it does
`run.sh` isn't written yet — this folder currently serves as a memo on Jenkins post-install.

## Post-install: let jenkins use Docker

Once Jenkins is installed, the `jenkins` user has no access to the Docker socket by default. To let it build images / run containers:

```bash
# Check the docker group
getent group docker

# Add the jenkins user to the docker group
sudo usermod -aG docker jenkins

# Restart Jenkins so the new membership is picked up
sudo systemctl restart jenkins
```

## Verification

```bash
sudo -u jenkins -g docker docker ps
```
Must list containers without permission errors.

# Jenkins

Placeholder pour Jenkins auto-hébergé en Docker.

## À quoi ça sert
Le `run.sh` n'est pas encore écrit — ce dossier sert pour l'instant de mémo sur la post-install Jenkins.

## Post-install : autoriser jenkins à utiliser Docker

Une fois Jenkins installé, l'utilisateur `jenkins` n'a pas accès au socket Docker par défaut. Pour qu'il puisse builder des images / lancer des containers :

```bash
# Vérifier le groupe docker
getent group docker

# Ajouter l'utilisateur jenkins au groupe docker
sudo usermod -aG docker jenkins

# Redémarrer Jenkins pour que la nouvelle appartenance soit prise en compte
sudo systemctl restart jenkins
```

## Vérification

```bash
sudo -u jenkins -g docker docker ps
```
Doit lister les containers sans erreur de permission.

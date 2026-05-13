# Repo Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Réorganiser le repo `homelab` selon l'arborescence hybride à 5 catégories définie dans le spec, en migrant les fichiers existants et en éclatant `wsl.txt` en fichiers thématiques markdown.

**Architecture:** Repo de documentation personnelle, structure hybride (setup/services/scripts/tools/notes + assets), markdown pour la doc, bash pour les scripts. Repo privé GitHub.

**Tech Stack:** Markdown, Bash, Git, `.gitignore` avec exceptions.

**Spec :** [`docs/superpowers/specs/2026-05-13-repo-organization-design.md`](../specs/2026-05-13-repo-organization-design.md)

---

## File Structure

### Fichiers créés
- `.gitignore`
- `README.md` (réécrit en index)
- `setup/wsl-fedora/README.md`
- `setup/terminal/README.md`
- `setup/terminal/starship.toml`
- `setup/docker/README.md`
- `setup/git/README.md`
- `setup/svn/README.md`
- `setup/vpn/README.md`
- `services/victoriametrics/README.md`
- `services/redpeaks/README.md`
- `services/dokuwiki/README.md`
- `services/dokuwiki/run.sh`
- `services/jenkins/.gitkeep`
- `tools/claude-code/README.md`
- `notes/.gitkeep`

### Fichiers déplacés / renommés
- `victoria_run.sh` → `services/victoriametrics/run.sh`
- `collector_run.sh` → `services/redpeaks/run.sh`
- `clean-all.sh` → `scripts/docker-clean.sh`
- `install-claude-plugins.sh` → `tools/claude-code/install-plugins.sh`
- `JetBrainsMono-2.304.zip` → `assets/fonts/JetBrainsMono-2.304.zip`
- `jenkins_docker/` → `services/jenkins/`

### Fichiers supprimés
- `wsl.txt` (contenu réparti dans les fichiers `setup/*/README.md` et `services/dokuwiki/`)

### Note
Les fichiers à la racine (`clean-all.sh`, `victoria_run.sh`, etc.) sont actuellement **non-trackés** par Git (vérifier avec `git status`). On utilise donc `mv` simple, pas `git mv`.

---

## Task 1: Foundation — `.gitignore` + squelette de dossiers

**Files:**
- Create: `.gitignore`
- Create: `setup/wsl-fedora/`, `setup/terminal/`, `setup/docker/`, `setup/git/`, `setup/svn/`, `setup/vpn/`
- Create: `services/victoriametrics/`, `services/redpeaks/`, `services/dokuwiki/`, `services/jenkins/`
- Create: `scripts/`, `tools/claude-code/`, `assets/fonts/`, `notes/`
- Create: `services/jenkins/.gitkeep`, `notes/.gitkeep`

- [ ] **Step 1: Écrire le `.gitignore`**

Contenu de `.gitignore` :

```gitignore
# Archives téléchargeables
*.zip
*.tar.gz

# Exception : assets versionnés (polices, etc.)
!assets/**/*.zip
!assets/**/*.tar.gz

# Secrets locaux
.env
.env.local
*.key
*.pem

# OS / éditeurs
.DS_Store
.idea/
.vscode/
*.swp
```

- [ ] **Step 2: Créer toute l'arborescence de dossiers**

Run:
```bash
mkdir -p setup/wsl-fedora setup/terminal setup/docker setup/git setup/svn setup/vpn
mkdir -p services/victoriametrics services/redpeaks services/dokuwiki services/jenkins
mkdir -p scripts tools/claude-code assets/fonts notes
```

- [ ] **Step 3: Créer les `.gitkeep` pour les dossiers vides**

Run:
```bash
touch services/jenkins/.gitkeep notes/.gitkeep
```

- [ ] **Step 4: Vérifier la structure**

Run: `find . -type d -not -path './.git*' -not -path './docs*' | sort`

Expected (les dossiers existent) :
```
.
./assets
./assets/fonts
./notes
./scripts
./services
./services/dokuwiki
./services/jenkins
./services/redpeaks
./services/victoriametrics
./setup
./setup/docker
./setup/git
./setup/svn
./setup/terminal
./setup/vpn
./setup/wsl-fedora
./tools
./tools/claude-code
```

- [ ] **Step 5: Vérifier le `.gitignore`**

Run: `cat .gitignore | head -20`
Expected: voir les règles ci-dessus.

- [ ] **Step 6: Commit**

```bash
git add .gitignore services/jenkins/.gitkeep notes/.gitkeep
git commit -m "chore: setup directory structure + .gitignore"
```

---

## Task 2: Migrer `victoria_run.sh` → `services/victoriametrics/`

**Files:**
- Move: `victoria_run.sh` → `services/victoriametrics/run.sh`
- Create: `services/victoriametrics/README.md`

- [ ] **Step 1: Déplacer et renommer le script**

Run:
```bash
mv victoria_run.sh services/victoriametrics/run.sh
chmod +x services/victoriametrics/run.sh
```

- [ ] **Step 2: Créer `services/victoriametrics/README.md`**

Contenu :

````markdown
# VictoriaMetrics

Base de données time-series compatible Prometheus + Graphite.

## À quoi ça sert
Stockage local de métriques pour le homelab. Reçoit en Graphite plain text et expose une UI/API HTTP.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP / UI : http://localhost:8428
- Ingestion Graphite : `localhost:2003`

## Données
Volume Docker : `victoriametrics-v1.143.0-8428-2003-data` (pattern `victoriametrics-<version>-<ports>-data`)

## Notes
- Version pinnée dans `run.sh` (variable `VICTORIA_VERSION`)
- `--restart=always` : le container redémarre au boot Docker
- Le script fait un `docker rm -f` du container existant avant de relancer
````

- [ ] **Step 3: Vérifier**

Run: `ls -la services/victoriametrics/`
Expected: voir `README.md` et `run.sh` (exécutable, ligne `-rwxr-xr-x`).

Run: `test ! -f victoria_run.sh && echo "moved OK"`
Expected: `moved OK`

- [ ] **Step 4: Commit**

```bash
git add services/victoriametrics/
git commit -m "feat(services): migrate victoriametrics run script + add README"
```

---

## Task 3: Migrer `collector_run.sh` → `services/redpeaks/`

**Files:**
- Move: `collector_run.sh` → `services/redpeaks/run.sh`
- Create: `services/redpeaks/README.md`

- [ ] **Step 1: Déplacer et renommer le script**

Run:
```bash
mv collector_run.sh services/redpeaks/run.sh
chmod +x services/redpeaks/run.sh
```

- [ ] **Step 2: Créer `services/redpeaks/README.md`**

Contenu :

````markdown
# Redpeaks

Outil de monitoring/supervision applicatif (image privée `redpeaks:*`).

## À quoi ça sert
Container Tomcat-based pour faire tourner Redpeaks en local.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP : http://localhost:8888
- HTTPS : https://localhost:8883

## Données (volumes Docker nommés)
- `redpeaks-8888-certificates`
- `redpeaks-8888-drivers`
- `redpeaks-8888-db`
- `redpeaks-8888-import`
- `redpeaks-8888-logs`
- `redpeaks-8888-snapshots`
- `redpeaks-8888-tmp-drivers`
- `redpeaks-8888-update`
- `redpeaks-8888-worker-libs`
- `redpeaks-8888-workers`

## Notes
- Version d'image pinnée dans `run.sh` (variable `IMAGE`)
- `--add-host=host.docker.internal:host-gateway` permet au container d'atteindre la machine hôte
- Pour nettoyer entièrement (containers + images + volumes) : `../../scripts/docker-clean.sh redpeaks`
````

- [ ] **Step 3: Vérifier**

Run: `ls -la services/redpeaks/`
Expected: voir `README.md` et `run.sh` exécutable.

Run: `test ! -f collector_run.sh && echo "moved OK"`
Expected: `moved OK`

- [ ] **Step 4: Commit**

```bash
git add services/redpeaks/
git commit -m "feat(services): migrate redpeaks run script + add README"
```

---

## Task 4: Migrer `clean-all.sh` → `scripts/docker-clean.sh`

**Files:**
- Move: `clean-all.sh` → `scripts/docker-clean.sh`

- [ ] **Step 1: Déplacer et renommer**

Run:
```bash
mv clean-all.sh scripts/docker-clean.sh
chmod +x scripts/docker-clean.sh
```

- [ ] **Step 2: Vérifier**

Run: `ls -la scripts/`
Expected: `docker-clean.sh` exécutable.

Run: `test ! -f clean-all.sh && echo "moved OK"`
Expected: `moved OK`

Run: `head -10 scripts/docker-clean.sh`
Expected: shebang + l'usage "Usage: docker-clean.sh <prefix-ou-nom>".

- [ ] **Step 3: Commit**

```bash
git add scripts/docker-clean.sh
git commit -m "feat(scripts): migrate clean-all.sh as docker-clean.sh"
```

---

## Task 5: Migrer `install-claude-plugins.sh` → `tools/claude-code/`

**Files:**
- Move: `install-claude-plugins.sh` → `tools/claude-code/install-plugins.sh`
- Create: `tools/claude-code/README.md`

- [ ] **Step 1: Déplacer et renommer**

Run:
```bash
mv install-claude-plugins.sh tools/claude-code/install-plugins.sh
chmod +x tools/claude-code/install-plugins.sh
```

- [ ] **Step 2: Créer `tools/claude-code/README.md`**

Contenu :

````markdown
# Claude Code — Setup

Setup de [Claude Code](https://claude.com/claude-code) (CLI Anthropic) avec les plugins perso.

## Pré-requis
- Claude Code installé (`claude` disponible dans le PATH)

## Installer la liste de plugins perso
```bash
./install-plugins.sh
```

Le script installe tous les plugins listés dans le tableau `plugins` (superpowers, code-review, frontend-design, feature-dev, etc.).

## Ajouter un nouveau plugin
Éditer `install-plugins.sh` et ajouter une ligne au tableau `plugins` au format `"nom@registre"`. Puis relancer le script.

## Vérification
Run :
```bash
claude plugin list
```
Tous les plugins du tableau doivent apparaître.
````

- [ ] **Step 3: Vérifier**

Run: `ls -la tools/claude-code/`
Expected: voir `README.md` et `install-plugins.sh` exécutable.

Run: `test ! -f install-claude-plugins.sh && echo "moved OK"`
Expected: `moved OK`

- [ ] **Step 4: Commit**

```bash
git add tools/claude-code/
git commit -m "feat(tools): migrate Claude Code install script + add README"
```

---

## Task 6: Déplacer `JetBrainsMono-2.304.zip` → `assets/fonts/`

**Files:**
- Move: `JetBrainsMono-2.304.zip` → `assets/fonts/JetBrainsMono-2.304.zip`

- [ ] **Step 1: Déplacer**

Run:
```bash
mv JetBrainsMono-2.304.zip assets/fonts/JetBrainsMono-2.304.zip
```

- [ ] **Step 2: Vérifier que `.gitignore` autorise l'exception**

Run: `git check-ignore -v assets/fonts/JetBrainsMono-2.304.zip`
Expected: la sortie indique que le fichier **n'est pas** ignoré (la règle `!assets/**/*.zip` s'applique). Si la commande retourne le fichier comme ignoré, c'est un bug à corriger dans `.gitignore`.

Note : `git check-ignore` retourne exit code 0 si le fichier est ignoré, 1 sinon. On veut **1** (donc la commande sort "rien" et exit 1). Tu peux tester explicitement :

```bash
git check-ignore -v assets/fonts/JetBrainsMono-2.304.zip; echo "exit=$?"
```
Expected: `exit=1`

- [ ] **Step 3: Vérifier que le fichier est listé par git**

Run: `git status --short assets/fonts/`
Expected: `?? assets/fonts/JetBrainsMono-2.304.zip` (le `??` indique untracked mais visible).

- [ ] **Step 4: Commit**

```bash
git add assets/fonts/JetBrainsMono-2.304.zip
git commit -m "chore(assets): store JetBrains Mono font archive"
```

---

## Task 7: Renommer `jenkins_docker/` → `services/jenkins/`

**Files:**
- Le dossier `jenkins_docker/` est vide. `services/jenkins/.gitkeep` existe déjà depuis Task 1.

- [ ] **Step 1: Vérifier que `jenkins_docker/` est bien vide**

Run: `ls -la jenkins_docker/ 2>/dev/null && find jenkins_docker -type f`
Expected: aucun fichier dans `jenkins_docker/`.

- [ ] **Step 2: Supprimer l'ancien dossier**

Run:
```bash
rmdir jenkins_docker
```

- [ ] **Step 3: Vérifier**

Run: `test ! -d jenkins_docker && test -d services/jenkins && echo "OK"`
Expected: `OK`

- [ ] **Step 4: Pas de commit nécessaire**

`jenkins_docker/` n'a jamais été commité (dossier vide untracked). Le `.gitkeep` de `services/jenkins/` a été commité dans Task 1. Aucune action git ici.

---

## Task 8: Extraire `wsl.txt` → `setup/wsl-fedora/README.md`

**Files:**
- Create: `setup/wsl-fedora/README.md`

Source : `wsl.txt` lignes 1-16 (install WSL + Fedora + dnf de base).

- [ ] **Step 1: Créer le fichier**

Contenu de `setup/wsl-fedora/README.md` :

````markdown
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
````

- [ ] **Step 2: Vérifier**

Run: `head -5 setup/wsl-fedora/README.md`
Expected: titre `# WSL + Fedora — Install` et début du contenu.

- [ ] **Step 3: Commit**

```bash
git add setup/wsl-fedora/README.md
git commit -m "docs(setup): add WSL + Fedora install procedure"
```

---

## Task 9: Extraire `wsl.txt` → `setup/terminal/`

**Files:**
- Create: `setup/terminal/README.md`
- Create: `setup/terminal/starship.toml`

Source : `wsl.txt` lignes 17-62 (terminal section : starship, fonts, nerd-fonts).

- [ ] **Step 1: Créer `setup/terminal/starship.toml`**

Contenu :

```toml
add_newline = false

[username]
show_always = true
format = "[$user]($style) "

[hostname]
ssh_only = true
format = "[@$hostname]($style) "

[character]
success_symbol = "❯"
error_symbol = "❯"

[directory]
truncation_length = 0
truncate_to_repo = false
home_symbol = "~"

[custom.svn]
when = "svn info >/dev/null 2>&1"
command = "svn info --show-item relative-url 2>/dev/null | sed 's#^\\^/##'"
format = " on [ $output]($style)"
```

- [ ] **Step 2: Créer `setup/terminal/README.md`**

Contenu :

````markdown
# Terminal — Starship + JetBrains Mono

Setup du prompt [Starship](https://starship.rs/) et de la police JetBrains Mono (Nerd Font pour les icônes).

## Étapes

### 1. Police JetBrains Mono (paquet Fedora)
```bash
sudo dnf install jetbrains-mono-fonts-all
```

### 2. Installer Starship
```bash
command -v starship || echo "starship absent"
dnf copr enable atim/starship -y
dnf install starship -y
```

### 3. Activer Starship dans bash
Ajouter à `~/.bashrc` :
```bash
eval "$(starship init bash)"
```

### 4. Config Starship
Copier le fichier `starship.toml` (à côté de ce README) dans `~/.config/starship.toml` :
```bash
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml
```

### 5. (Optionnel) Nerd Font pour les icônes
Si tu vois des carrés à la place des icônes Java / Git / etc. :
```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
cd /tmp
curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont
sudo fc-cache -fv
```

> Une copie locale de l'archive Nerd Font est aussi dans [`../../assets/fonts/JetBrainsMono-2.304.zip`](../../assets/fonts/JetBrainsMono-2.304.zip).

## Vérification
- Nouveau shell → prompt Starship visible
- `starship --version` répond
- Caractères Nerd Font (ex: ` java`) s'affichent correctement dans le terminal
````

- [ ] **Step 3: Vérifier**

Run: `ls setup/terminal/`
Expected: `README.md  starship.toml`

Run: `grep -c "starship" setup/terminal/README.md`
Expected: ≥ 3 (le mot apparaît plusieurs fois).

- [ ] **Step 4: Commit**

```bash
git add setup/terminal/
git commit -m "docs(setup): add terminal (starship + fonts) procedure + config"
```

---

## Task 10: Extraire `wsl.txt` → `setup/docker/README.md`

**Files:**
- Create: `setup/docker/README.md`

Source : `wsl.txt` lignes 63-84 (Docker section).

- [ ] **Step 1: Créer le fichier**

Contenu :

````markdown
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
````

- [ ] **Step 2: Vérifier**

Run: `head -3 setup/docker/README.md`
Expected: titre `# Docker — Install sur Fedora`.

- [ ] **Step 3: Commit**

```bash
git add setup/docker/README.md
git commit -m "docs(setup): add Docker install procedure for Fedora"
```

---

## Task 11: Extraire `wsl.txt` → `setup/svn/README.md`

**Files:**
- Create: `setup/svn/README.md`

Source : `wsl.txt` lignes 85-88 (SVN section).

- [ ] **Step 1: Créer le fichier**

Contenu :

````markdown
# SVN — Install

## Install
```bash
sudo dnf install -y subversion
```

## Vérification
```bash
svn --version
```
````

- [ ] **Step 2: Commit**

```bash
git add setup/svn/README.md
git commit -m "docs(setup): add SVN install note"
```

---

## Task 12: Extraire `wsl.txt` → `setup/git/README.md`

**Files:**
- Create: `setup/git/README.md`

Source : `wsl.txt` lignes 89-96 (Git section).

- [ ] **Step 1: Créer le fichier**

Contenu :

````markdown
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
````

- [ ] **Step 2: Commit**

```bash
git add setup/git/README.md
git commit -m "docs(setup): add Git install + global config"
```

---

## Task 13: Extraire `wsl.txt` → `setup/vpn/README.md`

**Files:**
- Create: `setup/vpn/README.md`

Source : `wsl.txt` lignes 97-102 (FortiClient VPN section).

- [ ] **Step 1: Créer le fichier**

Contenu :

````markdown
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
````

- [ ] **Step 2: Commit**

```bash
git add setup/vpn/README.md
git commit -m "docs(setup): add openfortivpn install + config note"
```

---

## Task 14: Extraire `wsl.txt` → `services/dokuwiki/`

**Files:**
- Create: `services/dokuwiki/README.md`
- Create: `services/dokuwiki/run.sh`

Source : `wsl.txt` lignes 103-106 (Dokuwiki section).

- [ ] **Step 1: Créer `services/dokuwiki/run.sh`**

Contenu :

```bash
#!/usr/bin/env bash
set -euo pipefail

docker run -d \
  -p 8080:8080 \
  --user 1000:1000 \
  -v dokuwiki_data:/storage \
  dokuwiki/dokuwiki:2024-02-06b
```

- [ ] **Step 2: Rendre exécutable**

Run:
```bash
chmod +x services/dokuwiki/run.sh
```

- [ ] **Step 3: Créer `services/dokuwiki/README.md`**

Contenu :

````markdown
# Dokuwiki

Wiki personnel auto-hébergé en Docker.

## À quoi ça sert
Stockage de notes en wiki accessible via navigateur. Alternative GUI à un repo Git de markdown.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP : http://localhost:8080

## Données
Volume Docker : `dokuwiki_data` (mappé sur `/storage` dans le container)

## Notes
- Image `dokuwiki/dokuwiki:2024-02-06b` (tag pinné, à mettre à jour manuellement)
- Le container tourne en `--user 1000:1000` (pas root)
- Pas de `--name` ni `--restart=always` pour l'instant — à enrichir si besoin
````

- [ ] **Step 4: Vérifier**

Run: `ls -la services/dokuwiki/`
Expected: voir `README.md` et `run.sh` exécutable.

- [ ] **Step 5: Commit**

```bash
git add services/dokuwiki/
git commit -m "feat(services): add dokuwiki run script + README"
```

---

## Task 15: Supprimer `wsl.txt`

**Files:**
- Delete: `wsl.txt`

À ce stade, tout le contenu de `wsl.txt` a été migré dans les fichiers `setup/*/README.md` et `services/dokuwiki/`. On peut supprimer la source.

- [ ] **Step 1: Vérification pré-suppression**

Vérifier que chaque section de `wsl.txt` a bien un fichier cible.

Run:
```bash
test -f setup/wsl-fedora/README.md && \
test -f setup/terminal/README.md && \
test -f setup/terminal/starship.toml && \
test -f setup/docker/README.md && \
test -f setup/svn/README.md && \
test -f setup/git/README.md && \
test -f setup/vpn/README.md && \
test -f services/dokuwiki/README.md && \
test -f services/dokuwiki/run.sh && \
echo "All target files present"
```
Expected: `All target files present`

- [ ] **Step 2: Vérifier la présence des keywords critiques dans les destinations**

S'assurer qu'aucune info clé n'est perdue.

Run:
```bash
grep -l "FedoraLinux-42" setup/wsl-fedora/README.md
grep -l "starship" setup/terminal/README.md
grep -l "docker-ce" setup/docker/README.md
grep -l "subversion" setup/svn/README.md
grep -l "credential.helper" setup/git/README.md
grep -l "0502f1d6af02dad9b7d46c6cfc1bc247af07e7c22ad5febda43d3c3752cabf02" setup/vpn/README.md
grep -l "dokuwiki/dokuwiki:2024-02-06b" services/dokuwiki/run.sh
```
Expected: chaque commande retourne le path du fichier (donc le keyword est présent).

- [ ] **Step 3: Supprimer `wsl.txt`**

Run:
```bash
rm wsl.txt
```

- [ ] **Step 4: Vérifier**

Run: `test ! -f wsl.txt && echo "wsl.txt removed"`
Expected: `wsl.txt removed`

- [ ] **Step 5: Pas de commit nécessaire**

`wsl.txt` n'a jamais été commité (untracked). Sa suppression du filesystem suffit. Si tu veux vérifier : `git status` ne doit plus mentionner `wsl.txt`.

---

## Task 16: Réécrire le `README.md` racine en index

**Files:**
- Modify: `README.md`

Le README actuel ne contient que `# homelab`. On le réécrit comme un vrai index.

- [ ] **Step 1: Écrire le nouveau README**

Contenu de `README.md` :

```markdown
# homelab

Repo personnel de centralisation : notes, documentation et scripts perso.

## Organisation

| Dossier | Contenu |
|---|---|
| [`setup/`](setup/) | Procédures d'install machine (WSL, Docker, Git, terminal, VPN…) |
| [`services/`](services/) | Services auto-hébergés en Docker (VictoriaMetrics, Redpeaks, Dokuwiki, Jenkins) |
| [`scripts/`](scripts/) | Scripts utilitaires transverses |
| [`tools/`](tools/) | Setup et config d'outils utilisés (Claude Code, etc.) |
| [`notes/`](notes/) | Cheatsheets et mémos divers (à remplir au fil de l'eau) |
| [`assets/`](assets/) | Binaires et archives (polices, etc.) |
| [`docs/`](docs/) | Specs et plans internes (workflow Superpowers) |

## Conventions

- Documentation en **Markdown**, scripts en **Bash `.sh`**
- **Kebab-case** pour noms de dossiers et fichiers (`docker-clean.sh`, `wsl-fedora/`)
- Un **`README.md`** par sous-dossier dès qu'il contient du contenu
- Templates de README : voir [`docs/superpowers/specs/2026-05-13-repo-organization-design.md`](docs/superpowers/specs/2026-05-13-repo-organization-design.md#conventions-internes)

## Zones grises courantes

- `setup/` = procédure d'install (à faire une fois)
- `notes/` = référence rapide (cheatsheet, mémo)
- Un sujet (Docker, Git, …) peut donc apparaître dans les **deux**.
```

- [ ] **Step 2: Vérifier**

Run: `head -5 README.md`
Expected: titre `# homelab` + description.

Run: `wc -l README.md`
Expected: > 20 lignes (l'ancien faisait 1 ligne).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite root README as repo index"
```

---

## Task 17: Vérification finale

- [ ] **Step 1: Vérifier l'arborescence complète**

Run:
```bash
find . -not -path './.git*' -not -path './node_modules*' | grep -v '/$' | sort
```
Expected (au minimum, les chemins suivants existent) :
- `./.gitignore`
- `./README.md`
- `./assets/fonts/JetBrainsMono-2.304.zip`
- `./docs/superpowers/plans/2026-05-13-repo-reorganization.md`
- `./docs/superpowers/specs/2026-05-13-repo-organization-design.md`
- `./notes/.gitkeep`
- `./scripts/docker-clean.sh`
- `./services/dokuwiki/README.md`
- `./services/dokuwiki/run.sh`
- `./services/jenkins/.gitkeep`
- `./services/redpeaks/README.md`
- `./services/redpeaks/run.sh`
- `./services/victoriametrics/README.md`
- `./services/victoriametrics/run.sh`
- `./setup/docker/README.md`
- `./setup/git/README.md`
- `./setup/svn/README.md`
- `./setup/terminal/README.md`
- `./setup/terminal/starship.toml`
- `./setup/vpn/README.md`
- `./setup/wsl-fedora/README.md`
- `./tools/claude-code/README.md`
- `./tools/claude-code/install-plugins.sh`

- [ ] **Step 2: Vérifier qu'aucun fichier ne reste à la racine en dehors de ceux attendus**

Run:
```bash
ls -1 | grep -v '^docs$\|^setup$\|^services$\|^scripts$\|^tools$\|^assets$\|^notes$\|^README.md$\|^\.gitignore$'
```
Expected: **aucune sortie** (toutes les autres entrées sont des dossiers internes au repo ou attendus).

- [ ] **Step 3: Vérifier que les fichiers d'origine ont disparu**

Run:
```bash
for f in wsl.txt clean-all.sh collector_run.sh victoria_run.sh install-claude-plugins.sh JetBrainsMono-2.304.zip jenkins_docker; do
  test ! -e "$f" && echo "OK: $f gone" || echo "STILL THERE: $f"
done
```
Expected: chaque ligne dit `OK: <fichier> gone`.

- [ ] **Step 4: Vérifier les permissions des scripts**

Run:
```bash
ls -l scripts/docker-clean.sh services/*/run.sh tools/claude-code/install-plugins.sh | grep -v 'rwx'
```
Expected: **aucune sortie** (tous les scripts sont exécutables).

- [ ] **Step 5: Vérifier le `git status`**

Run: `git status`
Expected: `nothing to commit, working tree clean` (tous les changements ont été commités au fil des tasks).

- [ ] **Step 6: Vérifier l'historique de commits**

Run: `git log --oneline -20`
Expected: voir une série de commits correspondant aux tasks (chore: setup, feat(services): …, docs(setup): …, docs: rewrite root README, etc.).

- [ ] **Step 7: Lecture rapide sur GitHub (si push fait)**

Si tu pushes (`git push`), va sur la page du repo GitHub et vérifie :
- Le README racine s'affiche avec la table et les liens cliquables
- Cliquer sur un lien (ex: `setup/`) descend dans le dossier
- Les `README.md` de chaque sous-dossier s'affichent avec leur rendu markdown
- Le bloc de code `starship.toml` s'affiche avec coloration

---

## Notes pour l'exécutant

- **Untracked → tracked** : tous les fichiers à la racine au début (`wsl.txt`, `clean-all.sh`, etc.) sont **untracked**. Utilise `mv`, pas `git mv`. Une fois déplacés, `git add` les ajoute au tracking.
- **Permissions** : les scripts source ont déjà le bit exécutable (ils tournaient avant). `chmod +x` est redondant mais explicite — fais-le pour être sûr.
- **Conserver le contenu** : pour les extractions de `wsl.txt`, **garde le contenu tel quel** (commandes, hashs, options). N'améliore pas — on migre d'abord, on raffine ensuite.
- **Ordre des tasks** : Task 1 doit être faite en premier (squelette + `.gitignore`). Les autres tasks (2 à 14) sont **indépendantes** entre elles et peuvent être exécutées dans n'importe quel ordre. Task 15 (suppression de wsl.txt) doit venir après 8-14. Task 16 doit venir en dernier (avant Task 17 qui ne fait que vérifier).
- **Commits fréquents** : 1 commit par task. Si une task échoue, le rollback est facile (`git reset --hard HEAD`).

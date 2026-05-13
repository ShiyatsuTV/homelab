# Design — Organisation du repo `homelab`

**Date :** 2026-05-13
**Statut :** Validé pour implémentation
**Auteur :** Serkan (ShiyatsuTV)

## Contexte

Le repo `homelab` centralise sur GitHub les notes, la documentation et les scripts personnels utilisés au quotidien : procédures d'installation machine, services auto-hébergés en Docker, outils CLI, cheatsheets. Repo **privé** — les informations spécifiques à l'environnement (cert hash VPN, hostnames, chemins) peuvent rester telles quelles.

Le contenu initial est hétérogène :
- Un fichier `wsl.txt` long qui mélange ~7 sujets (install WSL/Fedora, terminal, Docker, Git, SVN, VPN, Dokuwiki)
- Trois scripts Docker (`clean-all.sh`, `collector_run.sh`, `victoria_run.sh`)
- Un script d'install d'outils (`install-claude-plugins.sh`)
- Un dossier vide `jenkins_docker/`
- Une archive de police (`JetBrainsMono-2.304.zip`)
- Un `README.md` quasi vide

L'objectif est de définir une organisation pérenne qui :
1. Reste lisible quand le contenu va croître (notes, services, scripts supplémentaires)
2. Sépare clairement procédures d'install, services en cours d'exécution, et savoir brut
3. Suit des conventions stables (nommage, structure des README) pour éviter le bricolage incrémental

## Décisions clés

| Décision | Choix retenu |
|---|---|
| Axe d'organisation top-level | **Hybride** : 5 catégories logiques (setup, services, scripts, tools, notes) + un dossier `assets/` pour binaires |
| Format de documentation | **Markdown** partout (les `.txt` disparaissent) |
| Format des scripts | **Bash `.sh`** inchangé |
| Visibilité GitHub | **Privé** — pas de sanitisation requise |
| Convention de nommage | **kebab-case** (minuscules + tirets) pour dossiers et fichiers |
| README par sous-dossier | **Oui** dès qu'un sous-dossier contient du contenu |
| Archive de police | **Versionnée** dans `assets/fonts/` avec exception `.gitignore` |

## Arborescence cible

```
homelab/
├── README.md                       # index général, liens vers les sections
├── .gitignore
│
├── setup/                          # procédures d'installation (à faire une fois par machine)
│   ├── wsl-fedora/README.md
│   ├── terminal/
│   │   ├── README.md               # install starship, nerd-fonts, .bashrc
│   │   └── starship.toml           # config réelle, copiable telle quelle
│   ├── docker/README.md
│   ├── git/README.md
│   ├── svn/README.md
│   └── vpn/README.md               # openfortivpn + cert hash
│
├── services/                       # services auto-hébergés (1 dossier = 1 service)
│   ├── victoriametrics/
│   │   ├── README.md
│   │   └── run.sh
│   ├── redpeaks/
│   │   ├── README.md
│   │   └── run.sh
│   ├── dokuwiki/
│   │   ├── README.md
│   │   └── run.sh
│   └── jenkins/                    # placeholder vide
│
├── scripts/                        # utilitaires transverses (pas liés à un service précis)
│   └── docker-clean.sh
│
├── tools/                          # setup/config d'outils utilisés (pas hébergés)
│   └── claude-code/
│       ├── README.md
│       └── install-plugins.sh
│
├── assets/                         # binaires, archives, captures
│   └── fonts/
│       └── JetBrainsMono-2.304.zip
│
└── notes/                          # cheatsheets et mémos (vide initialement)
```

**Note sur les dossiers vides :** Git ne versionne pas les dossiers vides. `services/jenkins/` et `notes/` recevront un fichier `.gitkeep` vide pour exister dans le repo en attendant qu'ils soient peuplés.

## Logique des 5 catégories principales

| Dossier | Quand y mettre quelque chose | Question test |
|---|---|---|
| `setup/` | Procédure d'installation à faire **une fois** sur une machine neuve | "Je viens de réinstaller, qu'est-ce que je refais ?" |
| `services/` | Un truc qui **tourne en continu** chez soi (1 dossier = 1 service) | "Comment je relance ce service ?" |
| `scripts/` | Un script utilitaire **réutilisable**, pas lié à un service précis | "Quel one-liner Docker j'avais déjà écrit ?" |
| `tools/` | Setup et config d'un outil qu'on **utilise** (pas qu'on héberge) | "Comment je configure mon Claude Code / mon IDE ?" |
| `notes/` | Cheatsheets, mémos, savoir brut sans procédure ni script associé | "C'était quoi la syntaxe de X déjà ?" |

**Zone grise courante :** Docker / Git / SVN apparaissent dans `setup/` (procédure d'install) **et** pourront apparaître dans `notes/` (cheatsheet de commandes). C'est volontaire : *procédure ≠ référence*.

## Conventions internes

### Nommage
- Dossiers et fichiers en **kebab-case** : `wsl-fedora/`, `docker-clean.sh`, `victoria-metrics.md`
- Pas de mélange `snake_case` / `kebab-case`

### README par dossier
- Un `README.md` à chaque niveau qui contient quelque chose
- C'est le premier fichier lu quand on entre dans le dossier
- Le `README.md` racine sert d'index général

### Template — README de service

````markdown
# <Nom du service>

## À quoi ça sert
2-3 lignes max.

## Démarrer
```bash
./run.sh
```

## Accès
- HTTP : http://localhost:<port>
- Autres ports si applicable

## Données
Volumes Docker : `<nom-pattern>`

## Notes
Pièges connus, choses à savoir.
````

### Template — Procédure de setup

````markdown
# <Nom de la procédure>

## Pré-requis
Ce qu'il faut avoir avant.

## Étapes
1. ...
2. ...

## Vérification
Comment savoir que ça marche.

## Sources / liens
URL de la doc officielle, etc.
````

### Commandes shell dans les notes
- Toujours dans un code block ` ```bash `
- Une commande par ligne (pas de `&&` qui rend illisible)
- Préfixe `sudo` explicite quand pertinent

## Mapping fichiers existants → nouvelle structure

| Source | Destination | Opération |
|---|---|---|
| `README.md` | `README.md` | **Réécrire** en index général |
| `clean-all.sh` | `scripts/docker-clean.sh` | Déplacer + renommer |
| `collector_run.sh` | `services/redpeaks/run.sh` | Déplacer + renommer + créer `README.md` |
| `victoria_run.sh` | `services/victoriametrics/run.sh` | Déplacer + renommer + créer `README.md` |
| `install-claude-plugins.sh` | `tools/claude-code/install-plugins.sh` | Déplacer + créer `README.md` |
| `jenkins_docker/` (vide) | `services/jenkins/` | Renommer (reste vide, placeholder) |
| `JetBrainsMono-2.304.zip` | `assets/fonts/JetBrainsMono-2.304.zip` | Déplacer |
| `wsl.txt` | éclaté (voir ci-dessous) | Décomposer puis **supprimer** |

### Décomposition de `wsl.txt`

| Bloc de `wsl.txt` | Destination |
|---|---|
| `wsl --install`, install Fedora, dnf de base (htop, java, fastfetch…) | `setup/wsl-fedora/README.md` |
| Section `----- Terminal -----` (starship, jetbrains-mono, nerd-fonts) | `setup/terminal/README.md` + `setup/terminal/starship.toml` |
| Section `---- DOCKER ----` (install Docker + groupe docker) | `setup/docker/README.md` |
| Section `----- SVN -----` | `setup/svn/README.md` |
| Section `----- Git -----` (install + git config global) | `setup/git/README.md` |
| Section `----- FortiClientVPN -----` (cert hash inclus) | `setup/vpn/README.md` |
| Section `----- dokuwiki -----` (la commande `docker run`) | `services/dokuwiki/README.md` + `services/dokuwiki/run.sh` |

Après migration, `wsl.txt` est supprimé.

## `.gitignore` initial

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

## Critères de succès

- [ ] Toute l'arborescence cible existe dans le repo
- [ ] Aucun fichier du listing initial n'est resté à la racine sauf `README.md` et `.gitignore`
- [ ] `wsl.txt` n'existe plus ; son contenu est intégralement réparti dans les fichiers cibles (rien perdu)
- [ ] Chaque service de `services/` a son `README.md` et son `run.sh`
- [ ] Chaque sous-dossier de `setup/` a son `README.md`
- [ ] Le `README.md` racine sert d'index avec liens vers les grandes sections
- [ ] `.gitignore` en place avec exception explicite pour `assets/`
- [ ] Dossiers vides (`services/jenkins/`, `notes/`) contiennent un `.gitkeep`
- [ ] Le repo se clone et se lit correctement sur l'interface GitHub (markdown rendu, liens internes fonctionnels)

## Hors scope

- Migration vers Ansible / Docker Compose / IaC — c'est un autre projet
- Intégration avec Dokuwiki ou tout wiki frontend — la doc vit en markdown dans Git
- Sanitisation pour rendre le repo public — explicitement écarté (repo privé)
- Création de cheatsheets pour `notes/` — à faire au fil de l'eau, pas dans ce chantier
- Refonte du contenu de `wsl.txt` (corrections, mises à jour) — on **migre tel quel** d'abord, on améliore ensuite

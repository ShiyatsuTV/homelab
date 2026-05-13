# Git — Install + global config

## Install
```bash
sudo dnf install git -y
```

## Global config
```bash
git config --global user.name "ShiyatsuTV"
git config --global user.email "shiyatsu70@gmail.com"
git config --global credential.helper store
```

> `credential.helper store` keeps credentials in cleartext in `~/.git-credentials`. Fine for personal use on a trusted machine.

## Verification
```bash
git config --global --list
```
Must show `user.name`, `user.email`, `credential.helper`.

# Jenkins — Install

Install procedure for Jenkins on Linux. Covers Fedora 44 and Ubuntu, plus upgrade and service management.

Upstream documentation: <https://www.jenkins.io/doc/book/installing/linux/>

## Fedora 44

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo dnf upgrade
sudo dnf install fontconfig java-21-openjdk
sudo dnf install jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
```

## Ubuntu

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
```

### Upgrade (Ubuntu)

```bash
sudo apt update
sudo apt install --only-upgrade jenkins
sudo systemctl restart jenkins
```

## First startup

Retrieve the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Then select **Suggested plugins** in the setup wizard.

## Manage the service

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl stop jenkins
```

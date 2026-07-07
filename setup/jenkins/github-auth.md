# Jenkins — GitHub Enterprise Authentication

Configure GitHub Enterprise as the authentication provider and set up a GitHub App credential for pipeline access.

## Required plugins

Install via **Manage Jenkins → Plugins → Available**:

- [GitHub Branch Source](https://plugins.jenkins.io/github-branch-source/)
- [GitHub API](https://plugins.jenkins.io/github-api/)
- [Git Parameter](https://plugins.jenkins.io/git-parameter/)
- [GitHub Authentication](https://plugins.jenkins.io/github-oauth/)

## Create a GitHub App

1. Go to `https://<GHE_HOST>/settings/apps`
2. Click **New GitHub App**:

   | Field | Value |
   |---|---|
   | GitHub App name | `JenkinsHetzner` |
   | Home URL | `http://<JENKINS_HOST>:8080/` |
   | Callback URL | `http://<JENKINS_HOST>:8080/securityRealm/finishLogin` |
   | Webhook | Disabled |
   | Where can this GitHub App be installed? | This enterprise |

3. Click **Create GitHub App**.

### Generate credentials

Go back to `https://<GHE_HOST>/settings/apps/jenkinshetzner` → **General**:

- **Generate a new client secret** → store in Keeper.
- **Generate a private key** → store in Keeper.
- Convert the private key to PKCS8:

```bash
openssl pkcs8 -topk8 -inform PEM -outform PEM \
  -in jenkinshetzner.<DATE>.private-key.pem \
  -out new-key.pem -nocrypt
```

Store both the original `.pem` and `new-key.pem` in Keeper.

### Set permissions

**Permissions & events**:

| Section | Permission | Level |
|---|---|---|
| Repository permissions | Contents | Read-only |
| Repository permissions | Metadata | (mandatory) |
| Account permissions | Email addresses | Read-only |

### Install the app

Go to **Install App** → **Install** → select **All repositories** → confirm.

## Configure Jenkins

### Add GitHub Enterprise server

**Manage Jenkins → System → GitHub Enterprise Servers** → add:

| Field | Value |
|---|---|
| API endpoint | `https://api.<GHE_HOST>` |
| Name | `Redpeaks` |

### Add GitHub App credential

**Manage Jenkins → Credentials → Add Credentials** → kind: **GitHub App**:

| Field | Value |
|---|---|
| ID | `RedpeaksEntreprise` |
| App ID | From the app configuration page |
| API endpoint | `Redpeaks` (created above) |
| Key | Paste contents of `new-key.pem` |

Under **Advanced**:

- Repository access strategy → **Specify accessible repository**
  - Owner: `redpeaks-apps`
  - Repositories: *(leave empty)*
- Default permissions strategy → **Read-only access to repository contents**

Click **Test connection**, then **Create**.

### Enable GitHub authentication

**Manage Jenkins → Security → Authentication**:

**Security Realm** → **GitHub Authentication Plugin**:

| Field | Value |
|---|---|
| GitHub Web URI | `https://<GHE_HOST>` |
| GitHub API URI | `https://api.<GHE_HOST>` |
| Client ID | From the app configuration page |
| Client Secret | From Keeper |
| OAuth Scope(s) | `read:org,user:email,repo` |

**Authorization** → **Project-based Matrix Authorization Strategy**:

- Authenticated Users → check **Administer**

> Restrict this permission once the setup is validated.

## Add Nexus credentials

**Manage Jenkins → Credentials → Add Credentials** for each:

| Credential ID | Value |
|---|---|
| `nexus-deployer-user` | `deployer` |
| `nexus-deployer-password` | From Keeper |
| `nexus-reader-user` | `reader` |
| `nexus-reader-password` | From Keeper |

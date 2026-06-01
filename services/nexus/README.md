# Nexus

Sonatype Nexus Repository 3 self-hosted in Docker.

## What it does
Local artifact repository manager. Used to host and proxy Maven artifacts.

## Running
```bash
docker compose up -d
```

## Access
- HTTP: <http://localhost:8081>
- Wait ~1 min for Nexus to start, then read the generated admin password:
```bash
docker exec nexus cat /nexus-data/admin.password
```
- Log in as `admin` with that password, then change it.

## Data
Named volume `nexus-data` mounted at `/nexus-data`.

## Notes

### Default Maven repositories
- `maven-releases` (hosted) — final versions
- `maven-snapshots` (hosted) — dev versions (`-SNAPSHOT`)
- `maven-public` (group) — for consuming (proxy + hosted combined)

### Allow re-deploying the same version
To push the same jar version more than once, allow redeploy on `maven-releases`:
repo `maven-releases` → Deployment policy → Allow redeploy.

### Create a deployment-only user
1. Settings (gear icon) → Security → Roles → Create role.
2. Type "Nexus role", give it an id such as `deployer-role`.
3. In Privileges, add the ones that allow pushing Maven artifacts:
   - `nx-repository-view-maven2-*-add`
   - `nx-repository-view-maven2-*-edit`
   - `nx-repository-view-maven2-*-read`
4. Save.
5. Security → Users → Create local user: id e.g. `deployer`, a long unique
   password, and assign the `deployer-role` created above.

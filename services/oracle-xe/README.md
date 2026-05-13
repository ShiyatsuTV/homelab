# Oracle XE

Oracle Database Express Edition (21c) self-hosted in Docker.

## What it does
Local Oracle XE instance for development. Multi-tenant: exposes the root `XE` service plus the `xepdb1` and `freepdb1` pluggable databases.

## Running
The local-only `.env` is committed alongside `compose.yaml`. Start the stack:
```bash
docker compose up -d
```
To use a different password, edit `.env` before bringing the stack up.

## Access
- Listener (TCP): `localhost:1521`
- Default service name: `XE` (use `xepdb1` or `freepdb1` for the PDBs)
- Users: `SYS` (must connect as `SYSDBA`) and `SYSTEM`

## Data
Named volume `oracle-data` mounted at `/opt/oracle/oradata`.

## Notes
- Image `container-registry.oracle.com/database/express:latest` requires accepting Oracle's license on the registry.
- JDBC driver: `com.oracle.database.jdbc:ojdbc11:23.8.0.25.04`, tested with JDK 17.0.12 LTS.
- Connection troubleshooting (ORA-28009, ORA-12505): see [`../../notes/oracle.md`](../../notes/oracle.md).

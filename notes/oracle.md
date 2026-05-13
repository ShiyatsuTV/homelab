# Oracle

## Inspect listener services

```bash
docker exec -it oracle-db lsnrctl status
```

The `Services Summary` block lists every entry point the listener exposes:

- `XE` — root container database
- `FREE` — alias for `XE`
- `xepdb1`, `freepdb1` — pluggable databases (PDBs)

Status `READY` means the service accepts connections. Connect via `SYS` or `SYSTEM` to the `XE` database.

## JDBC driver

Coordinates: `com.oracle.database.jdbc:ojdbc11:23.8.0.25.04`
Tested with JDK 17.0.12 LTS.
Reference: <https://mvnrepository.com/artifact/com.oracle.database.jdbc/ojdbc11>

## Troubleshooting

### ORA-28009: connection as SYS should be as SYSDBA or SYSOPER

Add `internal_logon=sysdba` to the connector properties.

Reference: <https://docs.oracle.com/error-help/db/ora-28009>

### ORA-12505: SID not registered with the listener

Triggered when the JDBC URL uses the SID separator (`:`) against a service name. Switch the separator to `/`:

```java
// SID form — wrong here
String connectionURI = "jdbc:oracle:thin:@" + host + ":" + port + ":" + connector.getDatabaseName().trim();

// service-name form
String connectionURI = "jdbc:oracle:thin:@" + host + ":" + port + "/" + connector.getDatabaseName().trim();
```

Reference: <https://docs.oracle.com/error-help/db/ora-12505/>

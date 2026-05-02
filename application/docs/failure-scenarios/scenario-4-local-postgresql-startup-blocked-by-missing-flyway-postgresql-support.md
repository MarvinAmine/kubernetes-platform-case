# Scenario 4 - Local PostgreSQL startup blocked by missing Flyway PostgreSQL support

## Symptom

The Spring Boot application connects to the local PostgreSQL container, but startup still fails before the web layer becomes ready.

Typical error:

- `Unsupported Database: PostgreSQL 16.x`

## Impact

- local development is blocked
- migrations do not run
- the persisted endpoint cannot be tested locally

## Detection

The startup logs usually show this sequence:

- Hikari datasource starts successfully
- PostgreSQL connection is established
- Flyway initialization fails with `Unsupported Database`

## Root cause

`flyway-core` is present, but PostgreSQL-specific Flyway support is missing.

For PostgreSQL 16 local startup, the application also needs:

- `org.flywaydb:flyway-database-postgresql`

## Fix

Add both dependencies to `pom.xml`:

- `org.flywaydb:flyway-core`
- `org.flywaydb:flyway-database-postgresql`

Then rerun:

```bash
./mvnw spring-boot:run
```

## Validation

Successful recovery should show:

- datasource startup completes
- Flyway validates migrations
- Flyway creates `flyway_schema_history`
- migrations are applied
- Tomcat starts on port `8080`

Then the seeded persisted endpoint should work:

```bash
curl http://localhost:8080/api/payment-exceptions/payexc-100045/status
```

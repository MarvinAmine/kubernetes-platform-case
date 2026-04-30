# Local PostgreSQL

This document defines the local development database path for the Payment Exception Review Service.

## Goal

For local development:

- use a local PostgreSQL instance
- avoid depending on Azure infrastructure for day-to-day coding
- keep the same database engine family as the governed cloud environment

For the governed cloud environment:

- use Azure Database for PostgreSQL Flexible Server
- keep the cloud database private
- access it through the application/runtime network path, not directly from a developer laptop

This follows [ADR-010](../../docs/adrs/ADR-010-use-local-postgresql-for-local-development-and-managed-azure-postgresql-for-cloud.md).

## Recommended local approach

Use Docker for the local PostgreSQL instance.

It is the simplest option because:

- it avoids installing PostgreSQL directly on the workstation
- it keeps the local setup reproducible
- it is easy to destroy and recreate

## Example local container

```bash
docker run --name payment-review-postgres \
  -e POSTGRES_DB=payment_exception_review \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:16
```

This creates:

- database: `payment_exception_review`
- username: `postgres`
- password: `postgres`
- host port: `5432`

## Verify the container

```bash
docker ps
docker logs payment-review-postgres
```

If you want to connect interactively:

```bash
docker exec -it payment-review-postgres psql -U postgres -d payment_exception_review
```

## Local Spring Boot connection values

For local development, the application should use values like:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/payment_exception_review
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

If you want a looser first-start experience before Flyway is in place, you can temporarily use:

```properties
spring.jpa.hibernate.ddl-auto=update
```

But for the governed path, `validate` is the stronger target.

## Governed cloud access model

For the Azure `dev` environment, the intended model is:

- AKS attached to the platform virtual network
- Azure Database for PostgreSQL Flexible Server attached to a delegated subnet
- private DNS used for the database name resolution
- no public database access as a normal developer workflow

That means cloud database validation should happen through:

- the deployed Spring Boot application
- an internal in-cluster debug pod
- `kubectl exec` or an equivalent trusted internal path

It should not rely on:

- `psql` directly from a developer laptop to the cloud database
- a permanent public firewall rule

This keeps the cloud-side behavior aligned with the governed runtime model while preserving a simple local developer experience.

## Stop and remove the local instance

Stop it:

```bash
docker stop payment-review-postgres
```

Start it again:

```bash
docker start payment-review-postgres
```

Remove it completely:

```bash
docker rm -f payment-review-postgres
```

## Notes

- local credentials here are intentionally simple for development only
- do not reuse these credentials in Azure
- later, Flyway should manage schema creation and evolution
- later, the local developer experience can be improved with `docker-compose` or a devcontainer if needed

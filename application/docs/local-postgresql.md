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

This local setup intentionally separates:

- `compose.yaml` for the local PostgreSQL dependency only
- `run_containerized_app.sh` for containerized application validation

The application is not included in `compose.yaml` at this stage.

That separation keeps two local workflows clean:

- normal development with PostgreSQL in Docker and the app started through Maven
- runtime validation with PostgreSQL in Docker and the app started as a container

## Recommended local Compose usage

From:

```bash
application/payment-exception-review-service
```

start PostgreSQL with:

```bash
docker compose up -d
```

This starts the `payment-review-postgres` service defined in `compose.yaml`.

## Verify the container

```bash
docker compose ps
docker compose logs payment-review-postgres
```

If you want to connect interactively:

```bash
docker exec -it payment-review-postgres psql -U postgres -d payment_exception_review
```

## Optional equivalent standalone container

If you do not want to use Docker Compose, this is the equivalent `docker run` command:

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

## Local runbook

This runbook is the simplest validated local path for the service:

1. start local PostgreSQL
2. run the Spring Boot application
3. let Flyway create and seed the schema
4. call the persisted endpoint

If you want to validate the containerized application path locally, use:

```bash
./run_containerized_app.sh
```

from:

```bash
application/payment-exception-review-service
```

This script:

- starts the local PostgreSQL Compose service if needed
- rebuilds the local application image
- removes any previous local application container with the same name
- runs the application container against the local PostgreSQL instance

This is intentionally separate from `compose.yaml` so newcomers can choose between:

- `docker compose up -d` + `./mvnw spring-boot:run` for normal local development
- `./run_containerized_app.sh` for a reproducible container-runtime validation path

### 1. Start local PostgreSQL

```bash
docker compose up -d
```

### 2. Verify PostgreSQL is running

```bash
docker compose ps
docker compose logs payment-review-postgres
```

### 3. Run the Spring Boot application

From:

```bash
application/payment-exception-review-service
```

run:

```bash
./mvnw spring-boot:run
```

### 4. Expected startup signals

When startup is healthy, the logs should show:

- Hikari datasource startup completes
- Flyway validates and applies migrations
- JPA initializes successfully
- Tomcat starts on port `8080`

Typical success indicators:

- `HikariPool-1 - Start completed`
- `Successfully applied 2 migrations`
- `Initialized JPA EntityManagerFactory`
- `Tomcat started on port 8080`

### 5. Validate the persisted endpoint

```bash
curl http://localhost:8080/api/payment-exceptions/payexc-100045/status
```

Expected response:

```json
{
  "reviewId": "payexc-100045",
  "status": "PENDING_REVIEW",
  "validationMode": "STANDARD",
  "escalationEnabled": true,
  "region": "CA-QC"
}
```

### 6. Optional database verification

Connect to the local database:

```bash
docker exec -it payment-review-postgres psql -U postgres -d payment_exception_review
```

Then check:

```sql
SELECT * FROM flyway_schema_history;
SELECT review_id, status FROM payment_exception_reviews;
```

### 7. Troubleshooting

#### Flyway reports `Unsupported Database: PostgreSQL 16.x`

Cause:

- the PostgreSQL Flyway support module is missing
- this was encountered during the first local PostgreSQL startup attempt when Flyway could connect to PostgreSQL but could not identify PostgreSQL 16 correctly with `flyway-core` alone

Fix:

- ensure both dependencies are present in `pom.xml`:
  - `org.flywaydb:flyway-core`
  - `org.flywaydb:flyway-database-postgresql`

Expected recovery:

- the application starts
- Flyway creates `flyway_schema_history`
- migrations `V1` and `V2` are applied successfully

#### The app cannot connect to PostgreSQL

Check:

- the Compose service is running:

```bash
docker compose ps
```

- the application datasource values match the local container:
  - host: `localhost`
  - port: `5432`
  - database: `payment_exception_review`
  - username: `postgres`
  - password: `postgres`

#### Migrations do not appear to run

Check:

- `spring.flyway.enabled=true`
- migration files are under:
  - `src/main/resources/db/migration/`

#### The endpoint returns no seeded data

## Stop and cleanup

Stop PostgreSQL:

```bash
docker compose down
```

Stop PostgreSQL and remove the local database volume:

```bash
docker compose down -v
```

Check:

- `V2__seed_payment_exception_reviews.sql` exists
- the seed row uses the expected review id:
  - `payexc-100045`

### 8. Stop the local setup

Stop the application:

- `Ctrl+C`

If you started the containerized app with `./run_containerized_app.sh`, stop it with:

```bash
docker stop payment-exception-review-service-local
```

Stop PostgreSQL:

```bash
docker stop payment-review-postgres
```

Remove PostgreSQL completely:

```bash
docker rm -f payment-review-postgres
```

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

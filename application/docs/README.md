# Payment Exception Review Service Docs

This folder contains the design artifacts for the Stage 1 application-team service.

## Document index

- [API contract](./api-contract.md)
- [OpenAPI contract](./openapi.yaml)
- [Use cases](./use-cases.md)
- [Stage 1 implementation process](./implementation-process.md)
- [Domain model](./domain-model.md)
- [Persistence model](./persistence-model.md)
- [Local PostgreSQL setup](./local-postgresql.md)
- [Architecture decision records](./adrs/README.md)
- [Application architecture](./architecture.md)
- [Configuration ownership](./config-ownership.md)
- [Failure scenarios](./failure-scenarios/README.md)
- [Implementation skeleton](./implementation-skeleton.md)
- [Helm chart](../payment-exception-review-service/helm/README.md)

## Purpose

These documents define the minimum design baseline before implementation:

- what the service exposes
- which concepts it owns
- how it persists data
- how it fits into the governed AKS platform
- which technical decisions are locked for Stage 1

## Local quick start

From `application/payment-exception-review-service`:

1. start local PostgreSQL

```bash
docker compose up -d
```

2. run the application through Maven

```bash
./mvnw spring-boot:run
```

3. validate the persisted endpoint

```bash
curl http://localhost:8080/api/payment-exceptions/payexc-100045/status
```

If you want to validate the containerized application path instead of the Maven path:

```bash
./run_containerized_app.sh
```

For the detailed local database and container runtime runbook, see:

- [Local PostgreSQL setup](./local-postgresql.md)

For the Kubernetes deployment packaging and Helm deployment assumptions, see:

- [Helm chart](../payment-exception-review-service/helm/README.md)

# ADR-010 - Use Local PostgreSQL for Local Development and Managed Azure PostgreSQL for Cloud

## Status

Accepted

## Context

Stage 1 now makes PostgreSQL a real service dependency instead of treating persistence as a purely theoretical concern.

The main architectural question is whether every environment should use the same database hosting model or whether local development and cloud delivery should intentionally differ.

A single-model approach would force local development to depend on managed Azure resources, which increases friction and weakens the developer experience.

## Decision

The repository uses an environment-specific database hosting model:

- **local development** uses a local PostgreSQL instance
- the **governed cloud environment** uses managed Azure Database for PostgreSQL

This keeps local development practical while preserving a credible managed-service story for the cloud environment.

## Consequences

### Positive

- developers can work locally without requiring Azure-managed database access
- the cloud environment still reflects enterprise-style managed database usage
- the environment model becomes clearer: local path versus governed cloud path
- the design is easier to evolve later toward stronger database networking and secret management

### Negative

- local and cloud environments are not identical at the hosting level
- the repository must document the difference clearly
- app configuration must support environment-specific database wiring

## Alternatives considered

### Use Azure Database for PostgreSQL for every environment

Rejected because it makes local development heavier and less accessible.

### Use only local PostgreSQL everywhere

Rejected because it weakens the managed-cloud credibility of the Stage 1 infrastructure story.

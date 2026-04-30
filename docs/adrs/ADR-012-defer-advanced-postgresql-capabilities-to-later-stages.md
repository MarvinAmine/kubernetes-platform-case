# ADR-012 - Defer Advanced PostgreSQL Capabilities to Later Stages

## Status

Accepted

## Context

The repository needs to balance:

- realistic database architecture decisions
- finishable Stage 1 scope

If Stage 1 tries to include every mature managed-database capability immediately, the case risks becoming broader than necessary and weaker in execution quality.

Advanced capabilities discussed for PostgreSQL include:

- high availability (HA)
- replica strategy
- Key Vault integration
- advanced backup policy tuning

## Decision

Stage 1 keeps PostgreSQL credible but intentionally does **not** require all advanced managed-database capabilities immediately.

The following are explicitly deferred to later maturity stages:

- HA
- replicas
- Key Vault integration
- advanced backup policy tuning

Stage 1 focuses on getting the database role, ownership, environment model, and cloud posture decisions right first.

## Consequences

### Positive

- Stage 1 stays finishable
- the database story is still credible without being overloaded
- later stages retain meaningful maturity upgrades instead of adding only tool sprawl

### Negative

- some readers may expect stronger database hardening earlier
- the docs must clearly state what is current scope versus deferred scope

## Alternatives considered

### Implement all advanced PostgreSQL capabilities in Stage 1

Rejected because it would add too much implementation weight too early.

### Ignore advanced PostgreSQL capabilities entirely

Rejected because the later-stage maturity path should still be explicit.

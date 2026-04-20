# ADR-001 - Keep Stage 1 as a single Spring Boot service

## Status

Accepted

## Context

Stage 1 is meant to demonstrate a governed delivery foundation for one internal regulated-environment service.

The current objective is to prove:

- controlled CI/CD
- AKS deployment
- Docker and Helm packaging
- probes and rollout behavior
- observability
- supportable troubleshooting

The current objective is not to prove distributed-system decomposition.

## Decision

Implement Stage 1 as a single Spring Boot service.

## Consequences

### Positive

- Keeps the delivery path focused and explainable.
- Avoids premature service-to-service complexity.
- Makes rollout, configuration, and observability easier to reason about.

### Negative

- Does not yet demonstrate multi-service interaction patterns.

## Revisit trigger

Revisit this decision only if later stages require clear service-boundary separation for scale, ownership, or security reasons.

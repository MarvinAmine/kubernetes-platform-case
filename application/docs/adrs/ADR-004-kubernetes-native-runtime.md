# ADR-004 - Use Kubernetes-native runtime patterns without Eureka or OpenFeign

## Status

Accepted

## Context

The service is deployed to AKS and Stage 1 currently contains one application service.

Introducing Eureka or OpenFeign now would add distributed-system patterns that are not required by the current scope.

## Decision

Use Kubernetes-native runtime patterns and do not introduce:

- Eureka
- OpenFeign

for Stage 1.

## Consequences

### Positive

- Keeps the application aligned with the actual scope.
- Avoids premature complexity in discovery and internal client patterns.
- Uses Kubernetes as the natural runtime environment boundary.

### Negative

- Does not yet demonstrate service-to-service communication patterns.

## Revisit trigger

Revisit if later stages introduce multiple internal services with explicit inter-service contracts.

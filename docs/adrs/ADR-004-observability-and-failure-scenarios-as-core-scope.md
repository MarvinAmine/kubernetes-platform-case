# ADR-004 - Treat Observability and Failure Scenarios as Part of the Platform Case

## Status

Accepted

## Context

A Stage 1 platform case for a regulated internal service is not credible if it only proves that deployment succeeds.

The repo must also show:

- how health is exposed
- how runtime behavior is diagnosed
- how configuration failures surface
- how rollout problems are investigated

Without that, the project would look deployment-heavy but operations-light.

## Decision

Stage 1 includes observability and troubleshooting as part of the core scope:

- health endpoints
- Prometheus-compatible metrics
- Grafana-compatible observability direction
- realistic failure scenarios
- runbook-oriented thinking

The platform side owns shared observability conventions, while the application side owns service-level metrics and actuator exposure.

## Consequences

### Positive

- the repo demonstrates production-minded thinking rather than only deployment mechanics
- failure scenarios create stronger interview material
- observability becomes part of the operating model instead of an afterthought

### Negative

- documentation scope becomes larger
- some observability elements are architectural direction before they are fully provisioned by current IaC

## Alternatives considered

### Keep observability out of Stage 1

Rejected because the case would look too shallow for platform-oriented roles.

### Add a fully mature enterprise observability stack immediately

Rejected because it would overload Stage 1 and dilute the core delivery signal.

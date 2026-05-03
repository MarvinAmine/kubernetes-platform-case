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

The target Kubernetes metrics operating model is a shared platform-level
monitoring stack per cluster or environment boundary rather than a separate
Prometheus and Grafana stack for each application.

The preferred production direction is:

- `kube-prometheus-stack` as the shared Kubernetes-native monitoring baseline
- SSO-backed Grafana access
- network isolation around monitoring components and scrape endpoints
- controlled RBAC for dashboards, datasources, and operational access
- persistent Grafana storage
- governed Alertmanager routing and notification ownership
- Thanos for long-term retention and global query when enterprise scale
  requires it

Per-application duplication of Prometheus and Grafana is deferred unless a
regulatory or tenancy boundary explicitly requires physical separation.

## Consequences

### Positive

- the repo demonstrates production-minded thinking rather than only deployment mechanics
- failure scenarios create stronger interview material
- observability becomes part of the operating model instead of an afterthought
- the observability model stays aligned with the platform-team ownership model
- shared monitoring reduces duplicate infrastructure, dashboard drift, and
  operational patching overhead

### Negative

- documentation scope becomes larger
- some observability elements are architectural direction before they are fully provisioned by current IaC
- shared monitoring requires stricter logical isolation controls because teams
  do not each get a physically separate stack

## Alternatives considered

### Keep observability out of Stage 1

Rejected because the case would look too shallow for platform-oriented roles.

### Add a fully mature enterprise observability stack immediately

Rejected because it would overload Stage 1 and dilute the core delivery signal.

### Duplicate monitoring stacks per application by default

Rejected because the operational and governance overhead is too high for the
default case. Highly regulated organizations often prefer stronger isolation,
but they do not automatically duplicate Prometheus, Grafana, and Alertmanager
for every workload. The better default is one governed shared monitoring stack
per cluster or environment, with duplication reserved for cases where
compliance, residency, or tenancy boundaries genuinely require separate
platform instances.

# Observability Tradeoffs

This document clarifies the monitoring tradeoffs used in this repository so the
Stage 1 implementation is not confused with the longer-term enterprise target.

## Current Stage 1 choice

Stage 1 uses the following observability direction:

- one shared platform-level monitoring stack per cluster or environment
- `kube-prometheus-stack` as the Kubernetes-native baseline
- application metrics exposed through `/actuator/prometheus`
- governed onboarding through `ServiceMonitor` or `PodMonitor`

This means Stage 1 is intentionally **not** building:

- one Prometheus and Grafana stack per application
- Thanos from day one

## Why shared monitoring now

The default production-oriented choice is a shared platform monitoring stack
because it:

- reduces duplicated infrastructure
- reduces duplicated storage
- reduces dashboard and alert drift
- centralizes patching and operational hardening
- fits the platform-team ownership model better than per-app duplication

For a regulated fintech-style environment, the better default is strong logical
isolation and governance, not automatic physical duplication of the entire
observability estate.

## Why Thanos is not part of Stage 1

Thanos is a strong enterprise extension, but it solves problems that Stage 1
does not need to solve yet.

Thanos is most useful when the platform needs:

- long-term metrics retention beyond local Prometheus storage
- global query across multiple Prometheus instances or clusters
- stronger enterprise-scale monitoring continuity

Stage 1 does not yet require that level of observability scale. The immediate
goal is to prove:

- Kubernetes-native scraping works
- application metrics are exposed correctly
- dashboards and alerts can be layered on top of a shared monitoring baseline
- the platform operating model remains governed and supportable

Adding Thanos immediately would increase complexity before the repository has
demonstrated enough value from the simpler shared-stack baseline.

## Practical tradeoff

### Option A - Shared `kube-prometheus-stack` now

Pros:

- simpler
- lower operational cost
- easier to patch and govern
- enough for Stage 1 monitoring credibility

Cons:

- shorter retention unless extended later
- no global query layer yet
- not the final enterprise end-state

### Option B - Add Thanos immediately

Pros:

- stronger long-term retention story
- stronger multi-cluster / enterprise query story
- closer to a mature enterprise observability architecture

Cons:

- more components to operate
- more storage and configuration complexity
- distracts from the Stage 1 delivery and platform baseline

## Decision

The repository uses this progression:

- Stage 1: shared `kube-prometheus-stack`
- later stage: add SSO, tighter RBAC, network isolation, Alertmanager
  governance, and more mature operational controls
- later enterprise stage: add Thanos if long retention and global query are
  justified

So the rule is:

- shared monitoring is the default now
- Thanos is deferred, not rejected


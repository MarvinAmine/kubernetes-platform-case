# Stage 2 Reliability Targets

[GOVERNANCE DIRECTIVES ->](./stage2-governance-directives.md)

These targets simulate the high-level reliability expectations that would
normally be shaped by product ownership, service ownership, architecture
governance, platform leadership, risk/compliance, and SRE / Production
Engineering.

They are **project assumptions**, not external customer commitments.

## Purpose

Stage 2 needs explicit reliability targets before implementing alerts,
dashboards, runbooks, incident reports, and rollback automation.

This document defines the proposed SLO assumptions, the SLI translation needed
to measure them, and the evidence the reliability layer should produce.

## Ownership

| Area | Owner | Responsibility |
| --- | --- | --- |
| User impact and risk tolerance | Product / Business direction | Defines what matters to internal consumers and operators |
| SLO direction | Service Owner / Product Owner + Architecture Governance | Defines target reliability expectations and constraints |
| SLI definition | SRE / Production Engineering | Turns SLO direction into measurable indicators, queries, alert signals, and operational evidence |
| Alert thresholds and recovery evidence | SRE / Production Engineering | Defines alert behavior, runbooks, incidents, MTTR evidence, and postmortem follow-up |
| Application behavior | Application team | Fixes endpoint behavior, errors, latency, health, and API contract issues |
| Platform capability | Platform team | Maintains observability, rollout, rollback, and recovery platform capabilities |

Decision rule:

```text
SLOs are proposed by service ownership and governance.
SLIs are defined by SRE to make those SLOs measurable.
Application and platform teams implement the changes required to meet them.
```

## Stage 2 Proposed Targets

These values are intentionally modest because Stage 2 is a governed non-prod /
demo platform, not a formal production SLA.

| Target | Proposed value | Measurement direction | Evidence location |
| --- | --- | --- | --- |
| Availability SLO | 99.0% during the demo operating window | health checks and selected API success over time | `reliability/slos/`, Grafana panels |
| API success rate | 99.0% for selected API endpoints | ratio of non-5xx responses over rolling window | Prometheus rules / dashboard panels |
| Latency SLO | p95 under 500ms for simple backend endpoints | HTTP server request duration metrics | Grafana latency panel |
| Metrics scrapeability | `/actuator/prometheus` remains scrapeable | Prometheus target up and scrape success | Prometheus target and alert rule |
| Staging E2E readiness | 100% pass for required Postman/Newman checks before prod promotion | Newman report status | `reliability/testing/e2e/` |
| Rollback readiness | rollback to previous known-good image in under 10 minutes | rollback drill timeline | `reliability/runbooks/`, incident notes |
| MTTR drill target | restore service or rollback within 15 minutes during controlled failures | detection-to-recovery incident timeline | `reliability/incidents/` |
| Alert acknowledgement | acknowledge controlled alert in under 5 minutes | incident drill note or manual evidence | incident report |

## SLI Definitions

Stage 2 should start with a small SLI set:

```text
Availability SLI:
  successful health/API checks over total checks

Success-rate SLI:
  non-5xx HTTP responses over total HTTP responses

Latency SLI:
  p95 request latency for selected API endpoints

Scrapeability SLI:
  Prometheus can scrape /actuator/prometheus

Recovery SLI:
  detection-to-recovery duration during controlled failure drills
```

## SLA Boundary

Stage 2 does not claim an external SLA.

SLA is a business/legal support commitment. It belongs to a later enterprise or
compliance stage after support hours, escalation ownership, penalties, and
operational commitments are formally defined.

## Implementation Mapping

The reliability target flow should be:

```text
docs/governance/stage2-reliability-targets.md
  -> defines expected reliability posture

docs/architecture/stage2/operations/stage2_operational_architecture_mermaid.md
  -> shows how targets are observed, alerted, investigated, and recovered

reliability/
  -> stores SLO notes, alert rules, runbooks, incidents, rollback evidence,
     E2E reports, MTTR notes, and postmortems
```

## Evidence Rule

Every reliability claim should eventually map to durable evidence:

```text
Target
  -> metric query or test result
  -> dashboard / alert / runbook
  -> incident or drill evidence
  -> corrective action when the target is not met
```

This keeps Stage 2 honest: reliability is demonstrated through observable
signals and recovery evidence, not only through architecture text.

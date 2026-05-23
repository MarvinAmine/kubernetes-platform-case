# SRE Portfolio Leverage Strategy

## Purpose

This document explains how this project can create stronger leverage for **SRE
roles**, not only platform or DevOps roles.

The key point is simple:

> delivery proof is not enough for SRE credibility

The project gets stronger for SRE hiring when it produces evidence around
reliability, incident response, recovery speed, and prevention.

## Core formula

The strongest SRE story in this repository is:

```text
Incident
  -> SLI impact
  -> SLO pressure or breach
  -> alert or detection signal
  -> diagnosis
  -> mitigation or rollback
  -> MTTR measurement
  -> postmortem
  -> toil-reduction automation
  -> preventive control
```

That is the bridge between:

- “this repo can deploy and troubleshoot a platform”
- and
- “this repo shows real SRE thinking”

## What raises the SRE signal

To create maximum leverage for an SRE role, each reliability scenario should
leave durable repo evidence behind.

Required evidence types:

- incident report
- SLI or SLO definition
- dashboard or Prometheus query
- alert rule
- runbook
- MTTR measurement
- recovery automation
- prevention action

Video helps prove communication quality.
Repository evidence proves engineering quality.

## Strong scenario pattern

The best future scenarios are not abstract explanations. They are concrete
operational situations.

Example pattern:

### Scenario 1: bad deployment breaks readiness

```text
change introduced
  -> readiness probe fails
  -> service becomes unavailable
  -> alert fires
  -> rollback executed
  -> MTTR measured
  -> postmortem written
  -> preventive CI or policy check added
```

Signals demonstrated:

- availability SLI
- deployment safety
- rollback discipline
- MTTR
- postmortem culture
- prevention

### Scenario 2: PostgreSQL latency degrades the service

```text
slow query
  -> p95 latency rises
  -> SLO pressure or breach
  -> Grafana or Prometheus detection
  -> query or index fix
  -> before/after latency evidence
  -> runbook updated
```

Signals demonstrated:

- latency SLI
- dependency management
- performance diagnosis
- evidence-based remediation

### Scenario 3: secret rotation or secret contract failure

```text
secret change or secret mismatch
  -> app startup or DB connectivity failure
  -> alert or probe failure
  -> diagnosis
  -> fix
  -> secret rotation runbook
  -> validation automation
```

Signals demonstrated:

- operational readiness
- dependency failure recovery
- secure reliability
- reduced manual recovery risk

### Scenario 4: unsafe deployment blocked before runtime

```text
missing limits or probes
  -> policy blocks deployment
  -> runtime incident prevented
  -> prevented failure explained
```

Signals demonstrated:

- prevention over reaction
- policy-as-code
- reliability by design

### Scenario 5: toil reduction

```text
manual diagnosis and recovery
  -> script the repeated steps
  -> compare before and after MTTR
```

Signals demonstrated:

- toil reduction
- operator efficiency
- repeatable incident handling
- measurable reliability improvement

## Ideal repo artifacts

Recommended direction:

```text
reliability/
  service-level-objectives/
    payment-exception-review-slo.md
  alerts/
    prometheus-rules.yaml
  incidents/
    INC-001-readiness-probe-failure.md
    INC-002-postgresql-latency.md
    INC-003-secret-rotation-failure.md
  runbooks/
    rollback-failed-release.md
    investigate-high-latency.md
    investigate-db-connectivity.md
  testing/
    e2e/
  scripts/
    collect-incident-evidence.sh
    rollback-release.sh
    validate-slo-targets.sh
  observability/
    grafana/
      dashboards/
```

Not every file must exist immediately.
The important part is the pattern:

```text
incident -> evidence -> recovery -> prevention
```

## What would make the SRE signal close to 10/10

For portfolio-level SRE credibility, the project gets close to top-tier when it
shows:

| SRE signal | Evidence needed |
| --- | --- |
| SLI / SLO thinking | documented SLOs, queries, dashboard panels |
| Alerting | Prometheus alert rules with thresholds and rationale |
| Incident response | timeline, diagnosis, mitigation, recovery |
| MTTR | before and after recovery time |
| Postmortem culture | blameless postmortem and corrective actions |
| Toil reduction | scripts or automation replacing manual steps |
| Reliability testing | controlled failure scenarios |
| Deployment safety | rollback, staged promotion, approval gates |
| Operational readiness | runbooks, ownership, escalation path |
| Prevention | CI checks, policy guardrails, safer defaults |

## Honest positioning

This should not be presented as:

> real enterprise production traffic

It should be presented as:

> a controlled reliability lab designed to make production behaviors visible

That wording is stronger because it is accurate.

It allows you to say:

- this is simulated, but disciplined
- this is not fake theory
- the repo shows how incidents are detected, explained, mitigated, measured,
  and prevented

## Recommended use in later stages

The best place to increase SRE leverage is Stage 2 and Stage 3:

- **Stage 2**: staging E2E, rollback readiness, runbooks, SLO direction,
  alerting, incident evidence, toil reduction
- **Stage 3**: stronger production-readiness narrative, broader observability,
  hybrid environments, certification-grade operational evidence

Stage 1 already provides troubleshooting proof.
Later stages should turn that troubleshooting proof into **reliability
evidence**.

## Short conclusion

This project creates stronger leverage for SRE roles when it demonstrates not
only:

- deployment
- observability
- troubleshooting

but also:

- service-level objectives
- incident response
- rollback discipline
- MTTR
- postmortems
- toil reduction
- prevention

The strongest portfolio outcome is:

> every major failure scenario leaves behind a runbook, an alert, a dashboard,
> an incident note, and an automation improvement

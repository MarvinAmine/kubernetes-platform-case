# Stage 2 Governance Directives

[STAGE 2 PLAN ->](../stage2-implementation-plan.md)

These directives simulate the high-level constraints that would normally be
given by architecture governance, product ownership, risk/compliance, platform
leadership, and SRE / Production Engineering.

They guide Stage 2 implementation. They are not executable assets.

## Environment Model

Approved Stage 2 environments:

```text
local -> dev -> staging -> prod
```

`certification` is reserved for Stage 3.

## Cluster Boundary

Stage 2 uses two clusters:

```text
non-prod cluster:
  dev
  staging

prod cluster:
  prod
```

Production must be isolated at the cluster boundary. Dev and staging may share a
non-prod estate to balance governance, cost, and complexity.

## Promotion Policy

Promotion must follow this direction:

```text
local -> PR -> dev -> staging -> prod
```

Required controls:

- PR checks before merge
- security gates before promotion
- staging E2E validation before prod
- QA approval before production promotion
- PO approval when business validation is required
- rollback path documented before production promotion

## Workflow Evolution Rule

Stage 1 workflows are preserved by the Stage 1 Git tag and GitHub Release.

`main` evolves toward Stage 2. Do not keep duplicate active Stage 1 and Stage 2
workflow generations unless the older workflow is clearly marked
legacy/manual-only.

Workflow ownership must stay explicit:

- `infrastructure-*`: Infrastructure team
- `platform-*`: Platform team
- `application-*`: Application team
- `reliability-*`: SRE / Production Engineering
- `repository-*`: repository governance checks

## Artifact Promotion Rule

The application image must be built once and promoted across environments.

Stage 2 should promote the same immutable tag or digest from dev to staging and
then prod.

The image must not be rebuilt separately for each environment.

## Service-Level Direction

Stage 2 defines service-level direction for the demo platform.

Initial SLO direction:

```text
Availability: 99.0% during the demo operating window
API success rate: 99.0% for selected API endpoints
Latency: p95 under 500ms for simple backend endpoints
Metrics: /actuator/prometheus remains scrapeable
```

Initial MTTR target:

```text
Restore service or rollback within 15 minutes during demo operations.
```

## SLA Boundary

No external SLA is claimed in Stage 2.

SLA is a business/legal support commitment and belongs to a later enterprise or
compliance stage.

## Compliance Boundary

Stage 2 focuses on delivery governance and platform controls.

Formal compliance implementation is deferred.

Stage 3 may introduce compliance-aware architecture direction. Stage 4+ may
carry formal ISO, NIST, SOC 2, PCI DSS, ISO/IEC 20000, audit, and evidence
program scope.

## Ownership Boundary

Governance defines the target.

Implementation ownership:

- `infrastructure/`: environment-aware cloud and cluster foundations
- `platform/`: Kubernetes runtime boundaries and shared platform services
- `application/`: service code, image, Helm chart, and runtime behavior
- `reliability/`: E2E validation, SLO interpretation, rollback, and runbooks
- `.github/workflows/`: automated validation and promotion evidence

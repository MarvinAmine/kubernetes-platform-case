# Stage 2 Architecture Follow-Up Notes

These notes track architecture deliverables to complete later. They are intentionally separated from the current local runtime diagram to avoid mixing runtime traffic, deployment flow, security controls, and operations in one view.

## Already Started

| Deliverable | Current state |
| --- | --- |
| Stage 2 local high-level runtime architecture | Started in [`../runtime/stage2_local_high_level_runtime_mermaid.md`](../runtime/stage2_local_high_level_runtime_mermaid.md). It intentionally stays close to Stage 1 because local runtime traffic remains stable. |
| Stage 2 implementation plan | Documented in [`../../../stage2-implementation-plan.md`](../../../stage2-implementation-plan.md). |
| Stage 2 OpenShift governance decision | Documented in [`../../../adrs/ADR-016-use-openshift-aligned-governance-in-stage-2-and-defer-runtime-proof-to-stage-3.md`](../../../adrs/ADR-016-use-openshift-aligned-governance-in-stage-2-and-defer-runtime-proof-to-stage-3.md). |

## Follow-Up Architecture Deliverables

| Priority | Deliverable | Purpose |
| --- | --- | --- |
| 1 | Stage 2 local admission / governance flow | Show what changes before runtime: `helm` or `kubectl apply` -> Kubernetes API server -> Pod Security Admission -> Kyverno -> ResourceQuota / LimitRange -> accepted workload. |
| 2 | Stage 2 non-prod AKS high-level solution architecture | Show the real shared non-prod model: AKS non-prod cluster, dev namespace, staging namespace, managed PostgreSQL direction, shared observability, identity, and workflow boundaries. |
| 3 | Stage 2 promotion architecture | Show build once, publish once, promote the same GHCR image digest through dev -> staging -> prod approval. |
| 4 | Stage 2 security architecture | Show identity, RBAC, secrets, admission controls, policy-as-code, image scanning, SCA/SAST/DAST direction, and audit evidence. |
| 5 | Stage 2 operational architecture | Show SLO/SLI, alerting, dashboards, runbooks, rollback, incident response, MTTR measurement, and postmortem evidence. |

## Current Diagram Rule

The local high-level runtime diagram should not show admission controls as runtime traffic hops.

Use this split:

```text
Runtime architecture:
  Developer -> Service -> Pod -> PostgreSQL
  Observability -> metrics and dashboards

Admission / governance architecture:
  helm or kubectl apply
  -> Kubernetes API server
  -> admission and policy checks
  -> accepted workload
  -> runtime starts
```

This keeps diagrams readable and prevents controls such as Kyverno, ResourceQuota, LimitRange, Pod Security Standards, and securityContext from being misunderstood as normal HTTP/JDBC traffic components.

# ADR-016 - Use OpenShift-Aligned Governance in Stage 2 and Defer Runtime Proof to Stage 3

## Status

Accepted

## Context

Stage 2 is intended to evolve the Stage 1 AKS delivery foundation into a
governed shared-platform model.

The architectural direction includes OpenShift because OpenShift is a strong
enterprise Kubernetes signal for regulated organizations:

- project and namespace governance
- stronger multi-team platform boundaries
- route and ingress conventions
- service account and RBAC discipline
- policy-aware platform operations
- GitOps-friendly delivery patterns
- stronger operational supportability expectations

However, running a full OpenShift environment as the normal Stage 2 development
loop creates a cost and complexity problem.

Managed OpenShift options such as Azure Red Hat OpenShift can take roughly
45-75 minutes to create and require a larger estate than a small AKS learning
cluster. A controlled proof session can easily take several hours when creation,
validation, screenshots, cleanup, and error handling are included.

That cost profile does not match the Stage 2 goal.

Stage 2 should prove:

- governance
- environment separation
- promotion discipline
- GitOps direction
- secrets governance
- policy and security gates
- staging validation
- rollback readiness
- operational evidence

It should not become primarily an OpenShift installation exercise.

## Decision

Stage 2 will use OpenShift as a **target enterprise platform architecture** and
as an **OpenShift-ready design direction**, but it will not require a real
OpenShift runtime as the mandatory implementation path.

Real OpenShift runtime proof is deferred to Stage 3.

The progression becomes:

```text
Stage 1
  Governed AKS delivery foundation

Stage 2
  Governed shared-platform model
  OpenShift-ready target architecture
  Cost-controlled validation through local / hosted labs

Stage 3
  Real OpenShift runtime proof
  Hybrid / enterprise runtime expansion
```

## Stage 2 OpenShift Scope

Stage 2 may include OpenShift in:

- target architecture diagrams
- platform governance language
- comparison notes between Kubernetes namespace and OpenShift project models
- route / ingress design direction
- service account and RBAC conventions
- GitOps design direction
- policy guardrail design
- secrets governance direction

Stage 2 should not require:

- permanent Azure Red Hat OpenShift
- permanent ROSA
- permanent IBM Cloud OpenShift
- permanent self-managed OpenShift
- local OpenShift Local / CRC as a blocker
- MicroShift as the main runtime proof

## OpenShift-Aligned Outcomes in Stage 2

Stage 2 will not claim to emulate OpenShift internals on AKS or kind.

OpenShift includes platform-specific components and lifecycle behavior that are
not reproduced by a standard Kubernetes cluster, such as:

- Cluster Version Operator
- Machine Config Operator
- OpenShift release payload management
- OpenShift SecurityContextConstraints
- OpenShift Routes
- OpenShift Console
- OpenShift-specific operators and defaults
- OpenShift-native upgrade orchestration

Those are real OpenShift runtime features and are deferred to Stage 3.

Stage 2 can, however, implement the **governance outcomes** that OpenShift is
often selected for in regulated enterprises.

This distinction is important:

```text
Not accurate:
  Stage 2 emulates OpenShift on AKS.

Accurate:
  Stage 2 implements OpenShift-aligned governance outcomes on Kubernetes / AKS,
  then validates OpenShift-specific compatibility separately when needed.
```

### Outcome mapping

| OpenShift-oriented outcome | Stage 2 Kubernetes / AKS implementation |
| --- | --- |
| Project governance | namespaces, labels, quotas, RBAC conventions |
| Multi-team boundaries | namespace ownership, service accounts, role bindings, workflow ownership |
| Default security posture | Pod Security Standards, Kyverno policies, secure Helm defaults |
| SCC-like workload constraints | Kyverno / admission policies and explicit `securityContext` rules |
| Route-style exposure | Ingress or Gateway API direction |
| GitOps reconciliation | ArgoCD lab direction and Git-owned environment manifests |
| Secrets governance | Vault-ready secret contract and reduced secret exposure |
| Image governance | container scanning, immutable image promotion, optional admission rules |
| Platform hardening | policy-as-code, baseline manifests, preflight checks |
| Operational visibility | Prometheus / Grafana dashboards as code |
| Log investigation direction | Elasticsearch / Kibana or OpenSearch direction, deferred if too heavy |
| Promotion controls | GitHub Environments, approvals, staging E2E, rollback runbooks |

### OpenShift-informed hardening backlog

Stage 2 may track OpenShift release notes and operational recommendations, but
the output should be framed as an **OpenShift-informed hardening backlog**, not
as OpenShift update emulation.

Examples:

- OpenShift security default changes become Kyverno or Pod Security Standard
  updates.
- OpenShift route or ingress guidance becomes Ingress / Gateway API standards.
- OpenShift GitOps recommendations become ArgoCD project and application
  conventions.
- OpenShift secrets guidance becomes Vault / External Secrets direction.
- OpenShift monitoring recommendations become Prometheus / Grafana baseline
  improvements.

This keeps the Stage 2 work honest and useful: it learns from OpenShift without
claiming that AKS or kind has become OpenShift.

## Stage 2 Validation Model

Stage 2 validation is split between target architecture and affordable evidence.

### Target architecture

The target architecture is:

```text
Enterprise OpenShift Platform
```

This wording is intentionally provider-neutral.

It can map later to:

- Azure Red Hat OpenShift
- Red Hat OpenShift Service on AWS
- Red Hat OpenShift on IBM Cloud
- self-managed OpenShift
- private cloud / on-prem OpenShift

The repository must not imply that Montréal regulated organizations universally
use one specific OpenShift hosting model unless there is direct evidence.

### Affordable OpenShift evidence

OpenShift-specific behavior can be validated through Red Hat Developer Sandbox
when useful.

Sandbox evidence may include:

- OpenShift Projects
- Routes
- Services
- Pods
- ConfigMaps
- Secrets
- ServiceAccounts
- RBAC basics
- `oc` CLI practice

Sandbox is optional evidence, not a Stage 2 blocker.

Sandbox is also the place to validate compatibility where OpenShift differs
from standard Kubernetes, for example:

- Project behavior versus namespace-only assumptions
- Route behavior versus Ingress assumptions
- SecurityContextConstraints expectations
- `oc` CLI behavior
- manifest portability
- service account and RBAC behavior under OpenShift defaults
- workload database contract with a PostgreSQL pod, mocked DB contract, or
  optional external PostgreSQL endpoint

Sandbox does not validate Azure PostgreSQL provisioning, Azure private
networking, Azure OIDC, or the AKS Terraform foundation. That boundary is
documented in
[ADR-017](./ADR-017-use-managed-azure-postgresql-for-aks-nonprod-and-substitute-db-for-openshift-sandbox.md).

### Cost-controlled platform evidence

The shared-platform model can still be validated through:

- kind
- AKS low-cost / free-tier-oriented labs where appropriate
- GitHub Actions
- Helm
- ArgoCD lab direction
- Kyverno policy checks
- Vault-ready secret contracts
- Prometheus / Grafana
- local security scanning
- staging E2E evidence
- rollback runbooks

## Stage 3 OpenShift Scope

Stage 3 is where OpenShift becomes an implementation/proof focus.

Stage 3 may include:

- real OpenShift runtime deployment
- OpenShift Project design
- OpenShift Routes
- OpenShift SecurityContextConstraints
- OpenShift GitOps / ArgoCD
- OpenShift Service Mesh if justified
- hybrid / on-prem / provider-neutral runtime architecture
- broader enterprise identity and runtime integration

Stage 3 can choose the runtime based on cost, time, and available credits:

- Red Hat Developer Sandbox for hosted proof
- OpenShift Local / CRC if local resources are available
- Azure Red Hat OpenShift for short Azure proof
- ROSA or IBM Cloud OpenShift if the target story shifts
- self-managed OpenShift if infrastructure access is available

## Ansible Position

Ansible does not depend on OpenShift.

Stage 2 can still use Ansible for repeatable preparation and operations tasks,
for example:

- local workstation preflight checks
- CLI installation validation
- `kubectl`, `helm`, `terraform`, `terragrunt`, `oc`, and `argocd` tool checks
- environment file checks
- repository bootstrap validation
- lab dependency preparation
- operational checklist automation

OpenShift-specific Ansible automation is deferred to Stage 3.

This keeps Stage 2 useful without forcing OpenShift runtime availability.

## MicroShift Position

MicroShift is not the main Stage 2 proof.

MicroShift is a lightweight OpenShift-derived runtime optimized for edge and
small-footprint use cases. It may be useful as a side lab, but it sends a
different signal from the target Stage 2 and Stage 3 architecture.

For this repository:

```text
MicroShift = optional appendix / side validation
OpenShift Platform = enterprise target architecture
```

Using MicroShift as the main proof would risk weakening the enterprise
shared-platform story because it shifts the narrative toward edge deployment.

## ARO Position

Azure Red Hat OpenShift is not used as a daily lab.

ARO may be used later as a short controlled proof session if:

- budget or credits are available
- manifests and commands are prepared in advance
- screenshots and validation steps are planned
- teardown is part of the runbook

ARO should not be used as a mandatory Stage 2 dependency.

## Consequences

### Positive

- Stage 2 remains focused on shared-platform governance instead of cluster
  bootstrap friction.
- The project stays cost-aware and realistic for one-person portfolio work.
- The OpenShift story remains credible because the target architecture is not
  falsely presented as fully implemented.
- Stage 3 gets a clearer, stronger purpose: real enterprise runtime expansion.
- The repository can still demonstrate platform skills through GitOps, policy,
  secrets, promotion, observability, security gates, and rollback evidence.
- The decision reflects how companies operate OpenShift: clusters are created,
  hardened, and reused rather than recreated for every delivery cycle.

### Negative

- Stage 2 will not provide full OpenShift runtime proof.
- Some OpenShift-specific behavior will remain documented, simulated, or
  validated only through Sandbox.
- The repository must be explicit about what is implemented, what is validated,
  and what is deferred.
- Reviewers looking only for hands-on OpenShift runtime evidence will need to
  wait for Stage 3.

## Alternatives Considered

### Make ARO mandatory in Stage 2

Rejected.

ARO is too expensive and slow for a normal individual development loop. It would
turn Stage 2 into an OpenShift infrastructure exercise instead of a governed
shared-platform delivery stage.

### Use Red Hat Developer Sandbox as the mandatory Stage 2 runtime

Rejected as mandatory, accepted as optional evidence.

The Sandbox is useful for OpenShift behavior, but it is time-boxed and has
limitations. The project should not depend on it as permanent infrastructure.

### Use OpenShift Local / CRC as the mandatory local runtime

Rejected.

CRC is heavier than kind, requires meaningful local resources, and should not
be placed on unsuitable shared NTFS storage. It is valid for Stage 3 or an
optional later proof if local resources allow it.

### Use MicroShift as the Stage 2 OpenShift proof

Rejected as the main proof.

MicroShift is useful for edge and low-footprint validation, but it does not
represent the full enterprise shared-platform story targeted by this repository.

### Replace OpenShift with Datadog

Rejected.

OpenShift changes the platform operating model. Datadog changes the
observability vendor/tooling. Datadog can be added later as an observability
integration, but it does not replace the enterprise Kubernetes runtime story.

## Validation Rules

Stage 2 documentation and diagrams should clearly classify each capability:

```text
Implemented
Validated in affordable lab
Architecture target
Deferred to Stage 3
```

OpenShift should be described in Stage 2 as:

```text
OpenShift-ready target architecture and optional Sandbox evidence
```

not as:

```text
fully implemented permanent OpenShift platform
```

## Related Documents

- [OpenShift tradeoffs](../openshift-tradeoffs.md)
- [Stage 2 OpenShift architecture Q&A summary](../stage2_openshift_architecture_qa_summary.md)
- [Stage 2 implementation plan](../stage2-implementation-plan.md)
- [Stage 2 analysis](../stage2.md)

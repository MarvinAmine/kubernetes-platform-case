# Architecture Deliverables Guide

This guide defines the architecture documents and diagrams used across the staged platform evolution.

The goal is to avoid mixing different concerns in the same diagram. A runtime diagram should explain runtime interactions. A deployment diagram should explain where components run. A security diagram should explain controls and trust boundaries.

## Typical Architecture Deliverables

| Deliverable | Purpose |
| --- | --- |
| Business / capability context | Explains what problem is being solved, for whom, with which constraints, risks, and assumptions. |
| High-level solution architecture | Shows major systems, actors, cloud services, ownership boundaries, environments, and external dependencies. |
| Logical architecture | Describes components and responsibilities without overloading the reader with infrastructure details. |
| Runtime architecture | Shows how components interact while the system is running: requests, service calls, database calls, metrics, and observability flows. |
| Deployment / infrastructure architecture | Shows where components run: clusters, namespaces, databases, DNS, ingress, networks, subscriptions, and cloud accounts. |
| Security architecture | Shows identity, RBAC, secrets, network boundaries, admission controls, encryption, and audit concerns. |
| Operational architecture | Shows monitoring, alerting, SLOs, runbooks, backup/restore, incident response, rollback, and support flows. |
| Architecture Decision Records | Explains important decisions, alternatives rejected, consequences, and follow-up constraints. |
| Implementation / migration plan | Defines the sequence of work, rollout stages, dependencies, risks, and validation points. |

## Diagram Separation Rule

Do not force every concern into one diagram.

Use this separation:

```text
Runtime diagram:
  Who calls what while the system is running?

Deployment diagram:
  Where does each component run?

Security / governance diagram:
  Which controls validate, restrict, or authorize workloads?

Operational diagram:
  How is the system observed, recovered, and supported?
```

## Diagram Creation Process

Use this process before creating or updating a diagram:

1. Define the audience.

   A hiring manager, architect, platform engineer, SRE, security engineer, and
   application developer do not need the same level of detail.

2. Define the question the diagram answers.

   Examples:

   ```text
   How does runtime traffic reach the service?
   How is a workload accepted or rejected by Kubernetes?
   How does one image move from dev to staging to prod?
   How are secrets delivered to the workload?
   Which platform tools manage desired state?
   ```

3. Pick one architecture view.

   Do not mix runtime traffic, deployment topology, CI/CD, secrets governance,
   admission control, and operations in the same view unless the purpose is an
   explicit high-level solution overview.

4. Draw only components that participate in that view.

   If a component does not interact in the selected flow, move it to another
   diagram. For example, Vault belongs in a secrets/control-plane diagram, not
   in the normal HTTP runtime path.

5. Separate runtime resources from configuration resources.

   Example:

   ```text
   Ingress Controller Pod = traffic handler
   Ingress Resource = routing rule
   Service = stable cluster endpoint
   Pod = workload runtime
   ConfigMap / Secret = runtime dependency, not network traffic
   ```

6. Keep diagrams readable.

   A public presentation diagram should usually have fewer boxes and clearer
   labels than a repository evidence diagram. Mermaid diagrams can preserve
   precise versioned detail in the repository. Draw.io diagrams can provide a
   cleaner human-facing view for video, LinkedIn, and presentations.

## Recommended Stage 2 Diagram Set

Stage 2 should use several focused diagrams instead of one overloaded tool map:

| Diagram | Main question | Typical components |
| --- | --- | --- |
| High-level solution architecture | What systems, teams, environments, and external dependencies exist? | users, teams, AKS, OpenShift Sandbox, PostgreSQL, GitHub, GHCR, observability, environment boundaries |
| Runtime architecture | What calls what while the platform is running? | DNS, internal LoadBalancer Service, Ingress Controller Pod, Ingress Resources, Services, Pods, PostgreSQL, Prometheus, Grafana, Elasticsearch, Kibana |
| Admission governance flow | What happens before Kubernetes accepts a workload? | Kubernetes API server, Pod Security Admission, Kyverno, ResourceQuota, LimitRange, accepted/rejected workload |
| Promotion governance flow | How does code/image move toward production? | PR, GitHub Actions, GHCR image digest, dev deploy, staging E2E, prod approval, rollback |
| Platform control-plane architecture | Which tools manage desired state, configuration, policy, and secrets? | Git repository, GitHub Actions, Terraform/Terragrunt, Argo CD, Helm/Kustomize, Vault, Ansible, AKS/OpenShift targets |
| Secrets governance flow | How are secrets owned, synchronized, and consumed? | Vault, Kubernetes auth/workload identity direction, External Secrets or Vault Agent direction, Kubernetes Secret, application Pod |
| Operational architecture | How is the service observed and recovered? | SLOs, alerts, Alertmanager, Grafana, logs, Kibana, runbooks, incident evidence, rollback automation |

## Control-Plane Tools Placement

Some Stage 2 technologies are important, but they should not be forced into the
main runtime diagram.

| Technology | Best diagram placement | Reason |
| --- | --- | --- |
| Argo CD | Platform control-plane / GitOps diagram | Reconciles desired state; does not handle user HTTP traffic. |
| HashiCorp Vault | Secrets governance / control-plane diagram | Governs secret delivery and rotation; not part of the normal request path. |
| Kyverno | Admission governance flow | Validates or rejects Kubernetes resources before runtime. |
| Ansible | Platform control-plane / operational automation diagram | Automates setup or runbook actions; not a runtime service dependency. |
| Terraform / Terragrunt | Deployment / infrastructure and control-plane diagrams | Provisions cloud infrastructure and stateful environment wiring. |
| Postman / Newman | Promotion governance / reliability validation diagram | Validates staging readiness before promotion. |

## Project Application

For this repository, the architecture set should evolve like this:

| Stage | Recommended architecture artifacts |
| --- | --- |
| Stage 1 | Local high-level runtime architecture, dev / AKS high-level solution architecture, delivery path diagrams. |
| Stage 2 | Local high-level runtime architecture, local admission / governance flow, non-prod AKS solution architecture, promotion architecture. |
| Stage 3 | Hybrid / OpenShift target architecture, production-like security architecture, operational architecture, compliance evidence direction. |

## Current Stage 2 Rule

The Stage 2 local runtime diagram is intentionally close to Stage 1.

Reason:

```text
The local runtime traffic path remains stable.
Stage 2 changes mostly happen before runtime, during deployment, admission, validation, and promotion.
```

Therefore:

```text
Stage 2 local runtime architecture:
  Developer -> Service -> Pod -> PostgreSQL
  Observability -> metrics and dashboards

Stage 2 local admission / governance flow:
  helm or kubectl apply
  -> Kubernetes API server
  -> admission checks
  -> accepted workload
  -> runtime starts
```

This keeps the architecture readable and prevents governance controls from being misrepresented as runtime traffic hops.

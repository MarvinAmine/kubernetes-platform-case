# OpenShift Tradeoffs

This document clarifies why Stage 2 uses OpenShift-oriented platform features
without making multi-cloud the primary reason for that choice.

## Current Stage 2 choice

Stage 2 uses OpenShift as the reference platform for stronger enterprise
Kubernetes operating features such as:

- project and namespace governance patterns
- stronger admission and security defaults
- route and ingress management patterns
- stricter service account and RBAC operating conventions
- platform guardrails around multi-team tenancy
- more enterprise-oriented operational tooling and supportability patterns
- GitOps-friendly shared-platform operating behavior

The point of the choice is not "multi-cloud for its own sake".

The point is to model the kind of Kubernetes operating experience commonly
found in highly regulated enterprises where governance, supportability,
platform controls, and operational consistency matter more than using raw
upstream Kubernetes everywhere.

## Why OpenShift in Stage 2

OpenShift is useful in this repository because it represents:

- stronger enterprise Kubernetes conventions
- better alignment with governed shared-platform operations
- a more realistic platform-team operating model
- features and defaults that push the design toward production discipline

That makes it a stronger Stage 2 fit than staying only at the level of a basic
managed Kubernetes cluster with lighter governance assumptions.

## What belongs to Stage 2

Stage 2 is where the repository focuses on enterprise Kubernetes operating
features, for example:

- stronger dev / prod separation
- multi-team isolation and governed tenancy
- GitOps-style reconciliation and controlled promotion
- centralized secrets handling
- shared observability services
- platform defaults and policy-aware operations
- OpenShift-style operational guardrails and supportability patterns

These are platform-governance and enterprise-Kubernetes concerns.

## OpenShift compatibility boundary

Stage 2 does not try to deploy the full AKS foundation on OpenShift.

The compatibility target is narrower and more realistic:

```text
Can the application and Kubernetes platform manifests be made OpenShift-ready?
```

This means the portable scope is:

- Spring Boot container image
- Helm chart structure
- Kubernetes Deployment and Service
- ConfigMap and Secret usage
- ServiceMonitor where the Prometheus Operator contract exists
- Grafana dashboards as code, with environment-specific adjustments
- namespace / project naming conventions
- image pull from GHCR with the right pull secret contract

The non-portable scope is:

- Terraform that provisions AKS
- Azure PostgreSQL infrastructure
- Azure networking
- Azure Storage remote Terraform backend
- Azure OIDC / Microsoft Entra federation for GitHub Actions
- AKS-specific cluster access and lifecycle scripts

So the rule is:

```text
The workload and Kubernetes manifests can be made OpenShift-compatible.
The Azure / AKS infrastructure layer cannot be deployed on OpenShift as-is.
```

OpenShift Sandbox is therefore used as a side compatibility lab, not as `dev`,
`staging`, `certification`, or `prod`.

Sandbox should not be treated as a full replacement for AKS non-prod. AKS `dev`
and `staging` keep Azure Database for PostgreSQL because they must validate the
same managed-service dependency shape expected in production.

For Sandbox, the preferred stronger proof is external Azure PostgreSQL
connectivity when networking and firewall rules allow it:

```text
OpenShift Sandbox workload
  -> ConfigMap / Secret contract
  -> Azure PostgreSQL public or otherwise reachable endpoint
```

The practical blocker is network control. Azure PostgreSQL may need to
allow-list OpenShift Sandbox egress IPs, and the shared Sandbox environment may
not expose stable or controllable egress IPs.

If external connectivity is blocked or too noisy, the fallback proof is a
substitute database contract:

```text
OpenShift Sandbox workload
  -> ConfigMap / Secret contract
  -> PostgreSQL pod or mocked DB contract
```

That means Sandbox validates whether the workload can run on OpenShift with the
right application, secret, service, route, and image-pull contracts. It does not
prove Azure PostgreSQL provisioning, Azure private DNS, Azure networking, or
managed backup behavior.

It should validate questions such as:

- does the Helm chart deploy cleanly on OpenShift?
- does the container run with OpenShift security expectations?
- does the workload need explicit non-root or securityContext changes?
- does GHCR image pull behavior require a pull secret adjustment?
- does the app need an OpenShift Route in addition to Kubernetes Ingress?
- do ServiceMonitor labels and selectors still match the monitoring contract?
- can the app start against external Azure PostgreSQL when networking allows it?
- can the app still start against a PostgreSQL pod or mocked DB contract when
  external connectivity is blocked?

### Sandbox capability checks

Before drawing or installing the fuller observability stack in Sandbox, confirm
what is actually available and allowed.

Inspect the project and installed resources:

```bash
oc project
oc get projects
oc get all
oc get pods
oc get svc
oc get routes
oc get configmaps
oc get secrets
```

Inspect whether monitoring APIs exist:

```bash
oc get servicemonitor
oc get prometheus
oc get alertmanager
oc api-resources | grep -i monitor
oc api-resources | grep -i prometheus
oc api-resources | grep -i grafana
```

Check whether the current Sandbox identity can create the needed resources:

```bash
oc auth can-i create servicemonitors
oc auth can-i create prometheuses
oc auth can-i create alertmanagers
oc auth can-i create routes
oc auth can-i create secrets
oc auth can-i create configmaps
```

Check whether heavier logging components are realistic:

```bash
oc api-resources | grep -i elastic
oc api-resources | grep -i kibana
oc auth can-i create statefulsets
oc auth can-i create persistentvolumeclaims
oc get resourcequotas
oc describe quota
oc describe limitrange
```

Decision rule:

```text
If the component is installed or allowed in Sandbox, it can appear in the
Sandbox runtime proof.

If it is not installed or not allowed, keep it in the AKS non-prod architecture
and document Sandbox as a compatibility proof only.
```

Recommended sequence:

1. Prove the app compatibility path: `Route -> Service -> Pod -> ConfigMap / Secret -> DB`.
2. Prove the metrics contract: `/actuator/prometheus` and `ServiceMonitor` if allowed.
3. Add Prometheus / Grafana / Alertmanager only if Sandbox quotas and permissions allow it.
4. Avoid Elasticsearch / Kibana in Sandbox unless resource quotas and storage make it practical.

## What is deferred to Stage 3

The following concerns are intentionally treated as later-stage architecture
features rather than the main purpose of Stage 2:

- hybrid Azure and AWS platform design
- on-prem platform compatibility direction
- multi-cluster operating patterns across different hosting models
- service-mesh traffic governance through OpenShift Service Mesh (Istio-based)
- stronger portability design across providers
- broader enterprise identity integration across environments
- enterprise-wide observability federation and long-term cross-environment view

Even in Stage 3, the default regulated-style database posture is external
managed or enterprise DBA-managed PostgreSQL, not a critical database hosted
inside OpenShift. PostgreSQL operators such as Crunchy Data, EDB, or
CloudNativePG remain an advanced alternative only if the stage intentionally
studies stateful database operations on OpenShift.

These are multi-cloud and broader enterprise-architecture concerns.

## Why not position OpenShift primarily as a multi-cloud choice?

OpenShift can support multi-environment and hybrid strategies, but that is not
the main reason for using it in Stage 2.

If multi-cloud were made the main reason too early, the repository would blur
two different maturity signals:

- Stage 2: governed shared-platform operations
- Stage 3: broader hybrid-cloud and enterprise architecture credibility

The better progression is:

- Stage 2: use OpenShift for enterprise Kubernetes features and stronger
  platform governance
- Stage 3: extend the platform story into wider hybrid and multi-environment
  architecture concerns, including OpenShift Service Mesh (Istio-based) where
  mesh capabilities are justified

## Practical tradeoff

### Option A - Use OpenShift for Stage 2 enterprise platform features

Pros:

- stronger enterprise Kubernetes credibility
- better platform-governance signal
- clearer shared-platform operating model
- closer fit for regulated organizations with stronger operational standards

Cons:

- adds platform complexity compared with a lighter Kubernetes baseline
- can be overkill if the goal is only to prove simple deployment capability
- introduces vendor-flavored platform thinking earlier

### Option B - Stay only with a lighter upstream or managed Kubernetes baseline

Pros:

- simpler
- easier to explain initially
- fewer platform-specific concepts

Cons:

- weaker enterprise shared-platform signal
- weaker governance story
- less realistic for organizations that expect stronger platform controls

## Decision

The repository uses this progression:

- Stage 1: governed AKS delivery foundation
- Stage 2: OpenShift-ready target architecture and shared-platform governance
  validated through cost-controlled labs
- Stage 3: real OpenShift runtime proof, broader hybrid-cloud / enterprise
  architecture direction, and OpenShift Service Mesh (Istio-based) when
  mesh-level controls are needed

So the rule is:

- OpenShift in Stage 2 is mainly about enterprise Kubernetes operating features
  and architecture direction, not mandatory permanent runtime implementation
- real OpenShift runtime proof moves to Stage 3
- multi-cloud is a later architecture concern, not the primary justification

For the ADR that records the cost-controlled validation strategy, see
[ADR-016 - Use OpenShift-aligned governance in Stage 2 and defer runtime proof to Stage 3](./adrs/ADR-016-use-openshift-aligned-governance-in-stage-2-and-defer-runtime-proof-to-stage-3.md).

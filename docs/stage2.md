## Stage 2 analysis — Governed shared platform with enterprise Kubernetes features

[MAIN DOC: Stage 1 of 3 - Governed AKS delivery foundation for an internal payment review service ->](./README.md)

[IMPLEMENTATION PLAN: Stage 2 progress tracker ->](./stage2-implementation-plan.md)

[SRE LEVERAGE DIRECTION ->](./sre-portfolio-leverage.md)

[AI COLLABORATION MODEL ->](./ai-collaboration-model.md)

[ARCHITECTURE SET: Stage 2 runtime, admission, promotion, and compatibility views ->](./architecture/stage2/README.md)

Stage 2 evolves the Stage 1 delivery foundation into a governed shared platform model designed for enterprise Kubernetes operations in highly regulated environments.

The main objective is no longer only to prove that one internal service can be deployed safely. It is to demonstrate how a platform can support multiple teams, multiple environments, stronger change controls, centralized secrets handling, and safer promotion practices while keeping delivery repeatable and operationally supportable.

This stage introduces enterprise Kubernetes operational features through OpenShift, while keeping the delivery path aligned with platform engineering responsibilities commonly expected in regulated organizations. The focus is on governance, isolation, promotion discipline, and controlled operations rather than only raw deployment capability.

Stage 2 proof: one governed service becomes a reusable shared platform with
controlled promotion, centralized secrets, policy guardrails, security gates,
and operational visibility for multiple teams.

### Main focus areas

- **Platform governance:** OpenShift, stronger project boundaries, RBAC conventions, and shared standards
- **GitOps delivery:** ArgoCD reconciliation instead of direct deployment-only paths
- **Secrets governance:** Vault integration, reduced secret exposure, and stronger runtime secret patterns
- **Security gates:** SAST, SCA, container, IaC, secret, DAST, and policy-as-code checks
- **Dependency governance:** controlled update visibility through reviewed pull requests
- **Operations:** shared observability, log investigation, and platform supportability
- **Environment promotion:** controlled **local -> dev -> staging -> prod** movement with approval, staging E2E evidence, and rollback discipline
- **Multi-team readiness:** explicit Infrastructure, Platform, Security/IAM, Application, and SRE / Production Engineering boundaries

### Controlled internal access boundary

Stage 2 owns the platform-side private access pattern:

```text
trusted network prerequisite
  -> private DNS
  -> internal ingress / gateway
  -> private AKS services
```

It does not implement enterprise ZTNA / SASE / VPN. Palo Alto Prisma Access,
GlobalProtect, enterprise VPN ownership, and broader conditional access belong
to Stage 3 enterprise access architecture.

For the tradeoff behind using OpenShift here, see
[openshift-tradeoffs.md](./openshift-tradeoffs.md).

For the implementation timing decision, see
[ADR-016 - Use OpenShift-aligned governance in Stage 2 and defer runtime proof to Stage 3](./adrs/ADR-016-use-openshift-aligned-governance-in-stage-2-and-defer-runtime-proof-to-stage-3.md).

### Stage 2 architecture set

The architecture is split by purpose so newcomers can follow the evolution
without mixing runtime traffic, admission controls, and delivery governance:

- runtime component interactions
- admission governance
- promotion governance
- OpenShift Sandbox compatibility

See [architecture/stage2/README.md](./architecture/stage2/README.md).

### What changes from Stage 1

Stage 1 proved a governed delivery base for a single stateful internal service.  
Stage 2 extends that base into a shared platform model by introducing:

- stronger environment separation across **dev**, **staging**, and **prod**
- multi-tenant / multi-team isolation through platform boundaries
- GitOps-style reconciliation for safer and more controlled deployments
- centralized secrets handling
- automated dependency update visibility through controlled pull requests
- stronger shared-platform observability and operational governance
- enterprise Kubernetes capabilities better aligned with real production platform teams

### Operating model in this stage

This stage continues to use a clear separation of responsibilities:

- The **infrastructure team** continues to own the foundational cloud and cluster estate
- The **platform team** governs the shared services, platform controls, secrets integration points, and operational standards built on top of that estate
- The **security and IAM team** becomes an explicit actor for identity, access, and secrets governance
- The **application team** delivers and promotes workloads through controlled delivery mechanisms approved by the platform model

This is the point where the platform starts to look less like a single application deployment lab and more like an internal shared service used by multiple delivery teams.

### Core platform capabilities demonstrated

- **OpenShift** is used to represent enterprise Kubernetes operational features for governed shared platforms
- **Terraform** continues to manage repeatable infrastructure and platform configuration
- **Terragrunt** is introduced to reduce repeated Terraform backend, state-key, and environment wiring across non-prod and prod estates
- **GitHub Actions** continues to build, package, and publish application artifacts
- **ArgoCD** introduces a stronger GitOps-style deployment and reconciliation model
- **Vault** strengthens secrets centralization and reduces secret exposure inside delivery pipelines
- **Dependabot** adds dependency update visibility across Maven, GitHub Actions, Docker, and Terraform provider surfaces
- **Checkmarx** introduces enterprise SAST checks as part of the controlled pull request path
- **Snyk** strengthens SCA and dependency vulnerability governance
- **Trivy** adds container image scanning before promotion
- **Checkov** adds IaC scanning for Terraform and Kubernetes configuration risk
- **GitHub Secret Scanning** adds repository and pipeline secret exposure detection
- **OWASP ZAP baseline** adds DAST validation against non-production application routes
- **Kyverno** adds policy-as-code guardrails for Kubernetes admission and platform standards
- **Helm** continues to package Kubernetes application resources in a reusable and controlled way
- **Ansible** supports repeatable platform standardization and operational tasks
- **Prometheus, Grafana, Elasticsearch, and Kibana** improve platform-wide observability for monitoring, investigation, and operational diagnosis
- **Promotion controls** formalize PR gates, staging validation, production approval, rollback readiness, and release communication before production exposure

### Why this stage matters in regulated environments

Highly regulated organizations usually need more than successful deployments. They need:

- clear team boundaries
- controlled promotions across environments
- stronger secret management
- auditable and repeatable delivery behavior
- automated dependency update signals that still require CI, review, and promotion controls before adoption
- SSDLC security gates for code, dependencies, containers, infrastructure-as-code, secrets, and runtime baseline scans
- policy-as-code controls that make platform guardrails explicit and repeatable
- promotion evidence across **dev**, **staging**, and **production**
- human approval points for critical promotions without bypassing automated controls
- shared platform standards
- operational visibility across multiple workloads
- reduced misconfiguration risk in production

This stage is built to reflect those realities.

### Specific OpenShift-oriented features emphasized in Stage 2

This stage is mainly concerned with enterprise Kubernetes operating features
such as:

- stronger project or namespace governance patterns
- more controlled multi-team tenancy boundaries
- stricter service account and RBAC conventions
- stronger route or ingress operating patterns
- policy-aware shared-platform operations
- stronger GitOps alignment for governed promotions
- platform guardrails that improve supportability in regulated environments
- release channels that make QA, PO, application, platform, and operations decisions traceable

This is also the stage where the earlier Stage 1 internal access direction can
become more concrete through work such as:

- stronger internal ingress patterns
- more explicit private DNS integration
- clearer internal service exposure standards
- more governed internal application entry paths

For the preserved future-state access direction behind those items, see
[internal-access-future-direction.md](./internal-access-future-direction.md).

These are the features that justify OpenShift in Stage 2.

### Features intentionally deferred to Stage 3

This stage is not primarily about:

- hybrid Azure and AWS architecture
- on-prem expansion strategy
- multi-cluster portability across different hosting models
- service-mesh traffic governance through OpenShift Service Mesh (Istio-based)
- cross-environment identity standardization at broader enterprise scale
- broader federated observability across environments

Those concerns are treated as Stage 3 architecture features.

### What this stage proves

- ability to evolve a Kubernetes delivery foundation into a governed shared platform
- practical understanding of **dev / staging / prod separation**
- practical understanding of **multi-tenant / multi-team isolation**
- ability to combine **CI** and **GitOps-style CD** in a more controlled operating model
- ability to design governed promotion from pull request to production
- ability to treat dependency updates as governed change requests rather than ad hoc local upgrades
- ability to add SSDLC security gates without turning the stage into a full enterprise AppSec program
- ability to combine automated gates with staging validation, production approval, and rollback discipline
- ability to separate delivery-path security controls from broader SOC, endpoint, SASE, and enterprise security platform ownership
- stronger judgment around secrets handling, platform guardrails, and operational supportability
- stronger enterprise Kubernetes credibility through OpenShift-oriented platform thinking

### Main technical signals for hiring managers

This stage signals hands-on exposure and architectural thinking around:

- OpenShift
- Kubernetes
- Terraform
- Terragrunt
- GitHub Actions
- Dependabot
- Checkmarx
- Snyk
- Trivy
- Checkov
- GitHub Secret Scanning
- OWASP ZAP baseline
- Kyverno
- ArgoCD
- Vault
- QA / PO approval gates
- staging validation, production approval, and rollback runbooks
- Helm
- Docker
- PostgreSQL
- Prometheus / Grafana
- Elasticsearch / Kibana
- Ansible
- Linux platform operations
- governed platform delivery in regulated environments

The later mesh choice, when Stage 3 justifies it, is **OpenShift Service Mesh
(Istio-based)** rather than a standalone upstream mesh.

### Database and OpenShift Sandbox boundary

Stage 2 separates production parity from portability validation.

AKS `dev` and `staging` use **Azure Database for PostgreSQL** so non-prod
validates the same managed-service contract expected in production.

OpenShift Sandbox is different. It validates the portable workload contract:
Project, Route / Service exposure, pull secret, ConfigMap / Secret, and
external Azure PostgreSQL when networking allows it.

If Sandbox networking, firewall rules, DNS, or egress IP limits block external
Azure PostgreSQL, the fallback is a PostgreSQL pod or mocked DB contract.

AKS Terraform, Azure networking, Azure PostgreSQL provisioning, Azure Storage
remote state, Azure OIDC, and AKS lifecycle scripts stay Azure-specific.

Even in Stage 3, the default regulated-style OpenShift database posture remains
external managed or enterprise DBA-managed PostgreSQL. Running PostgreSQL inside
OpenShift is an advanced stateful-platform alternative, not the default.

For the ADR, see
[ADR-017 - Use managed PostgreSQL for non-prod parity and conditional external DB proof in OpenShift Sandbox](./adrs/ADR-017-use-managed-azure-postgresql-for-aks-nonprod-and-substitute-db-for-openshift-sandbox.md).

### Main soft skills demonstrated

This stage is also meant to demonstrate:

- platform ownership thinking
- governance mindset
- risk reduction through standardization
- ability to design safe defaults
- ability to separate team responsibilities clearly
- operational judgment in shared environments
- change control awareness
- communication between platform and application responsibilities

### Main business value of this stage

The business value of Stage 2 is not just more tooling. It is the reduction of delivery risk and operational inconsistency when multiple teams share the same enterprise platform.

### Shared monitoring ownership

Stage 2 keeps one shared non-prod observability stack by default.

Application teams are observed by Prometheus and Grafana, but they do not own
the `monitoring` namespace or dashboard source of truth.

The protection model is:

- Kubernetes RBAC prevents dev identities from changing shared monitoring or
  staging resources.
- GitHub Environments separate dev and staging deployment permissions.
- Grafana permissions limit UI access through folder-level viewer / editor /
  admin roles.
- GitOps restores dashboard ConfigMaps, alert rules, and shared observability
  resources from Git when drift occurs.

Design rule:

```text
Grafana permissions control UI access.
Kubernetes RBAC and GitOps control the source of truth.
```

Diagram rule:

```text
Grafana permissions are not a Kubernetes runtime component.
Runtime diagrams should show real component interactions only.
```

The Stage 2 log investigation path is:

```text
workload logs -> log collector -> Elasticsearch -> Kibana
```

OpenShift Sandbox is handled differently. It is a compatibility runtime, not
the canonical non-prod observability estate.

The fuller stack can be tested in Sandbox only after checking available APIs,
permissions, and quotas with `oc api-resources`, `oc auth can-i`, and resource
quota commands. If Sandbox cannot support it, the Sandbox proof stays focused on
`Route -> Service -> Pod -> ConfigMap / Secret -> DB`, plus `/actuator/prometheus`
and `ServiceMonitor` when allowed.

This stage is meant to show a platform that can:

- reduce repeated manual platform setup work
- reduce inconsistent deployment behavior between teams
- reduce secret handling risk
- reduce dependency drift across application, CI/CD, container, and infrastructure layers
- improve promotion safety between environments
- reduce production release ambiguity through explicit approval, communication, and rollback paths
- improve shared-platform observability
- increase confidence in operating internal services under stricter governance constraints

### Position in the overall progression

- **Stage 1** established delivery credibility
- **Stage 2** establishes governance and shared-platform credibility, with Security and IAM becoming explicit in the operating model
- **Stage 3** will extend this model toward enterprise-ready hybrid cloud and on-prem platform architecture

[NEXT: Stage 3 — Enterprise-ready hybrid governed platform ->](./stage3.md)

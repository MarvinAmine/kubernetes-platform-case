# Stage 2 Implementation Plan

[MAIN DOC: Stage 2 - Governed shared platform with enterprise Kubernetes features ->](./stage2.md)

Stage 2 turns the Stage 1 delivery foundation into a governed shared-platform model.

The work should progress in this order: operating model first, environments second, tooling last.

Governance directives for Stage 2 are captured in
[docs/governance/stage2-governance-directives.md](./governance/stage2-governance-directives.md).

The Stage 2 architecture set is organized by purpose in
[docs/architecture/stage2/README.md](./architecture/stage2/README.md).

The OpenShift implementation timing decision is captured in
[ADR-016 - Use OpenShift-aligned governance in Stage 2 and defer runtime proof to Stage 3](./adrs/ADR-016-use-openshift-aligned-governance-in-stage-2-and-defer-runtime-proof-to-stage-3.md).

## Progress Tracker

| Step | Scope | Status |
| --- | --- | --- |
| 1 | Create the Stage 2 implementation plan | Completed |
| 2 | Define the environment model | Completed |
| 3 | Refactor configuration for multi-environment support | In progress |
| 4 | Add the promotion workflow design | Pending |
| 5 | Add Stage 2 tools after the model is stable | Pending |

## 1. Stage 2 Planning

Define what changes and what stays stable from Stage 1.

Changes expected in Stage 2:

- `infrastructure/`: environment-aware Terraform variables, naming and tags, networking prerequisites, identity / secrets foundations, and observability / logging prerequisites needed by the shared platform
- `platform/`: environment-aware Kubernetes resources, policy guardrails, GitOps direction, secrets integration, shared observability hardening
- `application/`: environment-aware Helm values and runtime configuration
- `reliability/`: promotion runbooks, rollback notes, log and dashboard direction
- `.github/workflows/`: clearer validation, promotion, and approval workflow boundaries
- `docs/`: environment model, promotion model, security gate decisions, rollback process, and Stage 1 -> Stage 2 evolution notes
- `docs/governance/`: high-level architecture, service-level, promotion, and compliance boundaries consumed by implementation teams

Stage 2 infrastructure should support the shared platform. It should not become
a full enterprise hybrid architecture yet. Hybrid cloud, on-prem, certification
environment, enterprise identity integration, SIEM / SOC / ITSM direction, and
formal compliance mapping remain Stage 3 or later concerns.

## Infrastructure Architecture Choices

Stage 2 introduces multi-environment infrastructure, but keeps the human
entrypoint simple.

Design principle:

```text
Humans choose the environment. Scripts and Terragrunt resolve the files.
```

### `.env` role

`.env` should remain limited to local operator secrets and account-level values
that should not be duplicated in every environment file.

Examples:

- Azure subscription identifiers
- tenant identifiers
- local-only secret values
- GitHub / Azure bootstrap values that are not environment-specific

Stage 2 scripts should load `.env` internally when needed. Newcomers should not
have to run `source .env` manually before every command.

### Terraform variable files role

Environment-specific non-secret configuration should move to Terraform variable
files or Terragrunt inputs.

Expected inputs:

```text
infrastructure/azure/env/
  dev.tfvars
  staging.tfvars
  prod.tfvars
```

These files should hold values such as:

- resource names
- locations
- tags
- VM sizes
- network CIDR ranges
- PostgreSQL sizing
- AKS sizing
- environment labels

### Terragrunt role

Terragrunt becomes justified in Stage 2 because the platform now has repeated
Terraform environments and separate state keys.

Stage 2 should introduce Terragrunt to reduce:

- repeated backend configuration
- repeated Terraform commands
- repeated environment wiring
- manual selection of state keys and variable files

Recommended direction:

```text
infrastructure/
  azure/
    env/
      dev.tfvars
      staging.tfvars
      prod.tfvars
    live/
      stage2/
        nonprod/
          terragrunt.hcl
        prod/
          terragrunt.hcl
```

Terragrunt in Stage 2 should manage Azure multi-environment structure. Stage 3
can extend the same pattern toward hybrid Azure / AWS / on-prem architecture.

### Bash wrapper role

Bash scripts should remain the human-friendly entrypoints in Stage 2.

They should evolve from manual `.env` sourcing toward explicit environment
flags:

```bash
./bootstrap_infrastructure_and_provision_platform.sh --env nonprod
./bootstrap_infrastructure_and_provision_platform.sh --env prod
```

The wrapper should resolve:

```text
--env nonprod
  -> infrastructure/azure/live/stage2/nonprod/terragrunt.hcl
  -> non-prod Terraform state key
  -> dev and staging Kubernetes namespaces
  -> application values for dev and staging

--env prod
  -> infrastructure/azure/live/stage2/prod/terragrunt.hcl
  -> prod Terraform state key
  -> prod Kubernetes namespace
  -> application values for prod
```

## Stage 2 Cluster Model

Stage 2 should use two clusters:

```text
aks-stage2-nonprod-platform
  namespaces:
    payment-exception-review-dev
    payment-exception-review-staging

aks-stage2-prod-platform
  namespaces:
    payment-exception-review-prod
```

Why two clusters:

- production is isolated at the cluster boundary
- dev and staging stay cost-efficient in a shared non-prod estate
- promotion remains realistic without creating unnecessary cluster sprawl
- the model is easier to explain and operate than three separate clusters

Avoid a single cluster because production isolation would be weak. Avoid three
clusters because the extra cost and Terraform complexity would not add enough
Stage 2 value.

## Expected Infrastructure Changes

For Stage 2, `infrastructure/` should change only to support
multi-environment shared-platform governance.

### 1. Environment-specific Terraform inputs

Add `dev`, `staging`, and `prod` variable files or equivalent Terragrunt inputs.

Example:

```text
infrastructure/azure/env/
  dev.tfvars
  staging.tfvars
  prod.tfvars
```

### 2. Naming and tagging

Add consistent environment-aware names.

Example:

```text
rg-stage2-nonprod-aks
rg-stage2-prod-aks
aks-stage2-nonprod-platform
aks-stage2-prod-platform
```

Add tags such as:

```hcl
environment = "nonprod"
owner       = "infrastructure-team"
stage       = "stage2"
cost_center = "platform-demo"
```

### 3. Identity / secret foundation

Prepare the infrastructure prerequisites for stronger secret governance:

- managed identity or workload identity support
- Key Vault or Vault integration prerequisites
- access boundaries for platform-managed secrets

Keep actual Vault platform integration mostly under `platform/`.

### 4. Networking prerequisites

Prepare only the networking needed for Stage 2:

- internal ingress readiness
- private DNS direction
- environment-specific network names or CIDR planning

Do not build complex hub/spoke networking unless Stage 2 explicitly needs it.

Stage 2 owns the platform-side private access pattern:

```text
trusted network prerequisite
  -> private DNS
  -> internal ingress / gateway
  -> private AKS application and observability services
```

Stage 2 does not own the full enterprise access stack. The following are
enterprise network/security concerns and belong to Stage 3 or later:

- Palo Alto Prisma Access / GlobalProtect
- full ZTNA / SASE implementation
- enterprise VPN ownership
- enterprise WAF standardization
- broader Okta / Microsoft Entra conditional access model

Stage 2 may assume a trusted network or VPN exists, but it should not implement
or claim ownership of that enterprise access layer.

### 5. Observability / logging prerequisites

Add only what the platform layer needs for Stage 2 visibility:

- optional diagnostic settings
- optional Log Analytics direction
- cluster-level logging prerequisites if required by the shared-platform model

### 6. Terraform backend separation

Use separate Terraform state keys per Stage 2 estate.

Recommended pattern:

```text
tfstate/stage2/nonprod/terraform.tfstate
tfstate/stage2/prod/terraform.tfstate
```

If `dev` and `staging` later need stronger isolation, they can split into
separate state keys. Stage 2 should start with non-prod and prod estates to keep
the model understandable.

## Infrastructure Boundaries

Stage 2 should not introduce:

- hybrid Azure / AWS architecture
- on-prem architecture
- full compliance environment
- enterprise SIEM / SOC / ITSM implementation
- complex multi-region design unless required
- full OpenShift infrastructure unless Stage 2 explicitly decides to implement OpenShift rather than document it

Practical first infrastructure task:

> Refactor `infrastructure/azure` to support environment-specific variables,
> tags, naming, Terragrunt environment wrappers, and Terraform state keys for
> non-prod and prod estates.

## Database Hosting Decision

Stage 2 uses different PostgreSQL hosting models depending on what each
environment is meant to prove.

| Environment | PostgreSQL model | Purpose |
| --- | --- | --- |
| local developer runtime | PostgreSQL pod | Fast local validation without Azure dependency |
| OpenShift Sandbox | Preferred: external Azure PostgreSQL if networking allows it. Fallback: PostgreSQL pod or mocked DB contract | OpenShift workload compatibility proof |
| AKS dev | Azure Database for PostgreSQL | Real managed-service contract validation |
| AKS staging | Azure Database for PostgreSQL | Production-like promotion validation |
| AKS prod | Azure Database for PostgreSQL | Managed production dependency |

The rule is:

```text
Local and Sandbox optimize for portability and cost.
AKS non-prod optimizes for production parity.
```

AKS `dev` and `staging` should not use PostgreSQL pods as the default database
model. They should validate the same dependency shape as production:

```text
Spring Boot workload in AKS
  -> Kubernetes ConfigMap / Secret contract
  -> Azure Database for PostgreSQL
```

OpenShift Sandbox is not `prod`. It is a temporary compatibility lab. The
preferred stronger proof is external Azure PostgreSQL connectivity when
networking and firewall rules allow it:

```text
Spring Boot workload in OpenShift Sandbox
  -> OpenShift Project
  -> Route / Service exposure
  -> pull secret
  -> ConfigMap / Secret contract
  -> Azure PostgreSQL public or otherwise reachable endpoint
```

The main practical blocker is that Azure PostgreSQL may require allow-listing
Sandbox egress IPs, while the shared Sandbox environment may not provide stable
or controllable egress IPs.

If external connectivity is blocked, use PostgreSQL in a pod or a mocked DB
contract as the fallback compatibility proof.

Azure PostgreSQL provisioning, Azure networking, Azure private DNS, Azure OIDC,
and AKS Terraform remain Azure-specific infrastructure concerns.

Stage 3 should still default to external managed or enterprise DBA-managed
PostgreSQL for regulated-style OpenShift runtime proof. PostgreSQL operators
inside OpenShift are a later advanced alternative only if the stage explicitly
studies stateful database operations.

## Platform Architecture Choices

Stage 2 platform work should turn the Stage 1 Kubernetes bootstrap into an
environment-aware shared-platform layer.

The `platform/` folder should own Kubernetes runtime boundaries and shared
platform services. It should not own application code or application business
health logic.

### Current Stage 1 platform baseline

Stage 1 already has:

- Kubernetes resource provisioning under `platform/kubernetes-resources/`
- namespace, service account, RBAC, ConfigMap, and runtime boundary creation
- runtime database secret injection contract
- local and dev platform scripts
- shared Prometheus / Grafana observability stack
- platform-owned Grafana dashboards as code
- observability troubleshooting runbooks

Stage 2 should preserve that baseline and make it multi-environment.

### Expected platform changes

For Stage 2, `platform/` should change to support:

- environment-aware namespaces for `dev`, `staging`, and `prod`
- environment-aware service accounts and RBAC
- environment-aware runtime ConfigMaps
- environment-aware runtime secret naming contracts
- platform labels for `stage`, `environment`, `owner`, and `managed-by`
- shared observability hardening for non-prod and prod clusters
- GitOps-ready manifests for ArgoCD adoption
- policy-as-code guardrails with Kyverno
- secrets integration contracts for Vault direction
- promotion-safe platform conventions used by application Helm releases

### Recommended platform folder direction

Keep folders capability-based, not stage-based.

Recommended direction:

```text
platform/
  kubernetes-resources/
    terraform/
    env/
      local/
      dev/
      staging/
      prod/
    gitops/
      argocd/
    policies/
      kyverno/
    secrets-integration/
      vault/
    observability/
      grafana/
      prometheus/
      alertmanager/
    scripts/
      cloud/
      cluster/
```

Do not create:

```text
platform/stage1/
platform/stage2/
platform/shared/
```

Folder names should describe the platform capability, not the stage where the
capability was introduced.

### Environment-aware Kubernetes resources

Stage 2 platform resources should make the environment explicit.

Recommended namespace model:

```text
payment-exception-review-dev
payment-exception-review-staging
payment-exception-review-prod
```

Recommended labels:

```yaml
app.kubernetes.io/part-of: payment-exception-review
app.kubernetes.io/managed-by: platform-team
platform.stage: stage2
platform.environment: dev
platform.owner: platform-team
```

Recommended runtime secret naming:

```text
payment-review-db-dev
payment-review-db-staging
payment-review-db-prod
```

The platform team owns the secret contract and injection pattern. The
application team owns consuming the secret through the Helm chart and runtime
configuration.

### GitOps direction

Stage 2 should prepare platform resources for ArgoCD without forcing every
resource to move at once.

Initial platform GitOps scope:

- namespace definitions
- RBAC conventions
- platform labels
- baseline ConfigMaps
- Kyverno policies
- observability dashboard ConfigMaps

Keep cloud infrastructure provisioning outside ArgoCD. Infrastructure remains
owned by Terraform / Terragrunt.

### Policy-as-code direction

Kyverno policies should start with platform guardrails that are easy to explain:

- required labels
- restricted privileged containers
- image pull policy conventions
- namespace boundary conventions
- resource request / limit direction
- disallow default service account usage for application workloads

Do not start with a large policy library. Stage 2 should prove a focused set of
guardrails tied to the shared-platform operating model.

### Secrets integration direction

Stage 2 should prepare Vault integration without overbuilding it.

Platform responsibilities:

- define the Kubernetes secret naming contract
- define where Vault integration will attach
- define service account / workload identity boundaries
- document how application workloads receive runtime secrets

Application responsibilities:

- consume the secret contract
- avoid hardcoded secret values
- keep Helm values environment-aware

Infrastructure responsibilities:

- provide identity and access prerequisites for secret integration

### Observability hardening

Stage 2 platform observability should remain platform-owned.

Platform-owned observability:

- Prometheus / Grafana installation
- platform health dashboards
- Kubernetes networking / node / Prometheus dashboards
- dashboard provisioning as code
- scrape conventions and labels
- Grafana folder permissions and viewer / editor / admin boundaries

Reliability-owned observability:

- service SLO direction
- application health dashboards
- alert rules
- incident and rollback runbooks

The split keeps platform health separate from application reliability.

### Shared monitoring protection model

Stage 2 should use one shared non-prod observability stack by default.

The key separation is:

```text
Application teams are observed by monitoring.
Application teams do not own monitoring.
```

Recommended ownership:

| Scope | Owner | Rule |
| --- | --- | --- |
| `monitoring` namespace | Platform / SRE | Only platform-owned identities can update or delete observability resources |
| Prometheus / Grafana installation | Platform / SRE | Installed and reconciled through Helm, Kustomize, and later GitOps |
| dashboard ConfigMaps | Platform / SRE or Reliability through PR | Source of truth is Git, not manual UI edits |
| dev application namespace | Application team | Application deployment permissions only |
| staging application namespace | Application team with promotion gate | Deployment only after staging workflow / approval path |

Protection controls:

- Kubernetes RBAC prevents dev identities from changing `monitoring` or
  `payment-exception-review-staging`.
- GitHub Environments separate `dev`, `staging`, and later `prod` deployment
  permissions.
- Kyverno can block unauthorized updates or deletes on shared observability
  resources.
- ArgoCD can reconcile deleted or drifted dashboard ConfigMaps back from Git.
- Grafana permissions limit UI actions, but Kubernetes RBAC and GitOps remain
  the source-of-truth controls.

Grafana folder model:

| Folder | Default access |
| --- | --- |
| Shared Platform | Platform / SRE editor, dev and QA viewer |
| Application - Dev | Platform / SRE editor, dev viewer |
| Application - Staging | Platform / SRE editor, QA / PO / dev viewer as needed |
| Production | Platform / SRE editor, restricted viewer access |

Design rule:

```text
Grafana permissions control UI access.
Kubernetes RBAC and GitOps control the source of truth.
```

Architecture diagram rule:

```text
Do not model Grafana permissions as a Kubernetes runtime component.
Show Grafana, dashboards, Prometheus, log collectors, Elasticsearch, and Kibana
only where they participate in real runtime interactions.
```

The default Stage 2 model should not duplicate Grafana per environment. Use one
shared non-prod Grafana with dashboards filtered by `environment`, `namespace`,
and workload labels. Split dashboards or observability stacks only when
ownership, retention, access control, or alerting behavior must differ.

### OpenShift Sandbox observability check

The OpenShift Sandbox compatibility diagram should only draw observability
components that are actually installed or allowed in the Sandbox proof.

The fuller Stage 2 observability stack is:

```text
Prometheus
Grafana
Alertmanager
log collector
Elasticsearch
Kibana
dashboard ConfigMaps
```

This stack is compatible with OpenShift in principle, but it should not be
assumed in Developer Sandbox. Check the available APIs, permissions, and quotas
first:

```bash
oc api-resources | grep -i monitor
oc api-resources | grep -i prometheus
oc api-resources | grep -i grafana
oc api-resources | grep -i elastic
oc api-resources | grep -i kibana
oc auth can-i create servicemonitors
oc auth can-i create prometheuses
oc auth can-i create alertmanagers
oc auth can-i create statefulsets
oc auth can-i create persistentvolumeclaims
oc get resourcequotas
oc describe quota
oc describe limitrange
```

Decision rule:

```text
Sandbox first proves workload compatibility.
Full observability belongs in Sandbox only if the resources are available and
the quota can support them.
```

Implementation order:

1. `Route -> Service -> Pod -> ConfigMap / Secret -> DB`
2. `/actuator/prometheus` and `ServiceMonitor` if allowed
3. Prometheus / Grafana / Alertmanager if quotas allow
4. Elasticsearch / Kibana only if storage and memory quotas make it practical

### Platform boundaries

Stage 2 platform work should not introduce:

- full enterprise SIEM integration
- full application SLO program
- full OpenShift migration unless explicitly selected
- hybrid cloud platform abstractions
- certification-environment controls
- formal compliance control implementation

Practical first platform task:

> Refactor `platform/kubernetes-resources` to support environment-aware
> namespace, RBAC, ConfigMap, secret-contract, labels, and observability
> conventions for `dev`, `staging`, and `prod`.

Stage 1 should remain replayable from its Git tag and release:

```bash
git checkout stage1-v1.0.0
```

## 2. Environment Model

Stage 2 real environments:

- `local`
- `dev`
- `staging`
- `prod`

Stage 3 deferred environment:

- `certification`

Reason: Stage 2 proves shared-platform governance and controlled promotion. The `certification` environment is better reserved for Stage 3, where compliance-aware release evidence, audit traceability, and stronger enterprise governance become explicit.

Stage 2 reality model:

| Environment | Reality in Stage 2 | Main use | Cluster boundary |
| --- | --- | --- | --- |
| `local` | real | fast developer iteration, no cloud dependency for early validation | local machine / kind |
| `dev` | real | first shared-cloud integration target | `aks-stage2-nonprod-platform` |
| `staging` | real | promotion validation, Postman/Newman E2E, rollback proof | `aks-stage2-nonprod-platform` |
| `prod` | real | governed production target with explicit approval | `aks-stage2-prod-platform` |
| `certification` | deferred to Stage 3 | compliance-aware release evidence and stronger enterprise sign-off | not part of Stage 2 |

Stage 2 promotion path:

```text
local -> dev -> staging -> prod
```

Stage 3 future promotion path:

```text
local -> dev -> staging -> certification -> prod
```

Stage 2 namespace model:

```text
local:
  payment-exception-review-local

nonprod cluster:
  payment-exception-review-dev
  payment-exception-review-staging

prod cluster:
  payment-exception-review-prod
```

Stage 2 Helm release model:

```text
local:
  payment-exception-review-service

dev:
  payment-exception-review-service

staging:
  payment-exception-review-service

prod:
  payment-exception-review-service
```

Keep the Helm release name stable across environments. Let cluster, namespace,
image digest, and GitHub Environment provide the isolation rather than adding
environment-specific release-name sprawl.

Stage 2 label model:

```text
app.kubernetes.io/name=payment-exception-review-service
app.kubernetes.io/part-of=payment-exception-review
platform.stage=stage2
platform.environment=<local|dev|staging|prod>
platform.owner=platform-team
application.owner=application-team
reliability.owner=sre-production-engineering
```

Stage 2 secret and config naming model:

```text
Secret:
  payment-review-db

ConfigMap:
  payment-exception-review-service-config
```

Keep secret and ConfigMap names stable across environments inside each
namespace. Namespace isolation is enough and keeps promotion logic simpler.

Stage 2 environment-specific approval model:

- `local -> dev`: automated checks and merge discipline
- `dev -> staging`: immutable image promotion plus staging deployment
- `staging -> prod`: staging E2E evidence, rollback readiness, and explicit prod approval

Stage 2 observability and ownership tags to keep consistent:

- Grafana and Prometheus dashboards should show the environment label explicitly.
- Logs, metrics, and alerts should carry the same environment naming used by namespaces.
- Workflow evidence should always record environment, cluster, namespace, release, and image digest.

## 3. Multi-Environment Configuration

Stage 2 configuration should separate:

- stable cross-environment defaults
- environment-specific overrides
- local-only operator values
- platform-owned runtime contracts

Configuration ownership by layer:

| Layer | Config responsibility | Example location |
| --- | --- | --- |
| local operator setup | account-level values, bootstrap secrets, local-only values | repository-root `.env` |
| infrastructure | cloud sizing, names, tags, network ranges, cluster and PostgreSQL inputs | `infrastructure/azure/env/*.tfvars` |
| platform | namespace, RBAC, runtime secret contract, labels, observability conventions | `platform/kubernetes-resources/env/` |
| application | app runtime values and chart overrides per environment | `application/payment-exception-review-service/helm/values-*.yaml` |
| reliability | E2E target URLs, promotion evidence, rollback expectations | `reliability/testing/`, `reliability/runbooks/` |

Application Helm values to add or normalize:

```text
values-local.yaml
values-dev.yaml
values-staging.yaml
values-prod.yaml
```

Keep `values-certification.yaml` out of Stage 2 unless it is only a documented placeholder for Stage 3.

Recommended Helm values contract:

```text
values.yaml
  -> safe global defaults shared by every environment

values-local.yaml
  -> local namespace, local DB host, local-only runtime values

values-dev.yaml
  -> dev namespace, shared-cloud dev hostnames, dev observability labels

values-staging.yaml
  -> staging namespace, staging hostnames, staging validation labels

values-prod.yaml
  -> prod namespace, prod hostnames, stricter production runtime values
```

`values.yaml` should contain only defaults that are safe everywhere.

Examples:

- application name
- Service ports
- common probe structure
- common label keys
- image repository name

Environment files should contain only what changes by environment.

Examples:

- namespace
- `environmentName`
- database host
- ingress or route hostname
- replica count if justified
- environment-specific labels
- feature flags
- resource tuning if justified

Do not duplicate the full chart values file in every environment file. Only
override what actually changes.

Platform configuration to make environment-aware:

- namespace per environment
- RBAC per environment
- service account conventions
- runtime database secret naming
- ConfigMap naming
- observability labels
- ServiceMonitor / scrape conventions

Recommended platform folder direction:

```text
platform/
  kubernetes-resources/
    env/
      dev/
      staging/
      prod/
```

Recommended infrastructure folder direction:

```text
infrastructure/
  azure/
    env/
      dev.tfvars
      staging.tfvars
      prod.tfvars
```

Refactor rule:

```text
Keep names stable where namespace isolation is enough.
Split files only when the environment changes behavior.
```

## Application Architecture Choices

Stage 2 application work should make the Spring Boot service deployable through
controlled promotion without rebuilding it per environment.

The `application/` folder should own the service code, Docker packaging, Helm
chart, runtime configuration consumed by the app, and application-facing
deployment behavior.

It should not own Kubernetes platform boundaries, cluster policy, shared
observability installation, or production incident ownership.

### Current Stage 1 application baseline

Stage 1 already has:

- one Spring Boot service under `application/payment-exception-review-service/`
- Maven build and unit tests
- PostgreSQL persistence and Flyway migrations
- Dockerfile and GHCR image delivery
- Helm chart with Deployment, Service, and ServiceMonitor
- local and dev Helm scripts
- OpenAPI documentation
- application failure scenarios and runtime documentation

Stage 2 should preserve that baseline and make deployment environment-aware.

### Expected application changes

For Stage 2, `application/` should change to support:

- Helm values for `local`, `dev`, `staging`, and `prod`
- immutable image tag or digest injection during promotion
- environment-specific Spring configuration values
- environment labels in Kubernetes manifests
- promotion-safe probes and rollout settings
- runtime secret consumption per environment
- staging validation readiness for Postman / Newman E2E checks
- clear separation between app config and platform-owned runtime contracts

### Recommended application folder direction

Keep the current service folder as the application root.

Recommended direction:

```text
application/
  payment-exception-review-service/
    Dockerfile
    pom.xml
    helm/
      Chart.yaml
      values.yaml
      values-local.yaml
      values-dev.yaml
      values-staging.yaml
      values-prod.yaml
      templates/
    scripts/
      cluster/
    src/
```

Do not create:

```text
application/stage1/
application/stage2/
application/shared/
```

Stage history should remain in Git tags and documentation, not duplicated
application folders.

### Helm values model

`values.yaml` should hold safe defaults.

Environment files should override only environment-specific values:

```text
values-local.yaml
values-dev.yaml
values-staging.yaml
values-prod.yaml
```

Examples of environment-specific values:

- namespace
- replica count
- resource requests and limits
- Spring profile or environment name
- runtime config values
- secret names
- ServiceMonitor labels
- image tag or digest selected by the promotion workflow

The image should be built once and promoted. Environment values should not cause
separate Docker builds.

### Image promotion ownership

The application team owns:

- building the image
- publishing the immutable image tag or digest to GHCR
- exposing the Helm value that selects the image
- proving the service can run with environment-specific configuration

The promotion workflow owns which image digest is deployed to each environment.

Recommended principle:

```text
Same image. Different environment configuration.
```

### Runtime configuration ownership

Application-owned configuration:

- Spring Boot runtime properties
- feature flags or validation mode
- business thresholds
- actuator exposure needed by the service
- application log level defaults

Platform-owned configuration contract:

- namespace
- service account
- RBAC
- secret naming convention
- platform labels
- ServiceMonitor scrape convention

Reliability-owned interpretation:

- SLOs
- alerts
- incident runbooks
- service health dashboards

### Staging readiness

The application must expose stable endpoints for staging E2E validation:

- `/actuator/health`
- `/api/payment-exceptions/service-status`
- `/api/payment-exceptions/config-check`
- `/api/payment-exceptions/{id}/status`
- `/actuator/prometheus`

Postman + Newman tests live under `reliability/`, but the application team owns
keeping these API contracts stable enough for promotion gates.

### Application boundaries

Stage 2 application work should not introduce:

- a second business service
- UI E2E testing without a UI
- application-owned cluster policy
- application-owned shared Prometheus / Grafana installation
- full SLO / incident management ownership
- compliance-framework implementation

Practical first application task:

> Refactor the Helm chart to support `values-local.yaml`, `values-dev.yaml`,
> `values-staging.yaml`, and `values-prod.yaml`, while keeping image identity
> injectable by the promotion workflow.

## Stage 2 Tool Placement Before Reliability

These tools should not be spread randomly across team folders. Each one has a
clear ownership purpose.

| Tool | Primary owner | Folder direction | Stage 2 use |
| --- | --- | --- | --- |
| ArgoCD | Platform team | `platform/kubernetes-resources/gitops/` | GitOps desired state for namespaces, RBAC, policies, observability ConfigMaps, and application release targets |
| OpenShift | Platform team | `platform/kubernetes-resources/` and docs | Enterprise Kubernetes operating model: projects, routes, SCC direction, operators, and OpenShift-ready conventions |
| Elasticsearch | Platform team | `platform/kubernetes-resources/observability/` | Shared log storage direction for non-prod and prod platform visibility |
| Kibana | Platform team | `platform/kubernetes-resources/observability/` | Shared log investigation UI direction |
| Ansible | Infrastructure or Platform team | `infrastructure/` or `platform/kubernetes-resources/scripts/` | Optional operational standardization when it replaces repeated manual setup or post-provision validation |

Application impact:

- expose consistent logs, metrics, labels, and actuator endpoints
- keep Helm values environment-aware
- consume platform conventions instead of owning them
- support GitOps promotion by making release configuration predictable

Application should not own ArgoCD, OpenShift platform policy, Elasticsearch,
Kibana, or Ansible unless a narrow app-local helper is justified.

## Reliability Architecture Choices

Stage 2 reliability work should validate and operate the promoted service, not
install the shared platform.

The `reliability/` folder should own service-level validation, rollback
readiness, application health interpretation, and runbooks used by SRE /
Production Engineering.

It should not own Kubernetes namespace bootstrap, cluster RBAC, shared
Prometheus / Grafana installation, ArgoCD platform setup, or infrastructure
provisioning.

### Current Stage 1 reliability baseline

Stage 1 already has:

- a reliability-owned Grafana dashboard for service health
- a clear separation between platform dashboards and application health signals

Current folder:

```text
reliability/
  observability/
    grafana/
      dashboards/
        payment-exception-review-service-health.json
```

Stage 2 should extend this folder into validation and operational readiness.

### Expected reliability changes

For Stage 2, `reliability/` should change to support:

- Postman + Newman staging E2E checks
- staging promotion validation evidence
- rollback runbooks
- log investigation runbooks using Kibana
- service health dashboard direction
- alert rule direction
- production smoke validation notes
- release communication and escalation notes

### Recommended reliability folder direction

Recommended direction:

```text
reliability/
  testing/
    e2e/
      postman/
        payment-exception-review-stage2.postman_collection.json
        environments/
          staging.postman_environment.json
  observability/
    grafana/
      dashboards/
    kibana/
      queries/
  runbooks/
    promotion-validation.md
    rollback.md
    log-investigation.md
    production-smoke-check.md
    incident-response.md
  service-level-objectives/
    README.md
    payment-exception-review-slo.md
  alerts/
    README.md
```

Do not create:

```text
reliability/stage1/
reliability/stage2/
reliability/shared/
```

Folder names should describe operational responsibility, not stage history.

### Staging E2E ownership

Reliability owns the staging E2E gate because it validates operational readiness
before production promotion.

Stage 2 E2E tool choice:

```text
Postman collection + Newman execution
```

The application team owns stable API contracts. Reliability owns the promotion
gate that checks those contracts in staging.

Required Stage 2 staging checks:

- service health
- service status contract
- runtime config check
- payment exception lifecycle status
- Prometheus metrics exposure

Promotion rule:

```text
No staging E2E pass -> no production promotion.
```

### Log investigation ownership

Platform owns Elasticsearch / Kibana installation direction.

Reliability owns:

- useful Kibana queries
- log investigation runbooks
- what to check during failed staging validation
- what to check during rollback decisions

Runtime log investigation flow:

```text
workload stdout / application logs
  -> cluster log collector
  -> Elasticsearch
  -> Kibana
```

Stage 2 should not turn this into full SIEM ownership. SOC / SIEM integration is
Stage 3 or later.

### Rollback ownership

Reliability owns the rollback runbook.

The rollback runbook should define:

- how to identify the currently deployed image digest
- how to identify the previous known-good digest
- how to rollback Helm or GitOps desired state
- which smoke checks must pass after rollback
- what evidence should be attached to the incident or promotion record

### Alerting direction

Stage 2 can document alert rule direction, but should avoid a full production
SLO program.

Useful alert candidates:

- service unavailable
- readiness failures
- high 5xx rate
- sustained latency degradation
- database connectivity failure signal
- missing Prometheus scrape

Full SLO ownership, error budgets, incident process, and production reliability
reviews can mature later.

### SLO / SLA / MTTR direction

Stage 2 should introduce service-level thinking without pretending to offer a
formal external service contract.

The target values come from governance direction and are operationalized by
Reliability. See
[stage2-governance-directives.md](./governance/stage2-governance-directives.md).

Recommended location:

```text
reliability/
  service-level-objectives/
    README.md
    payment-exception-review-slo.md
```

Stage 2 should define:

- **SLIs:** measurable service signals
- **SLO direction:** target behavior for the demo platform
- **MTTR target:** operational recovery target for rollback or restore

Stage 2 should not claim:

- formal SLA
- contractual availability
- mature error-budget process
- RTO / RPO guarantees

Recommended Stage 2 SLIs:

- availability from health checks
- API success rate
- p95 request latency
- Prometheus scrape availability
- database connectivity signal

Recommended Stage 2 SLO direction:

```text
Availability: 99.0% during the demo operating window
API success rate: 99.0% for selected API endpoints
Latency: p95 under 500ms for simple backend endpoints
Metrics: /actuator/prometheus remains scrapeable
```

Recommended Stage 2 MTTR target:

```text
Restore service or rollback within 15 minutes during demo operations.
```

SLA boundary:

```text
No external SLA is claimed in Stage 2.
SLA is a business/legal support commitment and belongs to a later enterprise or compliance stage.
```

### Reliability boundaries

Stage 2 reliability work should not introduce:

- full enterprise SIEM ownership
- full SOC integration
- full ITSM / CAB process
- formal SLA ownership
- full error-budget program
- RTO / RPO guarantees
- platform-owned dashboard installation
- application code changes unless needed to expose stable health signals

Practical first reliability task:

> Add `reliability/testing/e2e/postman/` with a staging Postman collection,
> Newman execution direction, and a rollback runbook skeleton.

## 4. Promotion Workflow Design

Stage 2 should define controlled movement between environments:

```text
PR -> dev
dev -> staging
staging -> prod
```

Required promotion controls:

- PR checks before merge
- automated quality gates
- security scans before promotion
- QA approval before production promotion
- PO approval when business validation is required
- rollback command or runbook
- release communication path
- GitHub Actions workflow ownership by team

Workflow boundaries to define:

- Infrastructure-owned workflows
- Platform-owned workflows
- Application-owned workflows
- Reliability-owned validation or runbook workflows

## DevOps Practice Placement

DevOps practices should not be treated as `.github/workflows/` only.

`.github/workflows/` is the automation layer. The practice itself is distributed
across the repository.

| Practice area | Primary location |
| --- | --- |
| CI/CD automation | `.github/workflows/` |
| Application packaging | `application/.../Dockerfile`, application Helm chart |
| Environment configuration | Helm `values-*.yaml` |
| Promotion rules | workflow logic, GitOps desired state, docs, and runbooks |
| QA-readable E2E tests | Postman collections and Newman execution |
| Security gates | workflows and scanner configuration |
| Policy guardrails | `platform/kubernetes-resources/policies/` |
| GitOps desired state | `platform/kubernetes-resources/gitops/` |
| Runtime conventions | `platform/kubernetes-resources/` |
| Rollback and operational runbooks | `reliability/` and `docs/` |
| Release evidence | GitHub Actions logs, GitHub Releases, release notes, and docs |

## Docker Image Promotion Model

Stage 2 should promote immutable application artifacts. It should not rebuild
the Docker image separately for each environment.

Recommended flow:

```text
PR / merge
  -> build image once
  -> run tests and security gates
  -> push immutable image tag or digest to GHCR
  -> deploy the same artifact to dev
  -> approve promotion
  -> deploy the same artifact to staging
  -> approve promotion
  -> deploy the same artifact to prod
```

Tag-based example:

```text
ghcr.io/marvinamine/payment-exception-review-service:sha-1bbdb4f
```

Digest-based example:

```text
ghcr.io/marvinamine/payment-exception-review-service@sha256:abc123...
```

Digest-based promotion is stronger because it proves that dev, staging, and prod
run the exact same artifact.

Helm values should separate environment configuration from artifact identity.
The image reference should be promoted, not rebuilt.

Example:

```yaml
image:
  repository: ghcr.io/marvinamine/payment-exception-review-service
  tag: sha-1bbdb4f
```

Stage 2 workflow direction:

- `application-app-ci.yml`: build, test, scan, and publish the image
- `application-app-deploy-dev.yml`: deploy the immutable image to dev
- `application-app-promote-staging.yml`: promote the same image to staging
- `application-app-e2e-staging.yml`: run Postman / Newman E2E checks against staging
- `application-app-promote-prod.yml`: promote the same image to prod with approval

Stage 3 can later add stronger ITSM, CAB, audit, and compliance evidence around
the promotion. Stage 2 should already prove artifact promotion discipline.

## Staging E2E Test Model

Stage 2 should use **Postman + Newman** for QA-readable API E2E checks against
the staging environment.

Reason:

- the application is a backend API
- Postman is familiar and readable for QA-facing API validation
- Newman executes the same Postman collection in GitHub Actions
- the test evidence is easy to attach to promotion workflows
- staging needs stronger validation than a pod or health check

Recommended folder:

```text
reliability/
  testing/
    e2e/
      postman/
        payment-exception-review-stage2.postman_collection.json
        environments/
          staging.postman_environment.json
```

Recommended staging E2E checks:

- `GET /actuator/health` returns `UP`
- `GET /api/payment-exceptions/service-status` returns service metadata and `environmentName=staging`
- `GET /api/payment-exceptions/config-check` validates runtime configuration
- `GET /api/payment-exceptions/{id}/status` returns one valid lifecycle state
- `GET /actuator/prometheus` exposes expected metrics

Stage 2 promotion rule:

```text
No staging E2E pass -> no production promotion.
```

Shell scripts can still exist for local smoke checks and troubleshooting
runbooks, but Postman + Newman should be the staging E2E gate.

## GitHub Actions Workflow Architecture

GitHub Actions workflows must stay directly under `.github/workflows/`.
GitHub does not execute workflow files from nested folders, so team separation is
done through naming, triggers, GitHub Environments, and ownership boundaries.

Stage 1 workflows are preserved by the Stage 1 Git tag and GitHub release:

```bash
git checkout stage1-v1.0.0
```

`main` should evolve toward Stage 2. Do not keep Stage 1 workflows and Stage 2
workflows as two active generations unless the older workflow is clearly marked
legacy/manual-only. Duplicate active entrypoints make the delivery model harder
to understand.

Current Stage 1 workflow baseline:

```text
.github/workflows/
  infrastructure-azure-provision.yml
  infrastructure-azure-destroy.yml
  platform-kubernetes-resources-provision.yml
  platform-kubernetes-resources-destroy.yml
  platform-observability-provision.yml
  platform-observability-destroy.yml
  platform-observability-validate.yml
  application-app-ci.yml
  application-app-deploy.yml
  application-app-destroy.yml
  reliability-observability-dashboard-validate.yml
```

The team-prefixed naming model is correct. Stage 2 should evolve it from
single-environment delivery into explicit nonprod, prod, promotion, validation,
and teardown boundaries.

Recommended Stage 2 workflow direction:

```text
.github/workflows/
  repository-pr-governance-validate.yml

  infrastructure-stage2-nonprod-provision.yml
  infrastructure-stage2-nonprod-destroy.yml
  infrastructure-stage2-prod-provision.yml
  infrastructure-stage2-prod-destroy.yml

  platform-stage2-nonprod-provision.yml
  platform-stage2-nonprod-destroy.yml
  platform-stage2-prod-provision.yml
  platform-stage2-prod-destroy.yml
  platform-stage2-policies-validate.yml
  platform-stage2-observability-validate.yml
  platform-stage2-gitops-validate.yml

  application-app-ci.yml
  application-app-deploy-dev.yml
  application-app-destroy-dev.yml
  application-app-promote-staging.yml
  application-app-destroy-staging.yml
  application-app-promote-prod.yml
  application-app-destroy-prod.yml

  reliability-e2e-staging.yml
  reliability-rollback-validate.yml
```

Workflow ownership:

| Workflow family | Owner | Purpose |
| --- | --- | --- |
| `repository-*` | Repository governance | PR naming, issue reference, branch rules, release hygiene |
| `infrastructure-*` | Infrastructure team | Azure, AKS, PostgreSQL, Terraform backend, Terragrunt environment state |
| `platform-*` | Platform team | Kubernetes baseline, policies, observability stack, GitOps contracts |
| `application-*` | Application team | Build, test, scan, package, publish, deploy, promote application artifacts |
| `reliability-*` | SRE / Production Engineering | Staging E2E evidence, rollback validation, service health validation |

Stage 2 should use GitHub Environments for promotion control:

```text
dev
staging
prod
```

Recommended gates:

- PR validation must pass before merge.
- CI must publish one immutable GHCR image reference.
- Dev deployment uses the newly published image.
- Staging promotion reuses the same image reference.
- Reliability E2E must pass against staging.
- Prod promotion requires GitHub Environment approval.
- Prod promotion reuses the same image reference that passed staging.

Required workflow evidence:

- commit SHA
- GHCR image tag and digest
- target environment
- target AKS cluster
- target namespace
- Helm release name
- Terraform or Terragrunt state key
- Newman report for staging E2E
- rollback target image digest

Design rule:

```text
Each workflow should have one accountable owner.
Cross-team orchestration is allowed only when it calls team-owned workflows or
scripts without hiding ownership.
```

Stage 2 should avoid one large workflow that provisions infrastructure,
platform, application, observability, and reliability checks together. That
would be convenient, but it would weaken the operating model.

## DevOps Promotion Practices

Stage 2 should implement the promotion controls that fit the current environment
model and defer certification-specific controls to Stage 3.

Stage 2 practices to implement:

| Practice | Stage 2 placement | Workflow impact |
| --- | --- | --- |
| PR title convention | Repository governance | `repository-pr-governance-validate.yml` |
| Issue or ticket reference | Repository governance | block PRs without traceability |
| One feature per PR | Repository governance | reviewer checklist and PR template |
| Build and unit tests | Application team | `application-app-ci.yml` |
| Integration tests | Application team | `application-app-ci.yml` |
| Test coverage threshold | Application team | CI gate before image publish |
| Peer review | Repository governance | branch protection |
| SAST / quality scan | Application team | Checkmarx or equivalent gate |
| SCA dependency scan | Application team | Snyk gate |
| Container image scan | Application team | Trivy gate before promotion |
| IaC scan | Infrastructure / Platform | Checkov gate for Terraform and Kubernetes manifests |
| Secret scanning | Repository governance | GitHub Secret Scanning gate |
| Feature dependency check | Application team | PR template and reviewer checklist |
| Feature flag decision | Application team | required when rollout risk justifies it |
| Dev deployment | Application team | deploy immutable image to dev |
| Staging promotion | Application + Reliability | promote same image, then run E2E |
| QA-facing E2E validation | Reliability | Postman + Newman against staging |
| Rollback readiness | Reliability | rollback runbook and rollback target digest |
| Production approval | Application + Reliability | GitHub Environment approval for `prod` |

Stage 2 promotion path:

```text
local -> dev -> staging -> prod
```

Stage 2 gate sequence:

```text
PR governance
  -> build / tests / scans
  -> publish immutable GHCR image
  -> deploy dev
  -> promote same image to staging
  -> run Postman / Newman E2E
  -> approve prod
  -> promote same image to prod
```

Stage 3 practices deferred from `test.html`:

- certification environment
- QA / PO certification sign-off
- certification-to-production promotion
- canary or progressive traffic management
- formal deployment-room model with broader stakeholder communication

Reason:

```text
Stage 2 proves controlled promotion and operational validation.
Stage 3 adds certification-grade governance and release controls.
```

## 5. Stage 2 Tooling Order

Add tooling only after the environment and promotion model is stable.

Recommended order:

1. Dependabot
2. Snyk
3. Trivy
4. Checkov
5. GitHub Secret Scanning
6. OWASP ZAP baseline
7. Kyverno
8. ArgoCD
9. Vault
10. OpenShift

Rationale:

- dependency and scan controls are low-risk and immediately visible
- policy-as-code needs stable Kubernetes conventions
- GitOps needs stable environment boundaries
- Vault needs clear runtime secret ownership
- OpenShift should validate the mature platform model, not compensate for an unclear one

## Completion Criteria

Stage 2 is complete when the repository can demonstrate:

- environment-aware configuration across local, dev, staging, and prod
- controlled promotion from PR to production
- clear team-owned workflow boundaries
- centralized secrets direction
- security and dependency gates
- policy guardrails
- rollback path
- shared-platform observability and log investigation direction
- updated documentation explaining what changed from Stage 1

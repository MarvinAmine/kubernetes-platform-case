# Kubernetes Resources

This Terraform layer is managed by the platform team.

Its purpose is to create the platform-managed Kubernetes resources inside AKS before the application team deploys the Spring Boot service.

## Ownership

This layer owns the platform-managed Kubernetes resources required by the application team.

It does not deploy the application itself.

It also represents the correct ownership boundary for shared platform
observability services when they are introduced. Monitoring is treated as a
platform capability rather than as something each application team duplicates
for itself.

## Resources created

The Kubernetes resources Terraform creates:

- Namespace: `payment-exception-review-stage1`
- ServiceAccount: `app-runtime-sa`
- Role: `app-runtime-role`
- RoleBinding: `app-runtime-rb`
- Baseline ConfigMap: `platform-baseline-config`

These resources are prepared in advance so the application delivery path can reuse them instead of creating them.

## Shared monitoring direction

The intended production direction for Kubernetes metrics observability is a
shared platform-level stack per cluster or environment boundary.

Preferred baseline:

- `kube-prometheus-stack`
- shared Prometheus
- shared Grafana
- shared Alertmanager
- governed onboarding through `ServiceMonitor` or `PodMonitor`
- SSO-backed Grafana access
- network isolation and controlled RBAC
- persistent Grafana storage
- Thanos added later for long-term retention and global query

This layer should eventually own the shared monitoring platform installation
and its guardrails, while application teams only expose service metrics and
register scrape targets.

### Why not duplicate Prometheus and Grafana per application?

The default regulated-enterprise tradeoff is to prefer logical isolation over
automatic physical duplication.

Shared monitoring is preferred because it:

- reduces duplicated infrastructure and storage
- reduces dashboard and alert drift
- centralizes patching and operational hardening
- improves auditability and governance consistency

Per-application monitoring stacks should be reserved for stricter cases such
as:

- hard tenancy isolation
- different retention or residency requirements
- compliance scopes that require separate platform instances

## Runtime secret injection

The platform flow also injects the runtime database password secret expected by the application Helm chart.

The shared script:

- `scripts/apply_runtime_db_secret.sh`

applies the Kubernetes secret contract:

- Secret name: `payment-review-db`
- Secret key: `POSTGRES_ADMIN_PASSWORD`

The actual secret value is injected dynamically at runtime:

- locally from `.env` through `POSTGRES_ADMIN_PASSWORD`
- in GitHub Actions from the `POSTGRES_ADMIN_PASSWORD` repository secret

This keeps the secret contract reproducible and versioned without storing the actual password in:

- Git
- Helm values files
- Terraform state

## Scripts

The `scripts/` directory contains operational helpers for this layer.

- `scripts/validate-cluster-access.sh`
  Validates that Azure CLI is logged into the expected subscription, refreshes
  AKS credentials, verifies the active `kubectl` context, and confirms basic
  cluster access before Terraform interacts with the cluster.

- `scripts/apply_runtime_db_secret.sh`
  Applies the runtime Kubernetes secret consumed by the application Helm chart.
  It uses the stable secret contract in code while injecting the real password
  dynamically from local environment variables or GitHub Actions secrets.

This script is intentionally documented here in `docs/` while the executable
logic stays under `scripts/`.

## Local Terraform usage
```bash
cp .env.example .env

source commons/scripts/load_terraform_env.sh
load_repo_env .env .env.example

./platform/kubernetes-resources/scripts/validate-cluster-access.sh

cd platform/kubernetes-resources/terraform
terraform init \
  -backend-config="resource_group_name=<tf-backend-rg>" \
  -backend-config="storage_account_name=<tf-backend-storage-account>" \
  -backend-config="container_name=<tf-backend-container>" \
  -backend-config="key=platform/kubernetes-resources/terraform.tfstate" \
  -backend-config="use_azuread_auth=true"
terraform validate
terraform plan
terraform apply
```

The validation script checks:

- the active Azure subscription matches the expected subscription
- the AKS kubeconfig entry is refreshed with `az aks get-credentials`
- the current `kubectl` context matches the expected cluster name
- `kubectl cluster-info` succeeds
- the `kube-system` namespace is reachable



## GitHub Actions behavior

The workflow `.github/workflows/kubernetes-resources-provision.yml` supports two execution modes:

- `push`
  Runs Terraform format check, init, validate, and plan.

- `workflow_dispatch`
  Runs the same validation steps and also allows `terraform apply`.

This keeps infrastructure changes reviewed on push while reserving real cluster changes for an explicit manual run.

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

The repository also keeps an explicit observability sub-tree for readability:

- `platform/kubernetes-resources/observability/prometheus/`
- `platform/kubernetes-resources/observability/grafana/`
- `platform/kubernetes-resources/observability/alertmanager/`

That split makes the technology stack more visible to new visitors while still
allowing the platform to install one integrated shared stack through
`kube-prometheus-stack`.

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

- `scripts/cluster/apply_runtime_db_secret.sh`

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

- `scripts/cloud/validate_dev_cluster_access.sh`
  Validates that Azure CLI is logged into the expected subscription, refreshes
  AKS credentials, verifies the active `kubectl` context, and confirms basic
  cluster access before Terraform interacts with the cluster.

- `scripts/cluster/apply_runtime_db_secret.sh`
  Applies the runtime Kubernetes secret consumed by the application Helm chart.
  It uses the stable secret contract in code while injecting the real password
  dynamically from local environment variables or GitHub Actions secrets.

- `scripts/cluster/remove_runtime_db_secret.sh`
  Removes the runtime Kubernetes secret consumed by the application Helm chart.
  It stays in the cluster-generic folder because the Kubernetes cleanup is the
  same for local kind and AKS.

This script is intentionally documented here in `docs/` while the executable
logic stays under `scripts/`.

- `observability/install_local_observability_stack.sh`
- `observability/install_dev_observability_stack.sh`
  Environment-specific wrappers that validate the target context and then
  delegate to the shared cluster-generic observability installer.

- `observability/destroy_local_observability_stack.sh`
- `observability/destroy_dev_observability_stack.sh`
  Environment-specific wrappers that delegate to the shared cluster-generic
  observability teardown script before the wider Kubernetes platform resources
  are destroyed.

- `observability/scripts/cluster/install_shared_observability_stack.sh`
- `observability/scripts/cluster/destroy_shared_observability_stack.sh`
  Shared Kubernetes-only Helm logic used by both the local and dev wrappers.

- `.github/workflows/observability-provision.yml`
- `.github/workflows/observability-destroy.yml`
  Platform-owned GitHub Actions workflows for installing and uninstalling the
  shared observability stack in the AKS dev environment.

Workflow example:

![GitHub Actions provision Prometheus and Grafana](../../assets/github_actions_provision_prometheus_grafana.png)

## Shared observability installation

The platform-owned installation path is:

```bash
./platform/kubernetes-resources/observability/install_dev_observability_stack.sh
```

Expected local inputs:

- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`

The script:

- validates AKS access
- delegates to the shared cluster-generic installer
- keeps Grafana credentials out of committed values files

The shared installer then:

- creates the `monitoring` namespace if needed
- installs `kube-prometheus-stack`

After installation:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

The application chart publishes a `ServiceMonitor` into the `monitoring`
namespace so Prometheus can scrape the Spring Boot `/actuator/prometheus`
endpoint across namespaces.

### Real troubleshooting encountered locally

During a real local validation run, the observability installation step failed
with:

```text
Error: context deadline exceeded
```

The actual cluster state showed that:

- Prometheus was already running
- Alertmanager was already running
- the operator was already running
- Grafana was still initializing

So the timeout did not indicate a broken platform setup by itself.

The useful checks were:

```bash
kubectl get pods -n monitoring -w
kubectl get events -n monitoring
kubectl describe pod -n monitoring <grafana-pod-name>
```

In the real run, Grafana eventually became healthy, and the next command:

```bash
./application/payment-exception-review-service/create_local_app_with_helm.sh -s
```

completed successfully.

Interpretation:

- on a first local cluster run, `context deadline exceeded` during
  `kube-prometheus-stack` installation can be a local startup timing issue
- if Grafana is the only component still initializing, wait for it to become
  `Running` before continuing

## Shared observability teardown

The platform teardown flow removes the shared observability stack before the
wider Kubernetes resource destruction continues.

You can also run it directly:

```bash
./platform/kubernetes-resources/observability/destroy_dev_observability_stack.sh
```

For local validation, use:

```bash
./platform/kubernetes-resources/observability/install_local_observability_stack.sh
./platform/kubernetes-resources/observability/destroy_local_observability_stack.sh
```

## Local Terraform usage
```bash
cp .env.example .env

source commons/scripts/load_terraform_env.sh
load_repo_env .env .env.example

./platform/kubernetes-resources/scripts/cloud/validate_dev_cluster_access.sh

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

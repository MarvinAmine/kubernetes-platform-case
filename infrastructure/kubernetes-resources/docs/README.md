# Kubernetes Resources

This Terraform layer is managed by the infrastructure team.

Its purpose is to create the platform-managed Kubernetes resources inside AKS before the application team deploys the Spring Boot service.

## Ownership

This layer owns the platform-managed Kubernetes resources required by the application team.

It does not deploy the application itself.

## Resources created

The Kubernetes resources Terraform creates:

- Namespace: `document-processing-stage1`
- ServiceAccount: `app-runtime-sa`
- Role: `app-runtime-role`
- RoleBinding: `app-runtime-rb`
- Baseline ConfigMap: `platform-baseline-config`

These resources are prepared in advance so the application delivery path can reuse them instead of creating them.

## Scripts

The `scripts/` directory contains operational helpers for this layer.

- `scripts/validate-cluster-access.sh`
  Validates that Azure CLI is logged into the expected subscription, refreshes
  AKS credentials, verifies the active `kubectl` context, and confirms basic
  cluster access before Terraform interacts with the cluster.

This script is intentionally documented here in `docs/` while the executable
logic stays under `scripts/`.

## Local Terraform usage
```bash
cp infrastructure/.env.example infrastructure/.env

export EXPECTED_SUBSCRIPTION_ID="<your-subscription-id>"
export EXPECTED_RESOURCE_GROUP="rg-stage1-aks"
export EXPECTED_AKS_CLUSTER_NAME="aks-stage1-platform"
# Backward-compatible legacy variables also work:
# export SUBSCRIPTION_ID="<your-subscription-id>"
# export RESOURCE_GROUP="rg-stage1-aks"
# export AKS_CLUSTER_NAME="aks-stage1-platform"

./infrastructure/kubernetes-resources/scripts/validate-cluster-access.sh

cd infrastructure/kubernetes-resources/terraform
terraform init \
  -backend-config="resource_group_name=<tf-backend-rg>" \
  -backend-config="storage_account_name=<tf-backend-storage-account>" \
  -backend-config="container_name=<tf-backend-container>" \
  -backend-config="key=kubernetes-resources/terraform.tfstate" \
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

# GitHub Actions Workflows

This document is the authoritative runbook for the GitHub Actions workflows
used in this repository.

It answers three questions:

- which workflow or script owns each Stage 1 delivery step
- what must already exist before that step runs
- in what order the workflows should be triggered

## Workflow summary

| Layer | Action | Primary path | Manual only? | Why | Credentials / secret source |
| --- | --- | --- | --- | --- | --- |
| Terraform backend | Create | local bootstrap script | Yes | Terraform needs the backend before the normal cloud workflows can initialize remote state | local `.env` values and Azure CLI session |
| Azure foundation | Provision | GitHub Actions or dev script | No | this is a normal Infrastructure team delivery path after backend bootstrap | GitHub OIDC plus repository variables and secrets |
| Kubernetes resources | Provision | GitHub Actions or dev script | No | this is a normal Platform team delivery path after Azure foundation exists | GitHub OIDC plus repository variables and secrets |
| Shared observability | Provision | GitHub Actions or dev script | No | this is a normal Platform team cluster lifecycle after AKS and Kubernetes resources exist | GitHub OIDC plus `GRAFANA_ADMIN_PASSWORD` |
| Application | Deploy | GitHub Actions or dev script | No | this is a normal Application team delivery path after platform prerequisites exist | GitHub OIDC plus repository variables and secrets |
| Application | Destroy | GitHub Actions or dev script | No | normal application lifecycle cleanup | GitHub OIDC plus repository variables and secrets |
| Shared observability | Destroy | GitHub Actions or dev script | No | normal platform lifecycle cleanup | GitHub OIDC plus repository variables and secrets |
| Kubernetes resources | Destroy | GitHub Actions or dev script | No | normal platform lifecycle cleanup while AKS still exists | GitHub OIDC plus repository variables and secrets |
| Azure foundation | Destroy | GitHub Actions or dev script | No | normal infrastructure lifecycle cleanup after higher layers are removed | GitHub OIDC plus repository variables and secrets |

## Bootstrap prerequisite

Before the normal GitHub Actions workflows are usable, the remote Terraform
backend must already exist.

That backend is a bootstrap concern, not a normal day-to-day workflow concern.
It is created through the repository bootstrap path, not through a standard
GitHub Actions workflow.

Use one of these paths first:

- local bootstrap script: `./bootstrap_infrastructure_and_provision_platform.sh`
- backend bootstrap script: `./infrastructure/terraform-backend/create_remote_backend.sh`

Why this is separate:

- Terraform needs the backend before the normal Azure and Kubernetes Terraform
  workflows can initialize state
- this repository intentionally follows the decision recorded in
  [ADR-006](./adrs/ADR-006-do-not-create-a-standard-github-actions-workflow-for-the-remote-terraform-backend.md)

## Required repository configuration

Before the cloud workflows run successfully, these must already be configured:

- GitHub repository variables
- GitHub repository secrets
- Azure OIDC trust for GitHub Actions

Reference:

- [configuration-reference.md](./configuration-reference.md)
- [Azure OIDC For GitHub Actions](../infrastructure/azure/docs/OIDC.md)

## PostgreSQL credential path

The PostgreSQL admin password is injected in two different places during the
Stage 1 flow:

1. Azure infrastructure creation
2. Kubernetes runtime secret injection

The source value is:

- local path: `POSTGRES_ADMIN_PASSWORD` in `.env`
- GitHub Actions path: `POSTGRES_ADMIN_PASSWORD` GitHub repository secret

The flow is:

1. the Azure foundation uses `POSTGRES_ADMIN_PASSWORD` as
   `TF_VAR_postgres_admin_password`
2. the Kubernetes resources layer injects the same value into the Kubernetes
   secret `payment-review-db`
3. the application Helm release references that existing secret instead of
   receiving the raw password directly

That means the application deployment does not create the database password by
itself. It consumes the platform-provided secret created earlier in the
platform provisioning sequence.

## Provision order

The normal Stage 1 cloud order is:

1. remote Terraform backend bootstrap
2. Azure foundation
3. Kubernetes resources
4. shared observability stack
5. application deployment

## Workflow map

### 1. Azure foundation

Purpose:
- provision the Azure resource group, AKS cluster, and managed PostgreSQL foundation

Local script path:
- `./infrastructure/azure/create_azure_resources.sh`
- or the higher-level orchestrator: `./bootstrap_infrastructure_and_provision_platform.sh`

GitHub Actions workflow:
- `.github/workflows/infrastructure-azure-provision.yml`

Requirements:
- remote Terraform backend already exists
- GitHub repository variables are configured
- GitHub repository secrets are configured
- Azure OIDC credentials exist

Trigger model:
- `push` on `infrastructure/azure/terraform/**`
- `workflow_dispatch`

### 2. Kubernetes resources

Purpose:
- provision the platform-owned Kubernetes Terraform layer and inject the runtime DB secret

Local script path:
- `./platform/kubernetes-resources/apply_dev_kubernetes_resources.sh`
- or the higher-level orchestrator: `./bootstrap_infrastructure_and_provision_platform.sh`

GitHub Actions workflow:
- `.github/workflows/platform-kubernetes-resources-provision.yml`

Requirements:
- remote Terraform backend already exists
- Azure foundation already exists
- GitHub repository variables are configured
- GitHub repository secrets are configured
- Azure OIDC credentials exist

Trigger model:
- `push` on `platform/kubernetes-resources/terraform/**`
- `workflow_dispatch`

### 3. Shared observability stack

Purpose:
- install the shared `kube-prometheus-stack` components in the AKS cluster

Local script path:
- `./platform/kubernetes-resources/observability/install_dev_observability_stack.sh`
- or the higher-level orchestrator: `./bootstrap_infrastructure_and_provision_platform.sh`

GitHub Actions workflow:
- `.github/workflows/platform-observability-provision.yml`

Requirements:
- Azure foundation already exists
- AKS cluster is reachable
- Kubernetes resources path has already been provisioned
- `GRAFANA_ADMIN_PASSWORD` GitHub secret is configured
- Azure OIDC credentials exist

Notes:
- this workflow is cluster-focused and does not depend on the application being deployed
- `GRAFANA_ADMIN_USER` is optional and defaults to `admin`

Trigger model:
- `workflow_dispatch`

### 4. Application deployment

Purpose:
- build the Spring Boot image, push it to GHCR, and deploy the Helm release into AKS

Local script path:
- `./application/payment-exception-review-service/create_dev_app_with_helm.sh`

GitHub Actions workflow:
- `.github/workflows/application-app-deploy.yml`

Requirements:
- Azure foundation already exists
- AKS cluster is reachable
- Kubernetes resources path has already been provisioned
- GitHub repository variables are configured
- GitHub repository secrets are configured
- Azure OIDC credentials exist

Recommended but not strictly required:
- shared observability stack already installed

Why recommended:
- it gives Prometheus and Grafana a ready target once the app is deployed
- it keeps the full platform story coherent during validation

Trigger model:
- `workflow_dispatch`

## Destroy order

The normal Stage 1 cloud destroy order is the reverse:

1. application destroy
2. observability destroy
3. Kubernetes resources destroy
4. Azure destroy

The remote Terraform backend remains separate and is not part of the normal
destroy workflow chain.

### Application destroy

Local script path:
- `./application/payment-exception-review-service/destroy_dev_app_with_helm.sh`

GitHub Actions workflow:
- `.github/workflows/application-app-destroy.yml`

Requirements:
- Azure foundation still exists
- AKS cluster still exists
- Azure OIDC credentials exist

### Observability destroy

Local script path:
- `./platform/kubernetes-resources/observability/destroy_dev_observability_stack.sh`

GitHub Actions workflow:
- `.github/workflows/platform-observability-destroy.yml`

Requirements:
- Azure foundation still exists
- AKS cluster still exists
- Azure OIDC credentials exist

### Kubernetes resources destroy

Local script path:
- `./platform/kubernetes-resources/destroy_dev_kubernetes_resources.sh`

GitHub Actions workflow:
- `.github/workflows/platform-kubernetes-resources-destroy.yml`

Requirements:
- remote Terraform backend still exists
- Azure foundation still exists
- AKS cluster still exists
- Azure OIDC credentials exist

### Azure destroy

Local script path:
- `./infrastructure/azure/destroy_azure_resources.sh`
- or the higher-level orchestrator: `./destroy_infrastructure_and_platform.sh`

GitHub Actions workflow:
- `.github/workflows/infrastructure-azure-destroy.yml`

Requirements:
- remote Terraform backend still exists
- GitHub repository variables are configured
- GitHub repository secrets are configured
- Azure OIDC credentials exist

## Quick summary

Use this mental model:

- backend first, outside the normal workflow chain
- Azure before Kubernetes
- Kubernetes before observability and app
- observability before app is recommended
- destroy in reverse order

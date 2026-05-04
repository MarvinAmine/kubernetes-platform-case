# Configuration Reference

This document centralizes the environment variables, GitHub repository variables, and GitHub secrets used by the repository.

## Repository root `.env`

Create the local environment file from the repository root:

```bash
cp .env.example .env
```

The repository-root `.env` is the single local configuration source. Local wrapper scripts derive the Terraform-specific `TF_VAR_*` names from it through:

- `commons/scripts/load_terraform_env.sh`

So the root `.env` should keep the generic operational names only. Do not add duplicate `TF_VAR_*` aliases there.

Important distinction:

- `TF_VAR_*` is for normal Terraform input variables used by resources and modules.
- Terraform backend settings are different. They are loaded before normal input variables.
- Because of that, backend settings should not be modeled as regular Terraform `variable` inputs.
- In this repository, backend settings are handled through a combination of:
  - required static shape in `backend.tf`
  - `terraform init -backend-config=...`
  - local wrapper scripts and GitHub Actions workflow init steps

### Core local variables

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `REPO_OWNER` | Yes | `MarvinAmine` | GitHub user or organization that owns the repository. Used by the Azure OIDC scripts to build the federated credential subject for GitHub Actions. |
| `SUBSCRIPTION_ID` | Yes | `<your-azure-subscription-id>` | Azure subscription ID used by all local infrastructure scripts, Terraform layers, and the OIDC setup. |
| `RESOURCE_GROUP` | Yes for Azure and Kubernetes provisioning | `rg-stage1-aks` | Azure resource group name for the AKS platform resources. Passed into the Azure Terraform layer and reused by the Kubernetes validation scripts. |
| `REPO_NAME` | Yes for OIDC setup | `kubernetes-platform-case` | GitHub repository name used by `infrastructure/azure/oidc/create_az_oidc.sh` when it renders the GitHub federated credential. |
| `GITHUB_BRANCH` | Yes for OIDC setup | `main` | Git branch allowed to authenticate through the Azure federated credential. |
| `LOCATION` | Yes for backend and Azure provisioning | `canadacentral` | Azure region for the Terraform backend resource group and AKS infrastructure. This becomes `AKS_LOCATION` in GitHub Actions repo variables. |
| `APP_NAME` | Recommended | `sp-github-oidc-stage1-platform` | Display name for the Azure Entra application and service principal created for GitHub OIDC. |
| `ROLE_NAME` | Recommended | `Contributor` | Azure role assigned to the OIDC service principal at subscription scope. |

### AKS and backend variables

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `AKS_CLUSTER_NAME` | Yes for Azure and Kubernetes provisioning | `aks-stage1-platform` | AKS cluster name created by the Azure Terraform layer and later targeted by the Kubernetes resources layer. |
| `DNS_PREFIX` | Optional | `aks-stage1` | DNS prefix passed to the Azure Terraform layer for the AKS cluster. |
| `NODE_COUNT` | Optional | `1` | Initial AKS node count passed to Terraform. |
| `VM_SIZE` | Optional | `Standard_D2as_v6` | AKS node VM size used by local scripts. The GitHub workflow also supports the same value through a repository variable. |
| `TIER` | Optional | `Free` | AKS SKU tier passed to the Azure Terraform layer. |
| `TF_BACKEND_RESOURCE_GROUP` | Yes after the first backend bootstrap | `rg-stage1-tfstate` | Azure resource group that hosts the remote Terraform state storage account. Required by local scripts and GitHub Actions. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Yes after the first backend bootstrap | `<real-storage-account-name>` | Azure Storage Account name used as the remote Terraform backend. This is intentionally blank in the template until the backend is created or known. |
| `TF_BACKEND_CONTAINER` | Yes after the first backend bootstrap | `tfstate` | Blob container name that stores the Terraform state files. |

### PostgreSQL variables

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `POSTGRES_SERVER_NAME` | Yes for Azure provisioning | `psql-stage1-platform` | Azure Database for PostgreSQL Flexible Server name created by the infrastructure Terraform layer. |
| `POSTGRES_DATABASE_NAME` | Yes for Azure provisioning | `payment_exception_review` | Initial application database created on the PostgreSQL Flexible Server. |
| `POSTGRES_ADMIN_USERNAME` | Yes for Azure provisioning | `pgadminmarvin` | PostgreSQL administrator login used by the managed server. |
| `POSTGRES_ADMIN_PASSWORD` | Yes for Azure provisioning | `<strong-password>` | PostgreSQL administrator password. Keep it only in local `.env`; never commit it. |
| `POSTGRES_VERSION` | Optional | `16` | PostgreSQL major version for the managed Flexible Server. |
| `POSTGRES_SKU_NAME` | Yes for Azure provisioning | `Standard_B1ms` | Azure Database for PostgreSQL Flexible Server SKU used by the infrastructure layer. |
| `POSTGRES_STORAGE_MB` | Optional | `32768` | Storage allocation in MB for the managed PostgreSQL server. |
| `POSTGRES_BACKUP_RETENTION_DAYS` | Optional | `7` | Backup retention period used for the managed PostgreSQL server. |
| `POSTGRES_ZONE` | Optional | `1` | Availability zone used by the managed PostgreSQL server when the selected region and SKU support it. |

### Private networking variables

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `VNET_NAME` | Optional | `vnet-stage1-platform` | Name of the platform virtual network used by AKS and PostgreSQL private connectivity. |
| `VNET_ADDRESS_SPACE` | Optional | `10.20.0.0/16` | Address space for the platform virtual network. |
| `AKS_SUBNET_NAME` | Optional | `snet-stage1-aks` | Name of the AKS subnet inside the platform VNet. |
| `AKS_SUBNET_PREFIX` | Optional | `10.20.1.0/24` | Address prefix for the AKS subnet. |
| `POSTGRES_SUBNET_NAME` | Optional | `snet-stage1-postgres` | Name of the delegated PostgreSQL subnet inside the platform VNet. |
| `POSTGRES_SUBNET_PREFIX` | Optional | `10.20.2.0/28` | Address prefix for the delegated PostgreSQL subnet. |
| `POSTGRES_PRIVATE_DNS_ZONE_NAME` | Optional | `stage1-platform.postgres.database.azure.com` | Private DNS zone used by Azure Database for PostgreSQL Flexible Server. |
| `POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME` | Optional | `stage1-platform-postgres-dns-link` | Name of the VNet link for the PostgreSQL private DNS zone. |

### Observability variables

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `GRAFANA_ADMIN_USER` | Optional | `admin` | Grafana administrator username used by the shared observability installation path. Defaults to `admin` if unset. |
| `GRAFANA_ADMIN_PASSWORD` | Yes for local observability validation | `<strong-password>` | Grafana administrator password used by the shared observability installation path. Keep it only in local `.env`; never commit it. |

## GitHub repository variables

| Repository variable | Required | Description |
| --- | --- | --- |
| `TF_BACKEND_RESOURCE_GROUP` | Yes | Mirrors `.env` so GitHub Actions can initialize the Terraform backend. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Yes | Mirrors `.env` so GitHub Actions can reach the backend storage account. |
| `TF_BACKEND_CONTAINER` | Yes | Mirrors `.env` so GitHub Actions can select the Terraform state container. |
| `RESOURCE_GROUP` | Yes | Resource group expected by the Azure and Kubernetes workflows. Should match `RESOURCE_GROUP` in `.env`. |
| `AKS_LOCATION` | Yes | Azure region for the AKS layer. This should match `LOCATION` from `.env`. |
| `AKS_CLUSTER_NAME` | Yes | AKS cluster name expected by the Azure and Kubernetes workflows. Should match `AKS_CLUSTER_NAME` in `.env`. |
| `VM_SIZE` | Optional | Optional CI override for the AKS node size. If unset, workflows default to `Standard_D2as_v6`. |
| `POSTGRES_SERVER_NAME` | Yes | PostgreSQL Flexible Server name expected by the Azure workflows. Should match `POSTGRES_SERVER_NAME` in `.env`. |
| `POSTGRES_DATABASE_NAME` | Yes | Initial database name expected by the Azure workflows. Should match `POSTGRES_DATABASE_NAME` in `.env`. |
| `POSTGRES_ADMIN_USERNAME` | Yes | PostgreSQL administrator username expected by the Azure workflows. Should match `POSTGRES_ADMIN_USERNAME` in `.env`. |
| `POSTGRES_VERSION` | Optional | PostgreSQL major version used by the Azure workflows. Defaults to `16` if unset. |
| `POSTGRES_SKU_NAME` | Yes | PostgreSQL Flexible Server SKU expected by the Azure workflows. Should match `POSTGRES_SKU_NAME` in `.env`. |
| `POSTGRES_STORAGE_MB` | Optional | PostgreSQL storage size in MB used by the Azure workflows. Defaults to `32768` if unset. |
| `POSTGRES_BACKUP_RETENTION_DAYS` | Optional | PostgreSQL backup retention used by the Azure workflows. Defaults to `7` if unset. |
| `POSTGRES_ZONE` | Optional | PostgreSQL availability zone used by the Azure workflows. Defaults to `1` if unset. |
| `VNET_NAME` | Optional | Platform virtual network name used by the Azure workflows. Defaults to `vnet-stage1-platform` if unset. |
| `VNET_ADDRESS_SPACE` | Optional | Platform virtual network address space used by the Azure workflows. Defaults to `10.20.0.0/16` if unset. |
| `AKS_SUBNET_NAME` | Optional | AKS subnet name used by the Azure workflows. Defaults to `snet-stage1-aks` if unset. |
| `AKS_SUBNET_PREFIX` | Optional | AKS subnet prefix used by the Azure workflows. Defaults to `10.20.1.0/24` if unset. |
| `POSTGRES_SUBNET_NAME` | Optional | PostgreSQL delegated subnet name used by the Azure workflows. Defaults to `snet-stage1-postgres` if unset. |
| `POSTGRES_SUBNET_PREFIX` | Optional | PostgreSQL delegated subnet prefix used by the Azure workflows. Defaults to `10.20.2.0/28` if unset. |
| `POSTGRES_PRIVATE_DNS_ZONE_NAME` | Optional | PostgreSQL private DNS zone used by the Azure workflows. Defaults to `stage1-platform.postgres.database.azure.com` if unset. |
| `POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME` | Optional | PostgreSQL private DNS VNet link name used by the Azure workflows. Defaults to `stage1-platform-postgres-dns-link` if unset. |

## GitHub repository secrets

| Repository secret | Required | Description |
| --- | --- | --- |
| `AZURE_SUBSCRIPTION_ID` | Yes | Azure subscription used by GitHub Actions. Mirrors `SUBSCRIPTION_ID` from `.env`. |
| `AZURE_CLIENT_ID` | Yes | Application ID of the Azure Entra app created for GitHub OIDC. |
| `AZURE_TENANT_ID` | Yes | Azure tenant ID used by `azure/login@v2` during GitHub Actions authentication. |
| `POSTGRES_ADMIN_PASSWORD` | Yes | PostgreSQL administrator password used by the Azure workflows. Mirrors `POSTGRES_ADMIN_PASSWORD` from local `.env`, but must be stored as a GitHub secret in CI. |
| `GRAFANA_ADMIN_PASSWORD` | Yes for observability GitHub Actions | Grafana administrator password for the shared observability stack. Mirrors `GRAFANA_ADMIN_PASSWORD` from local `.env`, and must be stored as a GitHub secret in CI for the observability provision workflow. |

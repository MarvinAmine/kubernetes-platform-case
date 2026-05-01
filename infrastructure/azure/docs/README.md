# Azure Provisioning

This Terraform layer is managed by the infrastructure team.

Its purpose is to provision the Azure resources required before the Kubernetes cluster can be bootstrapped and used by the application team.

## Ownership

This layer owns the Azure infrastructure foundation for the platform.

It does not create the Kubernetes application resources inside the cluster. That responsibility belongs to the Kubernetes resources layer.

## Resources created

The Azure Terraform creates the core Azure infrastructure, including:

- Resource Group
- Platform virtual network
- AKS subnet
- PostgreSQL delegated subnet
- PostgreSQL private DNS zone and VNet link
- AKS Cluster
- Azure Database for PostgreSQL Flexible Server
- Initial PostgreSQL application database
- Networking and supporting Azure resources required by the AKS deployment

These resources provide the base environment on which the Kubernetes bootstrap layer can run.

## Local Terraform usage

From the repository root:

```bash
cp .env.example .env
```

Fill the repository-root `.env` before using the local scripts.

```bash
cd infrastructure/azure/terraform
source ../../../commons/scripts/load_terraform_env.sh
load_repo_env ../../../.env ../../../.env.example
export_azure_infra_tf_vars
terraform init \
  -backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=azure/terraform.tfstate" \
  -backend-config="use_azuread_auth=true"
terraform validate
terraform plan
terraform apply
```

The shared repository-root `.env` must include both the AKS inputs and the PostgreSQL inputs used by this layer, including:

- `RESOURCE_GROUP`
- `LOCATION`
- `AKS_CLUSTER_NAME`
- `VNET_NAME`
- `VNET_ADDRESS_SPACE`
- `AKS_SUBNET_NAME`
- `AKS_SUBNET_PREFIX`
- `POSTGRES_SERVER_NAME`
- `POSTGRES_DATABASE_NAME`
- `POSTGRES_ADMIN_USERNAME`
- `POSTGRES_ADMIN_PASSWORD`
- `POSTGRES_SKU_NAME`
- `POSTGRES_SUBNET_NAME`
- `POSTGRES_SUBNET_PREFIX`
- `POSTGRES_PRIVATE_DNS_ZONE_NAME`
- `POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME`

The shared helper `commons/scripts/load_terraform_env.sh` converts these generic `.env` values into the `TF_VAR_*` names expected by Terraform.

Backend note:

- `TF_VAR_*` covers normal Terraform input variables for the Azure resources.
- The remote backend is configured separately through `backend.tf` plus `terraform init -backend-config=...`.
- This is intentional because backend settings are initialized before normal Terraform input variables are evaluated.

To destroy the Azure infrastructure manually:

```bash
terraform destroy
```

## GitHub Actions behavior

The workflow `.github/workflows/azure-provision.yml` supports two execution modes:

- `push`
  Runs Terraform format check, init, validate, and plan.

- `workflow_dispatch`
  Runs the same validation steps and also allows `terraform apply`.

The workflow `.github/workflows/azure-destroy.yml` is manual only:

- `workflow_dispatch`
  Runs `terraform destroy -auto-approve`

This keeps Azure provisioning validated on push while reserving real infrastructure changes and destruction for explicit manual execution.

## Private database access model

For this project, the cloud database is intended to be private:

- AKS workloads reach PostgreSQL through the platform VNet
- PostgreSQL Flexible Server lives on a delegated subnet
- the database name is resolved through private DNS
- direct public laptop access to the cloud database is not the intended pattern

Cloud database validation should happen through:

- the deployed application
- an internal debug pod
- or another trusted in-cluster path

This is intentionally harder than a public-access test path because the project aims to simulate a governed environment rather than a convenience-first lab.

## Related Documentation

- [OIDC For GitHub Actions](./OIDC.md)
- [Azure networking design](./networking-design.md)

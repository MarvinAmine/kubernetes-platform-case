# Azure Provisioning

This Terraform layer is managed by the infrastructure team.

Its purpose is to provision the Azure resources required before the Kubernetes cluster can be bootstrapped and used by the application team.

## Ownership

This layer owns the Azure infrastructure foundation for the platform.

It does not create the Kubernetes application resources inside the cluster. That responsibility belongs to the Kubernetes resources layer.

## Resources created

The Azure Terraform creates the core Azure infrastructure, including:

- Resource Group
- AKS Cluster
- Networking and supporting Azure resources required by the AKS deployment

These resources provide the base environment on which the Kubernetes bootstrap layer can run.

## Local Terraform usage

From the repository root:

```bash
cp infrastructure/.env.example infrastructure/.env
```

Fill `infrastructure/.env` before using the local scripts.

```bash
cd infrastructure/azure/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

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

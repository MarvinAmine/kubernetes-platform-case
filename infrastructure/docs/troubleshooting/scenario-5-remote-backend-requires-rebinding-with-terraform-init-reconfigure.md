# Scenario 5 - Remote backend requires rebinding with `terraform init -reconfigure`

## Symptom

`terraform init` fails even though the remote backend exists and Azure login is valid.

Typical guidance from Terraform includes:

- `terraform init -reconfigure`
- or `terraform init -migrate-state`

## Impact

- local Terraform usage is blocked
- CI can fail on fresh runners
- wrapper scripts may loop on `terraform init` without making progress

## Root cause

The working directory must be rebound to the remote backend, for example after:

- backend recreation
- `.terraform/` deletion
- local backend metadata drift
- a fresh CI runner

This is a backend-initialization state issue, not an AKS, PostgreSQL, subnet, or private-DNS resource-definition issue.

## Fix

For remote-backend consumer stacks, use:

```bash
terraform init -reconfigure \
  -backend-config="resource_group_name=<tf-backend-rg>" \
  -backend-config="storage_account_name=<tf-backend-storage-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=<stack-specific-state-key>" \
  -backend-config="use_azuread_auth=true"
```

Use `-migrate-state` only when you intentionally need to move Terraform state between backend locations.

## Validation

- `terraform init -reconfigure` succeeds
- `terraform validate` runs normally afterward
- `terraform plan` uses the intended remote state

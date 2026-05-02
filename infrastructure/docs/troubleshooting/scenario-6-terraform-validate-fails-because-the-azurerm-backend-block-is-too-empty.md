# Scenario 6 - `terraform validate` fails because the `azurerm` backend block is too empty

## Symptom

`terraform init -reconfigure` succeeds, but `terraform validate` still fails with backend argument errors such as:

- missing `storage_account_name`
- missing `container_name`
- missing `key`

## Impact

- CI fails even after a successful backend initialization
- local validation looks inconsistent with successful `init`

## Root cause

Terraform backend configuration is evaluated before normal input variables.

That means:

- `TF_VAR_*` does not configure the backend
- an empty `backend "azurerm" {}` block can still fail validation

## Fix

Keep a structurally complete `backend "azurerm"` block in `backend.tf` for remote-backend consumer stacks.

Then keep supplying the real environment-specific backend values through:

- `terraform init -backend-config=...`
- local wrapper scripts
- GitHub Actions init steps

## Validation

- `terraform init -reconfigure` succeeds
- `terraform validate` no longer complains about backend arguments
- CI and local execution behave consistently

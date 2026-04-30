# ADR-013 - Use the Repository-Root `.env` File as the Single Local Configuration Source

## Status

Accepted

## Context

The repository uses several local execution paths:

- Terraform backend bootstrap scripts
- Azure infrastructure scripts
- Kubernetes platform scripts
- Azure CLI and OIDC helper scripts

These paths share many of the same values, including:

- Azure subscription identifiers
- backend storage identifiers
- AKS settings
- managed PostgreSQL settings
- private networking settings

Terraform expects input variables through `TF_VAR_*` environment variable names, but the rest of the repository uses generic operational names such as `SUBSCRIPTION_ID`, `RESOURCE_GROUP`, and `POSTGRES_SERVER_NAME`.

Without a shared convention, the repository drifts toward:

- duplicated environment variables
- Terraform-specific aliases in the root `.env`
- inconsistent local execution between scripts and manual Terraform usage

## Decision

The repository-root `.env` file is the single local configuration source.

The `.env` file keeps only generic operational variable names such as:

- `SUBSCRIPTION_ID`
- `RESOURCE_GROUP`
- `AKS_CLUSTER_NAME`
- `POSTGRES_SERVER_NAME`

Terraform-specific `TF_VAR_*` names are not stored as first-class values in `.env`.

Instead, local wrapper scripts and manual Terraform workflows derive the required Terraform environment variables through the shared helper:

- `commons/scripts/load_terraform_env.sh`

This helper is responsible for:

- loading the repository-root `.env`
- validating required variables for a given execution path
- exporting the `TF_VAR_*` names needed by the Terraform layer being invoked

## Consequences

### Positive

- `.env` remains the single local source of truth
- Terraform naming concerns stay at the execution boundary instead of polluting the base config
- Azure CLI, OIDC scripts, and Terraform wrappers can share the same underlying values
- local script behavior becomes more consistent across infrastructure and platform layers

### Negative

- manual Terraform usage requires an explicit helper-loading step unless a wrapper script is used
- the helper script becomes a small but important shared dependency

## Alternatives considered

### Store both generic names and `TF_VAR_*` aliases directly in `.env`

Rejected because it duplicates the same concepts and makes the repository-root `.env` unnecessarily Terraform-specific.

### Replace `.env` with Terraform `.auto.tfvars` files

Rejected because the repository uses the same configuration values for more than Terraform alone, including shell orchestration and Azure CLI workflows.

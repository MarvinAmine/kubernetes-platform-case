# Azure OIDC For GitHub Actions

This guide explains how to create Azure OpenID Connect credentials for GitHub Actions using the scripts in `infrastructure/azure/oidc`.

The OIDC setup creates or reconciles:

- an Azure Entra application
- its service principal
- a subscription-level Azure role assignment
- a GitHub federated credential bound to your repository and branch

At the end of the process, the script prints the GitHub repository secrets that must be configured.

## Prerequisites

From the repository root:

```bash
cp infrastructure/.env.example infrastructure/.env
```

Fill `infrastructure/.env` with at least these values:

```conf
REPO_OWNER="<your-github-org-or-user>"
REPO_NAME="<your-repository-name>"
GITHUB_BRANCH="main"
SUBSCRIPTION_ID="<your-azure-subscription-id>"
APP_NAME="sp-github-oidc-stage1-platform"
ROLE_NAME="Contributor"
```

You must also have Azure CLI installed and be logged in:

```bash
az version
az login
az account show --output table
```

If you have multiple subscriptions:

```bash
az account list --output table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

## Create Or Reconcile The OIDC Credentials

Run the helper from the repository root:

```bash
./infrastructure/azure/oidc/create_az_oidc.sh
```

The script will:

1. verify Azure login
2. load `infrastructure/.env`
3. check whether the Entra application already exists
4. create the Entra application if needed
5. create the service principal if needed
6. assign the configured Azure role on the subscription
7. render the GitHub federated credential payload
8. replace the federated credential if it already exists
9. print the GitHub repository secrets to configure

This flow is idempotent:

- first run creates the missing Azure identity resources
- later runs reuse the existing app and service principal, then reconcile the federated credential

## GitHub Repository Secrets

When the script completes, copy the printed values into your GitHub repository secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

The GitHub Actions workflows in this repository expect those exact secret names.

## How The Federated Credential Is Built

The federated credential is rendered from:

[github-oidc-credential.template.json](/home/marvin/Documents/dev/kubernetes/infrastructure/azure/oidc/github-oidc-credential.template.json)

The script replaces these placeholders using `infrastructure/.env`:

- `<REPO_OWNER>`
- `<REPO_NAME>`
- `<GITHUB_BRANCH>`

That means the resulting federated credential is scoped to the configured repository and branch.

## Example First-Time Flow

```bash
cp infrastructure/.env.example infrastructure/.env
# edit infrastructure/.env
az login
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
./infrastructure/azure/oidc/create_az_oidc.sh
```

Then set the printed values in GitHub repository secrets.

## Cleanup

To remove the GitHub OIDC integration:

```bash
./infrastructure/azure/oidc/destroy_az_oidc.sh
```

Use cleanup carefully. This removes the OIDC integration used by the repository workflows.

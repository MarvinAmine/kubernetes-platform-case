#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f ".env" ]]; then
    echo "Missing .env file. Copy .env.example to .env and fill the environment variables."
    exit 1
fi

# Source the variables from the env file
set -a
source .env
set +a

if [[ -z "$REPO_OWNER"  || -z  "$SUBSCRIPTION_ID" ]]; then
    echo "REPO_OWNER and SUBSCRIPTION_ID shouldn't be empty or unset"
    exit 1
fi

echo "Preemptive login verification"
az account show --output table >/dev/null

echo "Creating the Entra application: $APP_NAME"
APP_ID=$(az ad app create \
  --display-name "$APP_NAME" \
  --query appId -o tsv)

echo "Creating the service principal for app: $APP_ID"
az ad sp create --id "$APP_ID"

echo "Waiting for service principal propagation..."
sleep 15

# Get the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "TENANT_ID: $TENANT_ID"

# Assign Azure role with the right scope
SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"

echo "Assigning role '$ROLE_NAME' on scope '$SCOPE'"
az role assignment create --assignee "$APP_ID" --role "$ROLE_NAME" --scope "$SCOPE"


echo "Replacing the REPO_OWNER, REPO_NAME and GITHUB_BRANCH in the 'github-oidc-credential.json'"
RENDERED_FILE="github-oidc-credential.json"
cp github-oidc-credential.template.json "$RENDERED_FILE"


sed -i "s|<REPO_OWNER>|$REPO_OWNER|g" "$RENDERED_FILE"
sed -i "s|<REPO_NAME>|$REPO_NAME|g" "$RENDERED_FILE"
sed -i "s|<GITHUB_BRANCH>|$GITHUB_BRANCH|g" "$RENDERED_FILE"

az ad app federated-credential create --id "$APP_ID" --parameters @"$RENDERED_FILE"


echo "Done. Add these GitHub secrets in your github repository:"
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
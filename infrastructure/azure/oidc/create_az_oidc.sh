#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
TEMPLATE_FILE="$SCRIPT_DIR/github-oidc-credential.template.json"
OUTPUT_FILE="$SCRIPT_DIR/github-oidc-credential.json"


cd "$SCRIPT_DIR"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE file. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the environment variables."
    exit 1
fi

# Source the variables from the env file
set -a
source "$ENV_FILE"
set +a

if [[ -z "$REPO_OWNER"  || -z  "$SUBSCRIPTION_ID" ]]; then
    echo "REPO_OWNER and SUBSCRIPTION_ID shouldn't be empty or unset"
    exit 1
fi

echo "Preemptive login verification"
az account show --output table

echo "Checking whether the Entra application already exists: $APP_NAME"
APP_ID="$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)"

if [[ -z "$APP_ID" ]]; then
    echo "No existing app found. Creating Entra application: $APP_NAME"
    APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
else
    echo "Existing Entra application found: $APP_ID"
fi

echo "Checking whether the service principal already exists for app: $APP_ID"
SP_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv || true)"

if [[ -z "$SP_ID" ]]; then
    echo "No service principal found. Creating it..."
    az ad sp create --id "$APP_ID"
    echo "Waiting for service principal propagation..."
    sleep 15
    SP_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv)"
else
    echo "Existing service principal found: $SP_ID"
fi

# Get the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "TENANT_ID: $TENANT_ID"

# Assign Azure role with the right scope
SCOPE="/subscriptions/$SUBSCRIPTION_ID"

echo "Checking role assignment '$ROLE_NAME' on scope '$SCOPE'"
EXISTING_ASSIGNMENT="$(az role assignment list \
  --assignee-object-id "$SP_ID" \
  --scope "$SCOPE" \
  --query "[?roleDefinitionName=='$ROLE_NAME'] | [0].id" \
  -o tsv || true)"

if [[ -z "$EXISTING_ASSIGNMENT" ]]; then
    echo "Creating role assignment..."
    az role assignment create \
      --assignee-object-id "$SP_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "$ROLE_NAME" \
      --scope "$SCOPE"
else
    echo "Role assignment already exists."
fi

echo "Replacing the REPO_OWNER, REPO_NAME and GITHUB_BRANCH in the 'github-oidc-credential.json'"

cp "$TEMPLATE_FILE" "$OUTPUT_FILE"


sed -i "s|<REPO_OWNER>|$REPO_OWNER|g" "$OUTPUT_FILE"
sed -i "s|<REPO_NAME>|$REPO_NAME|g" "$OUTPUT_FILE"
sed -i "s|<GITHUB_BRANCH>|$GITHUB_BRANCH|g" "$OUTPUT_FILE"

echo "Checking if federated credential already exists..."
APP_OBJECT_ID="$(az ad app show --id "$APP_ID" --query id -o tsv)"
FED_NAME="github-main-branch"

FED_EXISTS="$(az rest \
  --method GET \
  --url "https://graph.microsoft.com/beta/applications/$APP_OBJECT_ID/federatedIdentityCredentials" \
  --query "value[?name=='$FED_NAME'] | [0].name" \
  -o tsv || true)"

if [[ -n "$FED_EXISTS" ]]; then
    echo "Federated credential '$FED_NAME' already exists. Replacing it to ensure subject is correct..."
    az ad app federated-credential delete \
      --id "$APP_ID" \
      --federated-credential-id "$FED_NAME"
fi

az ad app federated-credential create --id "$APP_ID" --parameters @"$OUTPUT_FILE"


echo "Done. Add these GitHub secrets in your github repository:"
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

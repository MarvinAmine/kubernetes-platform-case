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

echo "Preemptive Azure login verification"
az account show --output table

echo "Get the application id associated with the Entra application: $APP_NAME"
APP_ID="$(az ad app list \
  --display-name "$APP_NAME" \
  --query "[0].appId" -o tsv)"

if [[ -z "$APP_ID" ]]; then
    echo "No existing app found. There is no Azure Entra application: $APP_NAME to destroy"
    exit 0
fi

echo "Listing federated credentials for '$APP_NAME'..."
FED_CREDENTIAL_IDS="$(az ad app federeted-credential list --id "$APP_ID" --query '[].name' -o tsv || true)"

if [[ -n "$FED_CREDENTIAL_IDS" ]]; then
    while IFS= read -r credential_name; do
        [[ -z "$credential_name" ]] && continue
        az ad app federeted-credential delete \
            --id "$APP_ID" \
            --federeted-credential-id "$credential_name"
    done <<< "$FED_CREDENTIAL_IDS"
fi

echo "Removing role assignments on subsciption..."
ROLE_ASSIGNMENT_IDS="$(az role assignment list --assignee "$APP_ID" --scope "/subsriptions/$SUBSCRIPTION_ID" --query '[].id' -o tsv || true)"

if [[ -n "$ROLE_ASSIGNMENT_IDS" ]]; then
    while IFS= read -r assignment_id; do
        [[ -z "$assignment_id" ]] && continue
        az role assignment delete --ids "$assignment_id"
    done <<< "$ROLE_ASSIGNMENT_IDS"
fi

echo "GitHub OIDC integration has been removed."

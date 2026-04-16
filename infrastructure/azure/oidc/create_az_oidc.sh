#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
TEMPLATE_FILE="$SCRIPT_DIR/github-oidc-credential.template.json"
OUTPUT_FILE="$SCRIPT_DIR/github-oidc-credential.json"
source "$SCRIPT_DIR/../../scripts/common_logging.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}


cd "$SCRIPT_DIR"
parse_args "$@"
setup_logging "$INFRASTRUCTURE_ROOT/create_az_oidc.log"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE file. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the environment variables."
    exit 1
fi

# Source the variables from the env file
set -a
source "$ENV_FILE"
set +a

if [[ -z "$REPO_OWNER"  || -z  "$SUBSCRIPTION_ID" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" ]]; then
    echo "REPO_OWNER, SUBSCRIPTION_ID, TF_BACKEND_RESOURCE_GROUP and TF_BACKEND_STORAGE_ACCOUNT shouldn't be empty or unset"
    exit 1
fi

log_info "Preemptive login verification"
run_command_with_context "Azure login verified" az account show --output table

log_info "Checking whether the Entra application already exists: $APP_NAME"
APP_ID="$(run_command_capture az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)"

if [[ -z "$APP_ID" ]]; then
    log_info "No existing app found. Creating Entra application: $APP_NAME"
    APP_ID="$(run_command_capture az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
    log_success "Azure Entra application created"
else
    log_success "Existing Azure Entra application found: $APP_ID"
fi

log_info "Checking whether the service principal already exists for app: $APP_ID"
SP_ID="$(run_command_capture az ad sp show --id "$APP_ID" --query id -o tsv || true)"

if [[ -z "$SP_ID" ]]; then
    log_info "No service principal found. Creating it..."
    run_command_with_context "Service principal created" az ad sp create --id "$APP_ID"
    log_info "Waiting for service principal propagation..."
    sleep 15
    SP_ID="$(run_command_capture az ad sp show --id "$APP_ID" --query id -o tsv)"
    log_success "Service principal resolved after propagation"
else
    log_success "Existing service principal found: $SP_ID"
fi

# Get the tenant ID
TENANT_ID="$(run_command_capture az account show --query tenantId -o tsv)"
log_success "Tenant ID resolved: $TENANT_ID"

# Assign Azure role with the right scope
SCOPE="/subscriptions/$SUBSCRIPTION_ID"

log_info "Checking role assignment '$ROLE_NAME' on scope '$SCOPE'"
EXISTING_ASSIGNMENT="$(run_command_capture az role assignment list \
  --assignee-object-id "$SP_ID" \
  --scope "$SCOPE" \
  --query "[?roleDefinitionName=='$ROLE_NAME'] | [0].id" \
  -o tsv || true)"

if [[ -z "$EXISTING_ASSIGNMENT" ]]; then
    log_info "Creating role assignment..."
    run_command_with_context "Subscription role assignment created" az role assignment create \
      --assignee-object-id "$SP_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "$ROLE_NAME" \
      --scope "$SCOPE"
else
    log_success "Subscription role assignment already exists."
fi

BACKEND_SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TF_BACKEND_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$TF_BACKEND_STORAGE_ACCOUNT"
BACKEND_ROLE_NAME="Storage Blob Data Owner"

log_info "Checking role assignment '$BACKEND_ROLE_NAME' on scope '$BACKEND_SCOPE'"
EXISTING_BACKEND_ASSIGNMENT="$(run_command_capture az role assignment list \
  --assignee-object-id "$SP_ID" \
  --scope "$BACKEND_SCOPE" \
  --query "[?roleDefinitionName=='$BACKEND_ROLE_NAME'] | [0].id" \
  -o tsv || true)"

if [[ -z "$EXISTING_BACKEND_ASSIGNMENT" ]]; then
    log_info "Creating backend storage role assignment..."
    run_command_with_context "Backend storage role assignment created" az role assignment create \
      --assignee-object-id "$SP_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "$BACKEND_ROLE_NAME" \
      --scope "$BACKEND_SCOPE"
else
    log_success "Backend storage role assignment already exists."
fi

log_info "Rendering the GitHub OIDC credential JSON"

cp "$TEMPLATE_FILE" "$OUTPUT_FILE"


sed -i "s|<REPO_OWNER>|$REPO_OWNER|g" "$OUTPUT_FILE"
sed -i "s|<REPO_NAME>|$REPO_NAME|g" "$OUTPUT_FILE"
sed -i "s|<GITHUB_BRANCH>|$GITHUB_BRANCH|g" "$OUTPUT_FILE"
log_success "GitHub OIDC credential JSON rendered"

log_info "Checking if the federated credential already exists..."
APP_OBJECT_ID="$(run_command_capture az ad app show --id "$APP_ID" --query id -o tsv)"
FED_NAME="github-main-branch"

FED_EXISTS="$(run_command_capture az rest \
  --method GET \
  --url "https://graph.microsoft.com/beta/applications/$APP_OBJECT_ID/federatedIdentityCredentials" \
  --query "value[?name=='$FED_NAME'] | [0].name" \
  -o tsv || true)"

if [[ -n "$FED_EXISTS" ]]; then
    log_info "Federated credential '$FED_NAME' already exists. Replacing it to ensure subject is correct..."
    run_command_with_context "Existing federated credential removed" \
        az ad app federated-credential delete \
      --id "$APP_ID" \
      --federated-credential-id "$FED_NAME"
fi

run_command_with_context "Federated credential created" \
    az ad app federated-credential create --id "$APP_ID" --parameters @"$OUTPUT_FILE"


log_success "OIDC setup completed. Add these GitHub secrets in your github repository:"
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

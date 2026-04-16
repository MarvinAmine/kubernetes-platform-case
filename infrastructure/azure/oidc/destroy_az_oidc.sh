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
setup_logging "$INFRASTRUCTURE_ROOT/destroy_az_oidc.log"

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

log_info "Preemptive Azure login verification"
run_command_with_context "Azure login verified" az account show --output table

log_info "Getting the application id associated with the Entra application: $APP_NAME"
APP_ID="$(run_command_capture az ad app list \
  --display-name "$APP_NAME" \
  --query "[0].appId" -o tsv)"

if [[ -z "$APP_ID" ]]; then
    log_info "No existing app found. There is no Azure Entra application: $APP_NAME to destroy."
    exit 0
fi

SP_ID="$(run_command_capture az ad sp show --id "$APP_ID" --query id -o tsv || true)"

log_info "Listing federated credentials for '$APP_NAME'..."
FED_CREDENTIAL_IDS="$(run_command_capture az ad app federated-credential list --id "$APP_ID" --query '[].name' -o tsv || true)"

if [[ -n "$FED_CREDENTIAL_IDS" ]]; then
    while IFS= read -r credential_name; do
        [[ -z "$credential_name" ]] && continue
        run_command_with_context "Federated credential '$credential_name' deleted" \
            az ad app federated-credential delete \
            --id "$APP_ID" \
            --federated-credential-id "$credential_name"
    done <<< "$FED_CREDENTIAL_IDS"
fi

if [[ -n "$SP_ID" ]]; then
    log_info "Removing role assignments on subscription..."
    ROLE_ASSIGNMENT_IDS="$(run_command_capture az role assignment list \
      --assignee-object-id "$SP_ID" \
      --scope "/subscriptions/$SUBSCRIPTION_ID" \
      --query '[].id' -o tsv || true)"

    if [[ -n "$ROLE_ASSIGNMENT_IDS" ]]; then
        while IFS= read -r assignment_id; do
            [[ -z "$assignment_id" ]] && continue
            run_command_with_context "Role assignment '$assignment_id' deleted" \
                az role assignment delete --ids "$assignment_id"
        done <<< "$ROLE_ASSIGNMENT_IDS"
    fi

    BACKEND_SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TF_BACKEND_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$TF_BACKEND_STORAGE_ACCOUNT"

    if az storage account show \
      --name "$TF_BACKEND_STORAGE_ACCOUNT" \
      --resource-group "$TF_BACKEND_RESOURCE_GROUP" \
      --output none >/dev/null 2>&1; then
        log_info "Removing role assignments on backend storage account..."
        BACKEND_ROLE_ASSIGNMENT_IDS="$(run_command_capture az role assignment list \
          --assignee-object-id "$SP_ID" \
          --scope "$BACKEND_SCOPE" \
          --query '[].id' -o tsv || true)"

        if [[ -n "$BACKEND_ROLE_ASSIGNMENT_IDS" ]]; then
            while IFS= read -r assignment_id; do
                [[ -z "$assignment_id" ]] && continue
                run_command_with_context "Backend role assignment '$assignment_id' deleted" \
                    az role assignment delete --ids "$assignment_id"
            done <<< "$BACKEND_ROLE_ASSIGNMENT_IDS"
        fi
    else
        log_info "Backend storage account scope no longer exists. Skipping backend role assignment cleanup."
    fi
fi

log_success "GitHub OIDC integration has been removed."

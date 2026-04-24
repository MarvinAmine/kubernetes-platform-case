#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
source "$SCRIPT_DIR/../../commons/scripts/common_logging.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

parse_args "$@"
setup_logging "$INFRASTRUCTURE_ROOT/../logs/destroy_remote_backend.log"
enable_sensitive_logging

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values first."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${LOCATION:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, LOCATION, TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi


export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_location="$LOCATION"
export TF_VAR_backend_resource_group_name="$TF_BACKEND_RESOURCE_GROUP"
export TF_VAR_backend_storage_account_name="$TF_BACKEND_STORAGE_ACCOUNT"
export TF_VAR_backend_container_name="$TF_BACKEND_CONTAINER"

log_info "Checking Azure login..."
run_command_with_context "Azure login verified" az account show --output table

cd "$SCRIPT_DIR/terraform"

log_info "Initializing Terraform backend layer..."
run_command_with_context "Terraform init completed" terraform init
log_info "Destroying Terraform backend layer..."
run_command_with_context "Terraform destroy completed" terraform destroy -auto-approve

log_success "Remote backend has been destroyed."

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
source "$SCRIPT_DIR/../../commons/scripts/common_logging.sh"
source "$SCRIPT_DIR/../../commons/scripts/load_terraform_env.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

parse_args "$@"
setup_logging "$INFRASTRUCTURE_ROOT/../logs/destroy_azure_resources.log"

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" \
    SUBSCRIPTION_ID RESOURCE_GROUP LOCATION AKS_CLUSTER_NAME \
    TF_BACKEND_RESOURCE_GROUP TF_BACKEND_STORAGE_ACCOUNT TF_BACKEND_CONTAINER \
    POSTGRES_SERVER_NAME POSTGRES_DATABASE_NAME POSTGRES_ADMIN_USERNAME \
    POSTGRES_ADMIN_PASSWORD POSTGRES_SKU_NAME || exit 1

log_info "Loading Terraform variables from .env"
export_azure_infra_tf_vars

log_info "Checking Azure login..."
run_command_with_context "Azure login verified" az account show --output table

log_info "Destroying Azure resources managed by Terraform..."
cd "$SCRIPT_DIR/terraform"
run_command_with_context "Terraform init completed" \
  terraform init \
  -backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=azure/terraform.tfstate" \
  -backend-config="use_azuread_auth=true"

run_command_with_context "Terraform destroy completed" terraform destroy -auto-approve

log_success "Azure infrastructure has been destroyed."

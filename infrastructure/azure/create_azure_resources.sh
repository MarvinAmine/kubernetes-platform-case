#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
source "$SCRIPT_DIR/../../commons/scripts/wait_for_backend_access.sh"
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
setup_logging "$INFRASTRUCTURE_ROOT/../logs/create_azure_resources.log"

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" \
    SUBSCRIPTION_ID RESOURCE_GROUP LOCATION AKS_CLUSTER_NAME \
    TF_BACKEND_RESOURCE_GROUP TF_BACKEND_STORAGE_ACCOUNT TF_BACKEND_CONTAINER \
    POSTGRES_SERVER_NAME POSTGRES_DATABASE_NAME POSTGRES_ADMIN_USERNAME \
    POSTGRES_ADMIN_PASSWORD POSTGRES_SKU_NAME || exit 1
export_azure_infra_tf_vars

log_info "Checking Azure login..."
run_command_with_context "Azure login verified" az account show --output table

cd "$SCRIPT_DIR/terraform"
log_info "Initializing Azure Terraform layer..."
run_command_with_context "Terraform init completed" \
  terraform_init_with_backend_retry \
  "$TF_BACKEND_RESOURCE_GROUP" \
  "$TF_BACKEND_STORAGE_ACCOUNT" \
  "$TF_BACKEND_CONTAINER" \
  "azure/terraform.tfstate"

log_info "Validating Azure Terraform layer..."
run_command_with_context "Terraform validate completed" terraform validate

echo "If the next step fails because the resource group already exists, run:"
echo "terraform import azurerm_resource_group.aks \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP\""

log_info "Planning Azure Terraform layer..."
run_command_with_context "Terraform plan completed" terraform plan

log_info "Applying Azure Terraform layer..."
run_command_with_context "Terraform apply completed" terraform apply -auto-approve

log_success "Azure resources are ready."

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../.env.example"
source "$SCRIPT_DIR/../scripts/wait_for_backend_access.sh"
source "$SCRIPT_DIR/../scripts/common_logging.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

parse_args "$@"
setup_logging "$INFRASTRUCTURE_ROOT/create_azure_resources.log"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values first."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${LOCATION:-}" || -z "${AKS_CLUSTER_NAME:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, LOCATION, AKS_CLUSTER_NAME, TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in .env file"
    exit 1
fi

export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_resource_group_name="$RESOURCE_GROUP"
export TF_VAR_location="$LOCATION"
export TF_VAR_aks_cluster_name="$AKS_CLUSTER_NAME"
export TF_VAR_dns_prefix="${DNS_PREFIX:-aks-stage1}"
export TF_VAR_node_count="${NODE_COUNT:-1}"
export TF_VAR_vm_size="${VM_SIZE:-Standard_D2as_v6}"
export TF_VAR_tier="${TIER:-Free}"

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

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../.env.example"
source "$SCRIPT_DIR/../scripts/common_logging.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

parse_args "$@"
setup_logging "$INFRASTRUCTURE_ROOT/destroy_kubernetes_resources.log"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values first."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${AKS_CLUSTER_NAME:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, AKS_CLUSTER_NAME, TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"

if ! az group show --name "$RESOURCE_GROUP" --output none >/dev/null 2>&1; then
    log_info "Azure resource group $RESOURCE_GROUP does not exist. Skipping Kubernetes resource destruction."
    exit 0
fi

if ! az aks show --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --output none >/dev/null 2>&1; then
    log_info "AKS cluster $AKS_CLUSTER_NAME does not exist. Skipping Kubernetes resource destruction."
    exit 0
fi

log_info "Validating access to the expected AKS cluster..."
run_command_with_context "AKS cluster access validated" \
    "$SCRIPT_DIR/scripts/validate-cluster-access.sh"

cd "$SCRIPT_DIR/terraform"

log_info "Initializing Kubernetes Terraform layer..."
run_command_with_context "Terraform init completed" \
  terraform init \
  -backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=kubernetes-resources/terraform.tfstate" \
  -backend-config="use_azuread_auth=true"

log_info "Destroying Kubernetes Terraform resources..."
run_command_with_context "Terraform destroy completed" terraform destroy -auto-approve

log_success "Kubernetes resources have been destroyed."

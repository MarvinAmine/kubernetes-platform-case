#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
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
setup_logging "$PLATFORM_ROOT/../logs/apply_kubernetes_resources.log"

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" \
    SUBSCRIPTION_ID RESOURCE_GROUP AKS_CLUSTER_NAME \
    TF_BACKEND_RESOURCE_GROUP TF_BACKEND_STORAGE_ACCOUNT \
    TF_BACKEND_CONTAINER || exit 1

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"

log_info "Validating access to the expected AKS cluster..."
run_command_with_context "AKS cluster access validated" \
    "$SCRIPT_DIR/scripts/validate-cluster-access.sh"

cd "$SCRIPT_DIR/terraform"

log_info "Initializing Kubernetes Terraform layer..."
run_command_with_context "Terraform init completed" \
  terraform_init_with_backend_retry \
  "$TF_BACKEND_RESOURCE_GROUP" \
  "$TF_BACKEND_STORAGE_ACCOUNT" \
  "$TF_BACKEND_CONTAINER" \
  "platform/kubernetes-resources/terraform.tfstate"

log_info "Validating Kubernetes Terraform layer..."
run_command_with_context "Terraform validate completed" terraform validate
log_info "Planning Kubernetes Terraform layer..."
run_command_with_context "Terraform plan completed" terraform plan
log_info "Applying Kubernetes Terraform layer..."
run_command_with_context "Terraform apply completed" terraform apply -auto-approve

log_success "Kubernetes resources are applied."

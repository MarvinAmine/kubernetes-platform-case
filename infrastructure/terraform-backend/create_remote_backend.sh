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
setup_logging "$INFRASTRUCTURE_ROOT/../logs/create_remote_backend.log"
enable_sensitive_logging

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" \
    SUBSCRIPTION_ID LOCATION TF_BACKEND_RESOURCE_GROUP \
    TF_BACKEND_STORAGE_ACCOUNT TF_BACKEND_CONTAINER || exit 1
export_backend_bootstrap_tf_vars

log_info "Checking Azure login..."
run_command_with_context "Azure login verified" az account show --output table

cd "$SCRIPT_DIR/terraform"

log_info "Initializing Terraform backend layer..."
run_command_with_context "Terraform init completed" terraform init
log_info "Validating Terraform backend layer..."
run_command_with_context "Terraform validate completed" terraform validate
log_info "Planning Terraform backend layer..."
run_command_with_context "Terraform plan completed" terraform plan
log_info "Applying Terraform backend layer..."
run_command_with_context "Terraform apply completed" terraform apply -auto-approve

log_success "Remote backend is ready."

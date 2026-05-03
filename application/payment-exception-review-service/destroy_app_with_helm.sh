#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
ENV_FILE_TEMPLATE="$REPO_ROOT/.env.example"
source "$REPO_ROOT/commons/scripts/common_logging.sh"
source "$REPO_ROOT/commons/scripts/load_terraform_env.sh"

parse_args() {
    parse_silent_flag "$@"
    if [[ ${#REMAINING_ARGS[@]} -gt 0 ]]; then
        echo "Unknown argument: ${REMAINING_ARGS[0]}"
        exit 1
    fi
}

parse_args "$@"
setup_logging "$REPO_ROOT/logs/destroy_app_with_helm.log"

load_repo_env "$ENV_FILE" "$ENV_FILE_TEMPLATE" || exit 1
require_env_vars "$ENV_FILE" SUBSCRIPTION_ID RESOURCE_GROUP AKS_CLUSTER_NAME || exit 1

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"
export APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-stage1}"
export RELEASE_NAME="${RELEASE_NAME:-payment-exception-review-service}"

if ! az group show --name "$RESOURCE_GROUP" --output none >/dev/null 2>&1; then
    log_info "Azure resource group $RESOURCE_GROUP does not exist. Skipping application Helm uninstall."
    exit 0
fi

if ! az aks show --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --output none >/dev/null 2>&1; then
    log_info "AKS cluster $AKS_CLUSTER_NAME does not exist. Skipping application Helm uninstall."
    exit 0
fi

log_info "Validating access to the expected AKS cluster..."
run_command_with_context "AKS cluster access validated" \
    "$REPO_ROOT/platform/kubernetes-resources/scripts/validate-cluster-access.sh"

if helm status "$RELEASE_NAME" --namespace "$APP_NAMESPACE" >/dev/null 2>&1; then
    log_info "Uninstalling Helm release $RELEASE_NAME from namespace $APP_NAMESPACE..."
    run_command_with_context "Helm release uninstalled" \
        helm uninstall "$RELEASE_NAME" --namespace "$APP_NAMESPACE"
else
    log_info "Helm release $RELEASE_NAME does not exist in namespace $APP_NAMESPACE. Skipping."
fi

log_success "Application Helm teardown completed."

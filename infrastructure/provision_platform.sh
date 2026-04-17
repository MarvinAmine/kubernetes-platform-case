#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/.env.example"
source "$SCRIPT_DIR/scripts/common_logging.sh"

usage() {
    cat <<'EOF'
Usage: ./infrastructure/provision_platform.sh [--silent|-s] [--help|-h]

Options:
  -s, --silent   Show concise terminal logs and write detailed command output to log files at the project root.
  -h, --help     Show this help message.

Default behavior is verbose to make the provisioning flow easier to debug for newcomers.
EOF
}

parse_args() {
    parse_silent_flag "$@"

    if [[ ${#REMAINING_ARGS[@]} -eq 0 ]]; then
        return 0
    fi

    case "${REMAINING_ARGS[0]}" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: ${REMAINING_ARGS[0]}"
            echo
            usage
            exit 1
            ;;
    esac
}

print_header() {
    print_header_block "$1"
}

print_azure_login_help() {
    cat <<'EOF'

Azure CLI login is required before provisioning.

1. Install Azure CLI on Linux:
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   az version

2. Sign in:
   az login

3. If you have multiple subscriptions:
   az account list --output table
   az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"

4. Register required resource providers:
   az provider register --namespace Microsoft.ContainerService
   az provider register --namespace Microsoft.Compute
   az provider register --namespace Microsoft.Network

5. Verify the active subscription:
   az account show --output table

Then update infrastructure/.env and rerun this script.
EOF
}

ensure_env_file_exists() {
    if [[ ! -f "$ENV_FILE" ]]; then
        echo "Missing $ENV_FILE"
        echo "Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values manually."
        exit 1
    fi
}

load_env() {
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
}

ensure_azure_cli_and_login() {
    if ! command -v az >/dev/null 2>&1; then
        echo "Azure CLI is not installed."
        print_azure_login_help
        exit 1
    fi

    if ! az account show --output table >/dev/null 2>&1; then
        echo "Azure CLI is installed, but you are not logged in."
        print_azure_login_help
        exit 1
    fi
}

ensure_subscription_id_present() {
    if [[ -z "${SUBSCRIPTION_ID:-}" ]]; then
        log_error "SUBSCRIPTION_ID is missing from $ENV_FILE"
        echo
        echo "Available subscriptions:"
        az account list --output table
        echo
        echo "Set SUBSCRIPTION_ID manually in $ENV_FILE, then rerun this script."
        exit 1
    fi
}

register_required_providers() {
    print_header "Registering Azure Resource Providers"
    log_info "Registering Microsoft.ContainerService provider"
    run_command_with_context "Provider Microsoft.ContainerService registered" \
        az provider register --namespace Microsoft.ContainerService
    log_info "Registering Microsoft.Compute provider"
    run_command_with_context "Provider Microsoft.Compute registered" \
        az provider register --namespace Microsoft.Compute
    log_info "Registering Microsoft.Network provider"
    run_command_with_context "Provider Microsoft.Network registered" \
        az provider register --namespace Microsoft.Network
}

backend_values_missing() {
    [[ -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]
}

backend_exists() {
    az storage account show \
        --name "$TF_BACKEND_STORAGE_ACCOUNT" \
        --resource-group "$TF_BACKEND_RESOURCE_GROUP" \
        --output none >/dev/null 2>&1 || return 1

    az storage container show \
        --name "$TF_BACKEND_CONTAINER" \
        --account-name "$TF_BACKEND_STORAGE_ACCOUNT" \
        --auth-mode login \
        --output none >/dev/null 2>&1 || return 1    
}

read_backend_outputs() {
    local backend_output_dir="$SCRIPT_DIR/terraform-backend/terraform"

    BACKEND_RESOURCE_GROUP="$(terraform -chdir="$backend_output_dir" output -raw backend_resource_group_name)"
    BACKEND_STORAGE_ACCOUNT="$(terraform -chdir="$backend_output_dir" output -raw backend_storage_account_name)"
    BACKEND_CONTAINER="$(terraform -chdir="$backend_output_dir" output -raw backend_container_name)"
}

resolve_oidc_secret_values() {
    RESOLVED_AZURE_CLIENT_ID="<from infrastructure/azure/oidc/create_az_oidc.sh output>"
    RESOLVED_AZURE_TENANT_ID="<from infrastructure/azure/oidc/create_az_oidc.sh output>"

    if [[ -n "${APP_NAME:-}" ]]; then
        local app_id
        app_id="$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv 2>/dev/null || true)"
        if [[ -n "$app_id" ]]; then
            RESOLVED_AZURE_CLIENT_ID="$app_id"
        fi
    fi

    local tenant_id
    tenant_id="$(az account show --query tenantId -o tsv 2>/dev/null || true)"
    if [[ -n "$tenant_id" ]]; then
        RESOLVED_AZURE_TENANT_ID="$tenant_id"
    fi
}

print_first_run_instructions() {
    resolve_oidc_secret_values
    echo
    highlight_line "Backend created successfully."
    echo
    highlight_line "Update $ENV_FILE with:"
    echo "TF_BACKEND_RESOURCE_GROUP=\"$BACKEND_RESOURCE_GROUP\""
    echo "TF_BACKEND_STORAGE_ACCOUNT=\"$BACKEND_STORAGE_ACCOUNT\""
    echo "TF_BACKEND_CONTAINER=\"$BACKEND_CONTAINER\""
    echo
    highlight_line "Confirm these values are also set in GitHub repository variables:"
    echo "TF_BACKEND_RESOURCE_GROUP=$BACKEND_RESOURCE_GROUP"
    echo "TF_BACKEND_STORAGE_ACCOUNT=$BACKEND_STORAGE_ACCOUNT"
    echo "TF_BACKEND_CONTAINER=$BACKEND_CONTAINER"
    echo "RESOURCE_GROUP=${RESOURCE_GROUP:-rg-stage1-aks}"
    echo "AKS_LOCATION=${LOCATION:-canadacentral}"
    echo "AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-stage1-platform}"
    echo
    highlight_line "Confirm these GitHub repository secrets are set:"
    echo "AZURE_SUBSCRIPTION_ID=${SUBSCRIPTION_ID:-<your-subscription-id>}"
    echo "AZURE_CLIENT_ID=${RESOLVED_AZURE_CLIENT_ID}"
    echo "AZURE_TENANT_ID=${RESOLVED_AZURE_TENANT_ID}"
    echo
    highlight_line "Then load the environment:"
    echo "set -a"
    echo "source infrastructure/.env"
    echo "set +a"
}

confirm_continue() {
    local prompt="${1:-Do you want to continue? Type yes or no: }"
    local answer

    read -r -p "$prompt" answer
    [[ "$answer" == "yes" ]]
}

print_manual_configuration_block() {
    print_header "Required Manual Configuration"
    print_first_run_instructions

    echo
    highlight_line "Required:"
    echo "- Update $ENV_FILE manually"
    echo "- Set the GitHub repository variables"
    echo "- Ensure GitHub repository secrets exist"
    echo
    highlight_line "Optional now:"
    echo "- Continue local provisioning if you only want local bootstrap"
    echo "- Stop here and configure GitHub first"
}

run_first_time_backend_bootstrap() {
    print_header "First Run Detected"
    log_info "STEP 1/4 - Creating or reconciling the remote Terraform backend..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Remote Terraform backend bootstrap" \
            "$SCRIPT_DIR/terraform-backend/create_remote_backend.sh" --silent
    else
        run_command_with_context "Remote Terraform backend bootstrap" \
            "$SCRIPT_DIR/terraform-backend/create_remote_backend.sh"
    fi
    read_backend_outputs
}

run_azure_provisioning() {
    print_header "Azure Infrastructure"
    log_info "STEP 2/4 - Creating or reconciling Azure Infrastructure..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Azure infrastructure provisioning" \
            "$SCRIPT_DIR/azure/create_azure_resources.sh" --silent
    else
        run_command_with_context "Azure infrastructure provisioning" \
            "$SCRIPT_DIR/azure/create_azure_resources.sh"
    fi
}

run_kubernetes_provisioning() {
    print_header "Kubernetes Resources"
    log_info "STEP 3/4 - Creating or reconciling Kubernetes resources..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Kubernetes resources provisioning" \
            "$SCRIPT_DIR/kubernetes-resources/apply_kubernetes_resources.sh" --silent
    else
        run_command_with_context "Kubernetes resources provisioning" \
            "$SCRIPT_DIR/kubernetes-resources/apply_kubernetes_resources.sh"
    fi
}

run_oidc_setup() {
    echo
    if confirm_continue "Do you also want to create the Azure OIDC federation configuration? Type yes or no: "; then
        print_header "Azure OIDC For GitHub"
        log_info "STEP 4/4 - Creating or reconciling Azure OIDC for GitHub..."
        if [[ "$SILENT_MODE" == true ]]; then
            run_command_with_context "Azure OIDC reconciliation" \
                "$SCRIPT_DIR/azure/oidc/create_az_oidc.sh" --silent
        else
            run_command_with_context "Azure OIDC reconciliation" \
                "$SCRIPT_DIR/azure/oidc/create_az_oidc.sh"
        fi
    else
        log_info "STEP 4/4 - Skipping the creation or reconciliation of Azure OIDC for GitHub."
    fi
}

main() {
    local first_run_detected=false
    local start_time total_elapsed

    parse_args "$@"
    setup_logging "$SCRIPT_DIR/logs/provision_platform.log"
    start_time="$(date +%s)"

    print_header "Platform Provisioning Wizard"
    if [[ "$SILENT_MODE" == true ]]; then
        log_info "Silent mode enabled. Detailed command output will be written to project-root log files."
        log_info "Main log file: $LOG_FILE"
    else
        log_info "Verbose mode enabled by default to help debug the provisioning flow."
    fi

    ensure_env_file_exists
    load_env
    ensure_azure_cli_and_login
    ensure_subscription_id_present
    register_required_providers

    if backend_values_missing; then
        first_run_detected=true
        run_first_time_backend_bootstrap
    else
        print_header "Existing Backend Configuration Detected"
        log_info "Backend values already exist in $ENV_FILE."

        if backend_exists; then
            log_success "Remote backend exists and is reachable."
        else
            first_run_detected=true
            log_info "Remote backend values are set, but the backend does not exist yet or is not reachable."
            log_info "Falling back to STEP 1/4 to create or reconcile the remote Terraform backend."
            run_first_time_backend_bootstrap
        fi
    fi

    run_azure_provisioning
    run_kubernetes_provisioning
    run_oidc_setup

    if [[ "$first_run_detected" == true ]]; then
        print_manual_configuration_block
    fi

    print_header "Completed"
    total_elapsed=$(( $(date +%s) - start_time ))
    log_success "Platform provisioning completed in $(format_duration "$total_elapsed")."
}

main "$@"

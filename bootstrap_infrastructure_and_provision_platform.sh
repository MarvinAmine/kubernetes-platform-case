#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/.env.example"
source "$SCRIPT_DIR/commons/scripts/common_logging.sh"

usage() {
    cat <<'EOF'
Usage: ./bootstrap_infrastructure_and_provision_platform.sh [--silent|-s] [--video|-v] [--help|-h]

Options:
  -s, --silent   Show concise terminal logs and write detailed command output to log files in logs/.
  -v, --video    Redact end-of-run secret and identifier values for demos or screen recordings.
  -h, --help     Show this help message.

Default behavior is verbose to make the provisioning flow easier to debug for newcomers.
EOF
}

VIDEO_MODE=false

parse_args() {
    local args=()
    local arg

    for arg in "$@"; do
        case "$arg" in
            -v|--video)
                VIDEO_MODE=true
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    parse_silent_flag "${args[@]}"

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

redact_for_video() {
    if [[ "$VIDEO_MODE" == true ]]; then
        echo "[REDACTED FOR VIDEO]"
    else
        echo "$1"
    fi
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

Then update .env at the repository root and rerun this script.
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
    local backend_output_dir="$SCRIPT_DIR/infrastructure/terraform-backend/terraform"

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
    highlight_line "Required GitHub repository variables:"
    echo "TF_BACKEND_RESOURCE_GROUP=$BACKEND_RESOURCE_GROUP"
    echo "TF_BACKEND_STORAGE_ACCOUNT=$BACKEND_STORAGE_ACCOUNT"
    echo "TF_BACKEND_CONTAINER=$BACKEND_CONTAINER"
    echo "RESOURCE_GROUP=${RESOURCE_GROUP:-rg-stage1-aks}"
    echo "AKS_LOCATION=${LOCATION:-canadacentral}"
    echo "AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-stage1-platform}"
    echo "POSTGRES_SERVER_NAME=${POSTGRES_SERVER_NAME:-psql-stage1-platform}"
    echo "POSTGRES_DATABASE_NAME=${POSTGRES_DATABASE_NAME:-payment_exception_review}"
    echo "POSTGRES_ADMIN_USERNAME=${POSTGRES_ADMIN_USERNAME:-pgadminmarvin}"
    echo "POSTGRES_SKU_NAME=${POSTGRES_SKU_NAME:-Standard_B1ms}"
    echo
    highlight_line "Recommended GitHub repository variables for full Azure and networking bootstrap:"
    echo "VNET_NAME=${VNET_NAME:-vnet-stage1-platform}"
    echo "VNET_ADDRESS_SPACE=${VNET_ADDRESS_SPACE:-10.20.0.0/16}"
    echo "AKS_SUBNET_NAME=${AKS_SUBNET_NAME:-snet-stage1-aks}"
    echo "AKS_SUBNET_PREFIX=${AKS_SUBNET_PREFIX:-10.20.1.0/24}"
    echo "POSTGRES_SUBNET_NAME=${POSTGRES_SUBNET_NAME:-snet-stage1-postgres}"
    echo "POSTGRES_SUBNET_PREFIX=${POSTGRES_SUBNET_PREFIX:-10.20.2.0/28}"
    echo "POSTGRES_PRIVATE_DNS_ZONE_NAME=${POSTGRES_PRIVATE_DNS_ZONE_NAME:-stage1-platform.postgres.database.azure.com}"
    echo "POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME=${POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME:-stage1-platform-postgres-dns-link}"
    echo
    highlight_line "Optional tuning variables:"
    echo "VM_SIZE=${VM_SIZE:-Standard_D2as_v6}"
    echo "POSTGRES_VERSION=${POSTGRES_VERSION:-16}"
    echo "POSTGRES_STORAGE_MB=${POSTGRES_STORAGE_MB:-32768}"
    echo "POSTGRES_BACKUP_RETENTION_DAYS=${POSTGRES_BACKUP_RETENTION_DAYS:-7}"
    echo "POSTGRES_ZONE=${POSTGRES_ZONE:-1}"
    echo
    highlight_line "Confirm these GitHub repository secrets are set:"
    echo "AZURE_SUBSCRIPTION_ID=$(redact_for_video "${SUBSCRIPTION_ID:-<your-subscription-id>}")"
    echo "AZURE_CLIENT_ID=$(redact_for_video "$RESOLVED_AZURE_CLIENT_ID")"
    echo "AZURE_TENANT_ID=$(redact_for_video "$RESOLVED_AZURE_TENANT_ID")"
    echo "POSTGRES_ADMIN_PASSWORD=$(redact_for_video "<set this as a GitHub secret>")"
    echo "GRAFANA_ADMIN_PASSWORD=$(redact_for_video "<optional now, required later if you automate the observability stack from GitHub Actions>")"
    echo
    highlight_line "Secret contract note:"
    echo "- POSTGRES_ADMIN_PASSWORD is reused in Stage 1 for:"
    echo "  - Azure PostgreSQL provisioning"
    echo "  - the GitHub repository secret POSTGRES_ADMIN_PASSWORD"
    echo "  - the platform-injected Kubernetes secret payment-review-db / POSTGRES_ADMIN_PASSWORD"
    echo
    highlight_line "Then load the environment:"
    echo "set -a"
    echo "source .env"
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
    echo "- Set the required GitHub repository variables"
    echo "- Set the recommended networking variables if you want full bootstrap from GitHub Actions"
    echo "- Ensure the required GitHub repository secrets exist"
    echo
    highlight_line "Optional now:"
    echo "- Continue local provisioning if you only want local bootstrap"
    echo "- Stop here and configure GitHub first"
}

run_first_time_backend_bootstrap() {
    print_header "Remote Terraform Backend"
    log_info "STEP 1/5 - Creating or reconciling the remote Terraform backend..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Remote Terraform backend bootstrap" \
            "$SCRIPT_DIR/infrastructure/terraform-backend/create_remote_backend.sh" --silent
    else
        run_command_with_context "Remote Terraform backend bootstrap" \
            "$SCRIPT_DIR/infrastructure/terraform-backend/create_remote_backend.sh"
    fi
    read_backend_outputs
}

run_azure_provisioning() {
    print_header "Azure Infrastructure"
    log_info "STEP 2/5 - Creating or reconciling Azure infrastructure (AKS + PostgreSQL)..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Azure infrastructure provisioning (AKS + PostgreSQL)" \
            "$SCRIPT_DIR/infrastructure/azure/create_azure_resources.sh" --silent
    else
        run_command_with_context "Azure infrastructure provisioning (AKS + PostgreSQL)" \
            "$SCRIPT_DIR/infrastructure/azure/create_azure_resources.sh"
    fi
}

run_kubernetes_provisioning() {
    print_header "Kubernetes Resources"
    log_info "STEP 3/5 - Creating or reconciling Kubernetes resources..."
    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "Kubernetes resources provisioning" \
            "$SCRIPT_DIR/platform/kubernetes-resources/apply_dev_kubernetes_resources.sh" --silent
    else
        run_command_with_context "Kubernetes resources provisioning" \
            "$SCRIPT_DIR/platform/kubernetes-resources/apply_dev_kubernetes_resources.sh"
    fi

    log_info "Applying the platform-managed runtime database password secret..."
    run_command_with_context "Runtime database password secret injection" \
        "$SCRIPT_DIR/platform/kubernetes-resources/scripts/cluster/apply_runtime_db_secret.sh"
}

run_observability_install() {
    print_header "Shared Observability Stack"
    log_info "STEP 4/5 - Installing or reconciling the shared observability stack..."
    run_command_with_context "Shared observability stack installation" \
        "$SCRIPT_DIR/platform/kubernetes-resources/observability/install_dev_observability_stack.sh"
}

run_oidc_setup() {
    echo
    if confirm_continue "Do you also want to create the Azure OIDC federation configuration? Type yes or no: "; then
        print_header "Azure OIDC For GitHub"
        log_info "STEP 5/5 - Creating or reconciling Azure OIDC for GitHub..."
        if [[ "$SILENT_MODE" == true ]]; then
            if [[ "$VIDEO_MODE" == true ]]; then
                run_command_with_context "Azure OIDC reconciliation" \
                    "$SCRIPT_DIR/infrastructure/azure/oidc/create_az_oidc.sh" --silent --video
            else
                run_command_with_context "Azure OIDC reconciliation" \
                    "$SCRIPT_DIR/infrastructure/azure/oidc/create_az_oidc.sh" --silent
            fi
        else
            if [[ "$VIDEO_MODE" == true ]]; then
                run_command_with_context "Azure OIDC reconciliation" \
                    "$SCRIPT_DIR/infrastructure/azure/oidc/create_az_oidc.sh" --video
            else
                run_command_with_context "Azure OIDC reconciliation" \
                    "$SCRIPT_DIR/infrastructure/azure/oidc/create_az_oidc.sh"
            fi
        fi
    else
        log_info "STEP 5/5 - Skipping the creation or reconciliation of Azure OIDC for GitHub."
    fi
}

main() {
    local first_run_detected=false
    local start_time total_elapsed

    parse_args "$@"
    setup_logging "$SCRIPT_DIR/logs/bootstrap_infrastructure_and_provision_platform.log"
    start_time="$(date +%s)"

    print_header "Platform Provisioning Wizard"
    if [[ "$SILENT_MODE" == true ]]; then
        log_info "Silent mode enabled. Detailed command output will be written to project-root log files."
        log_info "Main log file: $LOG_FILE"
    else
        log_info "Verbose mode enabled by default to help debug the provisioning flow."
    fi
    if [[ "$VIDEO_MODE" == true ]]; then
        log_info "Video mode enabled. End-of-run secret and identifier values will be redacted."
    fi

    ensure_env_file_exists
    load_env
    ensure_azure_cli_and_login
    ensure_subscription_id_present
    register_required_providers

    if backend_values_missing; then
        first_run_detected=true
        log_info "Remote backend values are not fully set in $ENV_FILE yet."
        run_first_time_backend_bootstrap
    else
        if backend_exists; then
            print_header "Remote Terraform Backend"
            log_info "Backend values already exist in $ENV_FILE."
            log_success "Remote backend exists and is reachable."
        else
            first_run_detected=true
            log_info "Backend values already exist in $ENV_FILE."
            log_info "Remote backend values are set, but the backend does not exist yet or is not reachable."
            log_info "Falling back to STEP 1/5 to create or reconcile the remote Terraform backend."
            run_first_time_backend_bootstrap
        fi
    fi

    run_azure_provisioning
    run_kubernetes_provisioning
    run_observability_install
    run_oidc_setup

    if [[ "$first_run_detected" == true ]]; then
        print_manual_configuration_block
    fi

    print_header "Completed"
    total_elapsed=$(( $(date +%s) - start_time ))
    log_success "Platform provisioning completed in $(format_duration "$total_elapsed")."
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common_logging.sh"

usage() {
    cat <<'EOF'
Usage: ./infrastructure/destroy_platform.sh [--silent|-s] [--help|-h]

Options:
  -s, --silent   Show concise terminal logs and write detailed command output to log files in infrastructure/.
  -h, --help     Show this help message.

Default behavior is verbose to make the teardown flow easier to debug.
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
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

run_child_step() {
    local description="$1"
    local script_path="$2"

    if [[ "$SILENT_MODE" == true ]]; then
        run_command_with_context "$description" "$script_path" --silent
    else
        run_command_with_context "$description" "$script_path"
    fi
}

main() {
    local start_time total_elapsed

    parse_args "$@"
    setup_logging "$SCRIPT_DIR/destroy_platform.log"
    start_time="$(date +%s)"

    print_header "Platform Teardown"
    if [[ "$SILENT_MODE" == true ]]; then
        log_info "Silent mode enabled. Detailed command output will be written to log files in infrastructure/."
        log_info "Main log file: $LOG_FILE"
    else
        log_info "Verbose mode enabled by default to help debug the teardown flow."
    fi

    print_header "Kubernetes Resources"
    log_info "STEP 1/4 - Destroying Kubernetes resources..."
    run_child_step "Kubernetes resources destruction" \
        "$SCRIPT_DIR/kubernetes-resources/destroy_kubernetes_resources.sh"

    print_header "Azure Infrastructure"
    log_info "STEP 2/4 - Destroying Azure infrastructure..."
    run_child_step "Azure infrastructure destruction" \
        "$SCRIPT_DIR/azure/destroy_azure_resources.sh"

    print_header "Terraform Backend"
    log_info "STEP 3/4 - Destroying the remote Terraform backend..."
    run_child_step "Remote Terraform backend destruction" \
        "$SCRIPT_DIR/terraform-backend/destroy_remote_backend.sh"

    echo

    read -r -p "Do you also want to destroy the Azure OIDC federation configuration? Type yes or no: " DESTROY_OIDC

    if [[ "$DESTROY_OIDC" == "yes" ]]; then
        print_header "Azure OIDC"
        log_info "STEP 4/4 - Destroying Azure OIDC for GitHub..."
        run_child_step "Azure OIDC destruction" \
            "$SCRIPT_DIR/azure/oidc/destroy_az_oidc.sh"
    else
        log_info "STEP 4/4 - Skipping Azure OIDC federation destruction."
    fi

    print_header "Completed"
    total_elapsed=$(( $(date +%s) - start_time ))
    log_success "Platform teardown completed in $(format_duration "$total_elapsed")."
}

main "$@"

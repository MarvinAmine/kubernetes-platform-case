#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/commons/scripts/common_logging.sh"

usage() {
    cat <<'EOF'
Usage: ./destroy_local_platform_and_app.sh [--silent|-s] [--help|-h]
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
            exit 1
            ;;
    esac
}

main() {
    parse_args "$@"
    setup_logging "$SCRIPT_DIR/logs/destroy_local_platform_and_app.log"
    run_command_with_context "Local application Helm teardown" \
        "$SCRIPT_DIR/application/payment-exception-review-service/destroy_local_app_with_helm.sh"
    run_command_with_context "Local platform teardown" \
        "$SCRIPT_DIR/platform/kubernetes-resources/destroy_local_platform.sh"

    log_success "Local platform and application teardown completed."
}

main "$@"

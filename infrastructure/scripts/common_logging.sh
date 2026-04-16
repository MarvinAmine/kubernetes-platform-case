#!/usr/bin/env bash

SILENT_MODE=false
LOG_FILE=""
REMAINING_ARGS=()
HEARTBEAT_INTERVAL_SECONDS=30
COLOR_RESET=""
COLOR_BOLD=""
COLOR_INFO=""
COLOR_SUCCESS=""
COLOR_ERROR=""
COLOR_WARNING=""
COLOR_HEADER=""
COLOR_ACCENT=""

parse_silent_flag() {
    REMAINING_ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--silent)
                SILENT_MODE=true
                ;;
            *)
                REMAINING_ARGS+=("$1")
                ;;
        esac
        shift
    done
}

setup_logging() {
    LOG_FILE="$1"

    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
        COLOR_RESET=$'\033[0m'
        COLOR_BOLD=$'\033[1m'
        COLOR_INFO=$'\033[36m'
        COLOR_SUCCESS=$'\033[32m'
        COLOR_ERROR=$'\033[31m'
        COLOR_WARNING=$'\033[33m'
        COLOR_HEADER=$'\033[35m'
        COLOR_ACCENT=$'\033[94m'
    fi

    if [[ "$SILENT_MODE" == true ]]; then
        : >"$LOG_FILE"
    fi
}

log_info() {
    echo "${COLOR_INFO}INFO:${COLOR_RESET} $1"
}

log_success() {
    echo "${COLOR_SUCCESS}SUCCESS:${COLOR_RESET} $1"
}

log_error() {
    echo "${COLOR_ERROR}ERROR:${COLOR_RESET} $1"
}

log_warning() {
    echo "${COLOR_WARNING}WARNING:${COLOR_RESET} $1"
}

print_header_block() {
    local title="$1"
    echo
    echo "${COLOR_HEADER}${COLOR_BOLD}==================================================${COLOR_RESET}"
    echo "${COLOR_HEADER}${COLOR_BOLD}${title}${COLOR_RESET}"
    echo "${COLOR_HEADER}${COLOR_BOLD}==================================================${COLOR_RESET}"
}

highlight_line() {
    echo "${COLOR_ACCENT}${COLOR_BOLD}$1${COLOR_RESET}"
}

format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))

    if (( hours > 0 )); then
        printf '%dh %dm %ds' "$hours" "$minutes" "$seconds"
    elif (( minutes > 0 )); then
        printf '%dm %ds' "$minutes" "$seconds"
    else
        printf '%ds' "$seconds"
    fi
}

start_heartbeat() {
    local description="$1"
    local start_time="$2"

    while true; do
        sleep "$HEARTBEAT_INTERVAL_SECONDS"
        local now elapsed
        now="$(date +%s)"
        elapsed=$((now - start_time))
        log_info "$description still running... elapsed $(format_duration "$elapsed")"
    done
}

run_command_capture() {
    local tmp_output
    local status

    tmp_output="$(mktemp)"
    if [[ "$SILENT_MODE" == true ]]; then
        if "$@" >"$tmp_output" 2>>"$LOG_FILE"; then
            status=0
        else
            status=$?
        fi
    else
        if "$@" >"$tmp_output"; then
            status=0
        else
            status=$?
        fi
    fi

    cat "$tmp_output"
    rm -f "$tmp_output"
    return "$status"
}

run_command_with_context() {
    local description="$1"
    shift

    local start_time heartbeat_pid command_pid status elapsed
    start_time="$(date +%s)"

    if [[ "$SILENT_MODE" == true ]]; then
        "$@" >>"$LOG_FILE" 2>&1 &
        command_pid=$!
        start_heartbeat "$description" "$start_time" &
        heartbeat_pid=$!
        if wait "$command_pid"; then
            status=0
        else
            status=$?
        fi
        kill "$heartbeat_pid" >/dev/null 2>&1 || true
        wait "$heartbeat_pid" 2>/dev/null || true
    else
        if "$@"; then
            status=0
        else
            status=$?
        fi
    fi

    elapsed=$(( $(date +%s) - start_time ))

    if [[ "$status" -eq 0 ]]; then
        log_success "$description completed in $(format_duration "$elapsed")"
        return 0
    fi

    log_error "$description failed after $(format_duration "$elapsed")."
    if [[ "$SILENT_MODE" == true ]]; then
        echo "See detailed logs in: $LOG_FILE"
        echo "Last 40 log lines:"
        tail -n 40 "$LOG_FILE" || true
    fi
    exit "$status"
}

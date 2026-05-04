#!/usr/bin/env bash
set -euo pipefail

APP_NAMESPACE="${APP_NAMESPACE:-payment-exception-review-local}"
APP_RELEASE_NAME="${APP_RELEASE_NAME:-payment-exception-review-service}"

if helm status "$APP_RELEASE_NAME" -n "$APP_NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$APP_RELEASE_NAME" -n "$APP_NAMESPACE"
fi

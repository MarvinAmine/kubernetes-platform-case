#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_IMAGE="${APP_IMAGE:-payment-exception-review-service:local}"
APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-payment-exception-review-service-local}"
DB_SERVICE_NAME="${DB_SERVICE_NAME:-payment-review-postgres}"
DB_NAME="${DB_NAME:-payment_exception_review}"
DB_USERNAME="${DB_USERNAME:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_PORT="${DB_PORT:-5432}"
APP_PORT="${APP_PORT:-8080}"

cd "${SCRIPT_DIR}"

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is required but was not found in PATH."
    exit 1
fi

echo "INFO: Ensuring local PostgreSQL is running through Docker Compose..."
docker compose up -d "${DB_SERVICE_NAME}"

echo "INFO: Rebuilding application image ${APP_IMAGE}..."
docker build -t "${APP_IMAGE}" .

if docker ps -a --format '{{.Names}}' | grep -Fxq "${APP_CONTAINER_NAME}"; then
    echo "INFO: Removing existing application container ${APP_CONTAINER_NAME}..."
    docker rm -f "${APP_CONTAINER_NAME}" >/dev/null
fi

echo "INFO: Starting application container ${APP_CONTAINER_NAME} on port ${APP_PORT}..."
docker run --rm \
    --name "${APP_CONTAINER_NAME}" \
    -p "${APP_PORT}:8080" \
    --add-host=host.docker.internal:host-gateway \
    -e "SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:${DB_PORT}/${DB_NAME}" \
    -e "SPRING_DATASOURCE_USERNAME=${DB_USERNAME}" \
    -e "SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}" \
    "${APP_IMAGE}"

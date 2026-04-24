#!/usr/bin/env bash

wait_for_backend_access() {
    local storage_account="$1"
    local container_name="$2"
    local max_attempts="${3:-12}"
    local delay="${4:-15}"
    local attempt=1

    echo "Waiting for Azure RBAC propagation on the remote backend..."
    while true; do
        if az storage blob list \
            --container-name "$container_name" \
            --account-name "$storage_account" \
            --auth-mode login \
            --num-results 1 \
            --output none >/dev/null 2>&1; then
            echo "Remote backend access is ready."
            return 0
        fi

        if (( attempt >= max_attempts )); then
            echo "ERROR: backend access is still not available after $((max_attempts * delay)) seconds."
            return 1
        fi

        echo "Backend access not ready yet. Waiting ${delay}s before retrying..."
        sleep "$delay"
        attempt=$((attempt + 1))
    done
}

terraform_init_with_backend_retry() {
    local resource_group="$1"
    local storage_account="$2"
    local container_name="$3"
    local state_key="$4"
    local max_attempts="${5:-10}"
    local delay="${6:-15}"
    local attempt=1

    wait_for_backend_access "$storage_account" "$container_name"

    while true; do
        echo "Terraform init attempt ${attempt}/${max_attempts}..."
        if terraform init \
            -backend-config="resource_group_name=$resource_group" \
            -backend-config="storage_account_name=$storage_account" \
            -backend-config="container_name=$container_name" \
            -backend-config="key=$state_key" \
            -backend-config="use_azuread_auth=true"; then
            return 0
        fi

        if (( attempt >= max_attempts )); then
            echo "ERROR: terraform init failed after ${max_attempts} attempts."
            return 1
        fi

        echo "Terraform init failed. Waiting ${delay}s before retrying..."
        sleep "$delay"
        attempt=$((attempt + 1))
    done
}

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../.env.example"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values first."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${LOCATION:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, LOCATION, TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi


export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_location="$LOCATION"
export TF_VAR_backend_resource_group_name="$TF_BACKEND_RESOURCE_GROUP"
export TF_VAR_backend_storage_account_name="$TF_BACKEND_STORAGE_ACCOUNT"
export TF_VAR_backend_container_name="$TF_BACKEND_CONTAINER"

echo "Checking Azure login..."
az account show --output table

cd "$SCRIPT_DIR/terraform"

terraform init
terraform destroy -auto-approve

echo "Remote backend has been destroyed."

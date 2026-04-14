#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../.env.example"
source "$SCRIPT_DIR/../scripts/wait_for_backend_access.sh"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the values first."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${AKS_CLUSTER_NAME:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, AKS_CLUSTER_NAME,TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"

echo "Validating access to the expected AKS cluster..."
"$SCRIPT_DIR/scripts/validate-cluster-access.sh"

cd "$SCRIPT_DIR/terraform"

terraform_init_with_backend_retry \
  "$TF_BACKEND_RESOURCE_GROUP" \
  "$TF_BACKEND_STORAGE_ACCOUNT" \
  "$TF_BACKEND_CONTAINER" \
  "kubernetes-resources/terraform.tfstate"

terraform validate
terraform plan
terraform apply -auto-approve

echo "Kubernetes resources are applied."

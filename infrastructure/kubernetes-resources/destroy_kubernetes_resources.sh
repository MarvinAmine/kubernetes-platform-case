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

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${AKS_CLUSTER_NAME:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, AKS_CLUSTER_NAME, TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi

export EXPECTED_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export EXPECTED_RESOURCE_GROUP="$RESOURCE_GROUP"
export EXPECTED_AKS_CLUSTER_NAME="$AKS_CLUSTER_NAME"

if ! az group show --name "$RESOURCE_GROUP" --output none >/dev/null 2>&1; then
    echo "Azure resource group $RESOURCE_GROUP does not exist. Skipping Kubernetes resource destruction."
    exit 0
fi

if ! az aks show --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --output none >/dev/null 2>&1; then
    echo "AKS cluster $AKS_CLUSTER_NAME does not exist. Skipping Kubernetes resource destruction."
    exit 0
fi

echo "Validating access to the expected AKS cluster..."
"$SCRIPT_DIR/scripts/validate-cluster-access.sh"

cd "$SCRIPT_DIR/terraform"

terraform init \
  -backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=kubernetes-resources/terraform.tfstate" \
  -backend-config="use_azuread_auth=true"

terraform destroy -auto-approve

echo "Kubernetes resources have been destroyed."

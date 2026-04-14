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


if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${LOCATION:-}" || -z "${AKS_CLUSTER_NAME:-}" || -z "${TF_BACKEND_RESOURCE_GROUP:-}" || -z "${TF_BACKEND_STORAGE_ACCOUNT:-}" || -z "${TF_BACKEND_CONTAINER:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, LOCATION, AKS_CLUSTER_NAME,TF_BACKEND_RESOURCE_GROUP, TF_BACKEND_STORAGE_ACCOUNT and TF_BACKEND_CONTAINER must be set in $ENV_FILE"
    exit 1
fi


echo "Converting the .env variables in Terraform auto injected variable format"
export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_resource_group_name="$RESOURCE_GROUP"
export TF_VAR_location="$LOCATION"
export TF_VAR_aks_cluster_name="$AKS_CLUSTER_NAME"
export TF_VAR_dns_prefix="${DNS_PREFIX:-aks-stage1}"
export TF_VAR_node_count="${NODE_COUNT:-1}"
export TF_VAR_vm_size="${VM_SIZE:-Standard_D2as_v6}"
export TF_VAR_tier="${TIER:-Free}"


echo "Checking Azure login..."
az account show --output table

echo "Destroying Azure resources managed by Terraform..."
cd "$SCRIPT_DIR/terraform"
terraform init \
-backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
-backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
-backend-config="container_name=$TF_BACKEND_CONTAINER" \
-backend-config="key=azure/terraform.tfstate" \
-backend-config="use_azuread_auth=true"

terraform destroy -auto-approve

echo "Azure infrastructure has been destroyed."

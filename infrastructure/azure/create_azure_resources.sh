#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo "Missing .env file. Copy .env.example to .env and fill the values first."
    exit 1
fi

set -a
source "$SCRIPT_DIR/.env"
set +a

if [[ -z "${SUBSCRIPTION_ID:-}" || -z "${RESOURCE_GROUP:-}" || -z "${LOCATION:-}" || -z "${AKS_CLUSTER_NAME:-}" ]]; then
    echo "SUBSCRIPTION_ID, RESOURCE_GROUP, LOCATION and AKS_CLUSTER_NAME must be set in infrastructure/azure/.env"
    exit 1
fi

export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_resource_group_name="$RESOURCE_GROUP"
export TF_VAR_location="$LOCATION"
export TF_VAR_aks_cluster_name="$AKS_CLUSTER_NAME"
export TF_VAR_dns_prefix="${DNS_PREFIX:-aks-stage1}"
export TF_VAR_node_count="${NODE_COUNT:-1}"
export TF_VAR_vm_size="${VM_SIZE:-Standard_D2as_v6}"
export TF_VAR_tier="${TIER:-Free}"

echo "Checking Azure login..."
az account show --output table >/dev/null

cd "$SCRIPT_DIR/terraform"
terraform init

echo "If the next step fails because the resource group already exists, run:"
echo "terraform import azurerm_resource_group.aks \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP\""

echo "Planning Azure resources..."
terraform plan

echo "Applying Azure resources..."
terraform apply -auto-approve

echo "Done."
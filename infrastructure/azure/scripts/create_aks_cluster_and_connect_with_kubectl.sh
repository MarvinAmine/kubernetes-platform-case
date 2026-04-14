#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../../.env"
ENV_FILE_TEMPLATE="$SCRIPT_DIR/../../.env.example"
cd "$SCRIPT_DIR/.."

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Copy $ENV_FILE_TEMPLATE to $ENV_FILE and fill the environment variables."
    exit 1
fi

# Source the variables from the env file
set -a
source "$ENV_FILE"
set +a

if [[ -z "$RESOURCE_GROUP"  || -z  "$LOCATION" || -z  "$AKS_CLUSTER_NAME" ]]; then
    echo "RESOURCE_GROUP, LOCATION and AKS_CLUSTER_NAME shouldn't be empty or unset"
    exit 1
fi

echo "Please don't forget to login on Azure using 'az login' if it's not already done."
echo "This step will take around 10 minutes to create the Azure AKS service..."

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --node-count 1 \
  --generate-ssh-keys \
  --tier free 

az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --overwrite-existing

kubectl config current-context
kubectl get nodes

echo 'You can delete the resource group at any time using: "az group delete --name "$RESOURCE_GROUP" --yes --no-wait"'

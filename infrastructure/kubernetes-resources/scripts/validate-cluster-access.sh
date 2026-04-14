#!/usr/bin/env bash
set -euo pipefail

# How to run it locally?
# export EXPECTED_SUBSCRIPTION_ID="<your-subscription-id>"
# export EXPECTED_RESOURCE_GROUP="rg-stage1-aks"
# export EXPECTED_AKS_CLUSTER_NAME="aks-stage1-platform"

EXPECTED_SUBSCRIPTION_ID="${EXPECTED_SUBSCRIPTION_ID:?EXPECTED_SUBSCRIPTION_ID is required}"
EXPECTED_RESOURCE_GROUP="${EXPECTED_RESOURCE_GROUP:?EXPECTED_RESOURCE_GROUP is required}"
EXPECTED_AKS_CLUSTER_NAME="${EXPECTED_AKS_CLUSTER_NAME:?EXPECTED_AKS_CLUSTER_NAME is required}"

echo "Checking Azure account..."
ACTIVE_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
ACTIVE_SUBSCRIPTION_NAME="$(az account show --query name -o tsv)"

echo "Active subscription name: ${ACTIVE_SUBSCRIPTION_NAME}"
echo "Active subscription id: ${ACTIVE_SUBSCRIPTION_ID}"

if [ "$ACTIVE_SUBSCRIPTION_ID" != "$EXPECTED_SUBSCRIPTION_ID" ]; then
    echo "ERROR: wrong Azure subscription"
    exit 1
fi

echo
echo "Refreshing AKS credentials for expected cluster..."
az aks get-credentials \
    --resource-group "$EXPECTED_RESOURCE_GROUP" \
    --name "$EXPECTED_AKS_CLUSTER_NAME" \
    --overwrite-existing

echo
echo "Checking kubectl context..."
CURRENT_CONTEXT="$(kubectl config current-context)"
echo "Current context: ${CURRENT_CONTEXT}"

echo
echo "Checking cluster info..."
kubectl cluster-info

echo
echo "Checking kube-system namespace..."
kubectl get ns kube-system

echo
echo "Cluster access validation passed."



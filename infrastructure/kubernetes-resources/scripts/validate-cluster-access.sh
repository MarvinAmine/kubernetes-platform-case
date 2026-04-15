#!/usr/bin/env bash
set -euo pipefail

# This script validates AKS access for the kubernetes-resources layer.
#
# Preferred interface:
#   EXPECTED_SUBSCRIPTION_ID
#   EXPECTED_RESOURCE_GROUP
#   EXPECTED_AKS_CLUSTER_NAME
#
# Backward-compatible fallback:
#   SUBSCRIPTION_ID
#   RESOURCE_GROUP
#   AKS_CLUSTER_NAME

EXPECTED_SUBSCRIPTION_ID="${EXPECTED_SUBSCRIPTION_ID:-${SUBSCRIPTION_ID:-}}"
EXPECTED_RESOURCE_GROUP="${EXPECTED_RESOURCE_GROUP:-${RESOURCE_GROUP:-}}"
EXPECTED_AKS_CLUSTER_NAME="${EXPECTED_AKS_CLUSTER_NAME:-${AKS_CLUSTER_NAME:-}}"

EXPECTED_SUBSCRIPTION_ID="${EXPECTED_SUBSCRIPTION_ID:?EXPECTED_SUBSCRIPTION_ID is required (or set SUBSCRIPTION_ID for backward compatibility)}"
EXPECTED_RESOURCE_GROUP="${EXPECTED_RESOURCE_GROUP:?EXPECTED_RESOURCE_GROUP is required (or set RESOURCE_GROUP for backward compatibility)}"
EXPECTED_AKS_CLUSTER_NAME="${EXPECTED_AKS_CLUSTER_NAME:?EXPECTED_AKS_CLUSTER_NAME is required (or set AKS_CLUSTER_NAME for backward compatibility)}"

echo "Checking Azure account..."
ACTIVE_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
ACTIVE_SUBSCRIPTION_NAME="$(az account show --query name -o tsv)"

echo "Active subscription name: ${ACTIVE_SUBSCRIPTION_NAME}"
echo "Active subscription id: ${ACTIVE_SUBSCRIPTION_ID}"

if [ "$ACTIVE_SUBSCRIPTION_ID" != "$EXPECTED_SUBSCRIPTION_ID" ]; then
    echo "ERROR: wrong Azure subscription"
    echo "Expected subscription id: ${EXPECTED_SUBSCRIPTION_ID}"
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

if [ "$CURRENT_CONTEXT" != "$EXPECTED_AKS_CLUSTER_NAME" ]; then
    echo "ERROR: wrong kubectl context"
    echo "Expected context: ${EXPECTED_AKS_CLUSTER_NAME}"
    exit 1
fi

echo
echo "Checking cluster info..."
kubectl cluster-info

echo
echo "Checking kube-system namespace..."
kubectl get ns kube-system

echo
echo "Cluster access validation passed."


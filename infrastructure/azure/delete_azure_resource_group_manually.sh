#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${1:-rg-stage1-aks}"

echo "Checking Azure login..."
az account show --output table

echo "Deleting resource group: $RESOURCE_GROUP, it might take more than 5 minutes. Please be patient..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo "Done."

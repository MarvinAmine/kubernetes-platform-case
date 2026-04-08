export RESOURCE_GROUP="rg-stage1-aks"
export LOCATION="canadacentral"
export CLUSTER_NAME="aks-stage1-platform"

echo "Please don't forget to login on Azure using 'az login' if it's not already done."
echo "This step will take around 10 minutes to create the Azure AKS service..."

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --node-count 1 \
  --generate-ssh-keys \
  --tier free 

az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --overwrite-existing

kubectl config current-context
kubectl get nodes

echo 'You can delete the resource group at any time using: "az group delete --name "$RESOURCE_GROUP" --yes --no-wait"'
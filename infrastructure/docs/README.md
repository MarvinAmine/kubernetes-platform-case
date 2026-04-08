# Infrastructure documentation

> This folder is reserved to the infrastructure team. In hightly regulated compagnies, this folder would be specifically on his own repository, only accessible by the infra team.

## Azure

### Requirments steps (if it's not already done):

#### Install AZ command line on linux:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version
```

#### Interactive login
```bash
az login
```

#### If you have multiple subscriptions
```bash
# identify the right subcription
az account list --output table
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

#### Register the resource providers
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
```

### Create the AKS cluster and connect the kubectl to it:
```bash
# From the root
cd infrastructure/azure
./create_aks_cluster_and_connect_with_kubectl.sh
```

### Delete the AKS cluster to avoid any additional feeds, after the simulation
```bash
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
```

## Terraform

Init and validate the syntax of the terrafom files:
```bash
# From the root direcctory
cd /infrastructure/terraform
terraform init
terrafrom validate
```

`terraform init` will initiate the backend, and provider plugins like `hashicorp/kubernetes` pluging. It will also create the `.terraform.lock.hcl` file.

Show changes required by the current configuration. Create the `.terraform.tfstate.lock.info` file:
```bash
terraform plan
```

Create or update infrastructure
```bash
terraform apply
```

Verify the kubernetes ressources (here is the official documentation [Terraform_ArchiCorp_Kubernetes_provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace))
```bash
kubectl get ns document-processing-stage1
```
```bash
NAME                         STATUS   AGE
document-processing-stage1   Active   24m
```

```bash
kubectl get serviceaccounts -n document-processing-stage1 
```
```bash
NAME             AGE
app-runtime-sa   50s
```

```bash
k get roles.rbac.authorization.k8s.io -n document-processing-stage1
```
```bash
NAME               CREATED AT
app-runtime-role   2026-04-05T19:45:05Z
```

```bash
k -n document-processing-stage1 get rolebindings.rbac.authorization.k8s.io 
```
```bash
NAME             ROLE                    AGE
app-runtime-rb   Role/app-runtime-role   26s
```

```bash
kubectl auth can-i list configmaps  --as=system:serviceaccount:document-processing-stage1:app-runtime-sa   -n document-processing-stage1
```
```bash
yes
```

```bash
kubectl auth can-i list pods  --as=system:serviceaccount:document-processing-stage1:app-runtime-sa   -n document-processing-stage1
```
```bash
yes
```

```bash
k -n document-processing-stage1 get configmaps 
```
```bash
NAME                       DATA   AGE
kube-root-ca.crt           1      3h17m
platform-baseline-config   3      42s
```
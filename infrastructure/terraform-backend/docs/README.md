# Remote backend stats instructions

## 1. Confirm the remote backend validity

```bash
cd infrastructure/terraform-backend/terraform
terraform init
terraform validate
terraform plan
```
## 2. Create the backend
```bash
terraform apply
```

The command `terraform apply` will provide you these values:
1. `backend_container_name`
2. `backend_resource_group_name`
3. `backend_storage_account_name`

> Note them, you will need them on the next steps.

Then verify in Azure:
```bash
# The values was given by the terraform apply command 
export BACKEND_CONTAINER_NAME=<backend_container_name_value>
export BACKEND_RESOURCE_GROUP_NAME=<backend_resource_group_name_value>
export BACKEND_STORAGE_ACCOUNT_NAME=<backend_storage_account_name_value>
az storage account show \
--name "<your-backend-storage-account>" \
--resource-group "<your-backend-rg>" \
--output table

az storage container show \
--name "tfstate" \
--account-name "<your-backend-storage-account>" \
--auth-mode login
```

## 3. Fill backend values
Now your `infrastructure/.env` values become real:
```conf
TF_BACKEND_RESOURCE_GROUP="rg-stage1-tfstate"
TF_BACKEND_STORAGE_ACCOUNT="<real-storage-account-name>"
TF_BACKEND_CONTAINER="tfstate"
```
Source your shared env file with `set -a; source infrastructure/.env; set +a`

## 4. Test Azure infrastructure stack against remote backend
Optional `export TF_VAR_subscription_id="<your-subscription-id>"`

From infrastructure/azure/terraform:
```bash
terraform init -migrate-state \
-backend-config="resource_group_name=<tf-backend-rg>" \
-backend-config="storage_account_name=<tf-backend-storage-account>" \
-backend-config="container_name=tfstate" \
-backend-config="key=azure/terraform.tfstate" \
-backend-config="use_azuread_auth=true"
```

Because key-based authentication is disabled on the backend storage account, local `terraform init` must include `use_azuread_auth=true`.


```bash
terraform validate
terraform plan
```

> If there was no old local state, you can use terraform init
without -migrate-state.

## Scripted usage

The wrapper scripts stay at the layer root:

- `infrastructure/terraform-backend/create_remote_backend.sh`
- `infrastructure/terraform-backend/destroy_remote_backend.sh`

They load `infrastructure/.env` and run Terraform from `infrastructure/terraform-backend/terraform`.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-stage1-tfstate"
    storage_account_name = "tfbackendplaceholder"
    container_name       = "tfstate"
    key                  = "platform/kubernetes-resources/terraform.tfstate"
    use_azuread_auth     = true
  }
}

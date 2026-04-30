terraform {
  backend "azurerm" {
    resource_group_name  = "rg-stage1-tfstate"
    storage_account_name = "tfbackendplaceholder"
    container_name       = "tfstate"
    key                  = "azure/terraform.tfstate"
    use_azuread_auth     = true
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfstate" {
  name     = var.backend_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = var.backend_storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.backend_container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"

  depends_on = [
    azurerm_role_assignment.tfstate_blob_data_owner
  ]
}

resource "azurerm_role_assignment" "tfstate_blob_data_owner" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}
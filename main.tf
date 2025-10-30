
module "storageacc" {
  source = "./module/storageaccount"
  #   version                  = "1.0.0"
  name_prefix              = var.name_prefix
  location                 = var.location
  account_replication_type = var.account_replication_type
}

data "azurerm_client_config" "current" {}

output "current_object_id" {
  value = data.azurerm_client_config.current.object_id
}
output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "cmk_id" {
  value = azurerm_storage_account_customer_managed_key.cmk_binding.id
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
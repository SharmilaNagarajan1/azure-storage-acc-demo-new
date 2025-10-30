data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = lower("${var.name_prefix}-rg")
  location = var.location
}

resource "random_string" "unique_name" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                     = lower("${var.name_prefix}${random_string.unique_name.result}")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [customer_managed_key]
  }

  tags = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                     = "${var.name_prefix}-kv"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "storage_account_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_storage_account.storage.identity[0].principal_id
  secret_permissions = ["Get"]
  key_permissions    = ["Get", "WrapKey", "UnwrapKey"]
}

resource "azurerm_key_vault_access_policy" "client_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Get"]
  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}

resource "azurerm_key_vault_key" "cmk" {
  name         = "${var.name_prefix}-cmk"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client_policy,
    azurerm_key_vault_access_policy.storage_account_policy
  ]
}

resource "azurerm_storage_account_customer_managed_key" "cmk_binding" {
  storage_account_id = azurerm_storage_account.storage.id
  key_vault_id       = azurerm_key_vault.kv.id
  key_name           = azurerm_key_vault_key.cmk.name
} 
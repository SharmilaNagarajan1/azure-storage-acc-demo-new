
variable "location" {
  type        = string
  description = "Azure region for the resources"
}

variable "name_prefix" {
  description = "Prefix for the resource names (used for storage account and resource group)."
  type        = string
}

variable "account_tier" {
  description = "The performance tier of the storage account. Possible values: Standard or Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "The replication type of the storage account.Only LRS or GRS are allowed."
  validation {
    condition     = contains(["LRS", "GRS"], var.account_replication_type)
    error_message = "account_replication_type must be either LRS or GRS."
  }
}


variable "tags" {
  description = "Optional tags to apply to the storage account"
  type        = map(string)
  default = {
    environment = "staging"
    project     = "azure-storage-using-terraform-private-registry"
  }
}


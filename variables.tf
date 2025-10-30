variable "name_prefix" {
  type        = string
  description = "Prefix for the storage account name"
  default     = "storageAcc"

}

variable "location" {
  type    = string
  default = "Australia East"
}

variable "account_replication_type" {
  type        = string
  description = "The replication type of the storage account"
  default     = "LRS"

}




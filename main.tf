
module "storageacc" {
  source = "./module/storageaccount" 
  name_prefix              = var.name_prefix
  location                 = var.location
  account_replication_type = var.account_replication_type
}


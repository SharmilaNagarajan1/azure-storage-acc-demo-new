# azure-storage-acc-demo-new

Both root and child module in same repo — a small Terraform demo that shows how to manage an Azure Storage Account using a root configuration that calls a child module located in the repository.

---

Table of contents
- About
- Repo layout
- Prerequisites
- Quickstart
- Example usage
- Variables (child module)
- Outputs (child module)
- Remote state / backend (recommended)
- Validation, linting & testing
- Contributing
- License

About
-----
This repository contains Terraform HCL demonstrating a root module (top-level configuration) that calls a child module (module in ./modules/storage_account). The child module encapsulates creation of an Azure Storage Account and related resources (resource group, optionally network rules, containers, etc.) so you can reuse it from other configs.

Repo layout
-----------
Suggested structure:
- main.tf                 <- root module entrypoint that calls the child module
- variables.tf            <- root-level variables (if any)
- outputs.tf              <- root-level outputs (if any)
- terraform.tfvars        <- example values (gitignore secrets)
- modules/
  - storage_account/
    - main.tf
    - variables.tf
    - outputs.tf
    - README.md            <- (module-level documentation)

Prerequisites
-------------
- Terraform CLI (recommended >= 1.0)
- Azure CLI (az)
- An Azure subscription and permission to create resources
- An Azure AD user/service principal for automation (if running non-interactively)

Quickstart
----------
1. Authenticate:
   - Interactive:
     az login
     az account set --subscription <YOUR_SUBSCRIPTION_ID>
   - CI/service principal:
     export ARM_CLIENT_ID="..."
     export ARM_CLIENT_SECRET="..."
     export ARM_SUBSCRIPTION_ID="..."
     export ARM_TENANT_ID="..."

2. Initialize Terraform:
   terraform init

3. Review plan:
   terraform plan -var-file="terraform.tfvars"

4. Apply:
   terraform apply -var-file="terraform.tfvars"

Example usage (root/main.tf)
----------------------------
This is a minimal example that calls the local child module at ./modules/storage_account

```hcl
provider "azurerm" {
  features = {}
}

module "storage" {
  source              = "./modules/storage_account"
  resource_group_name = var.resource_group_name
  location            = var.location
  storage_account_name = var.storage_account_name
  sku_name            = var.sku_name
  account_tier        = var.account_tier
  enable_https_only   = true
  tags                = var.tags
}
```

Example module path (modules/storage_account/main.tf)
----------------------------------------------------
The child module should contain the storage account resource and any supporting resources. Example snippet:

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  enable_https_traffic_only = var.enable_https_only
  sku_name                 = var.sku_name
  tags                     = var.tags
}
```

Sample variables (modules/storage_account/variables.tf)
------------------------------------------------------
Common variables to include in the child module:

```hcl
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create/use."
}

variable "location" {
  type        = string
  description = "Azure region e.g. eastus."
  default     = "eastus"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account (must be globally unique)."
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "sku_name" {
  type    = string
  default = "Standard_LRS"
}

variable "enable_https_only" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

Sample terraform.tfvars (root)
------------------------------
Store non-secret example values here (do not commit secrets):

```hcl
resource_group_name    = "rg-demo-storage"
location               = "eastus"
storage_account_name   = "demostorageacct12345" # must be globally unique
sku_name               = "Standard_LRS"
account_tier           = "Standard"
account_replication_type = "LRS"
tags = {
  owner = "dev-team"
  env   = "dev"
}
```

Outputs (modules/storage_account/outputs.tf)
-------------------------------------------
Expose important values from the module:

```hcl
output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "primary_connection_string" {
  value     = azurerm_storage_account.this.primary_connection_string
  sensitive = true
}
```

Remote state / backend (recommended)
-----------------------------------
Use a remote backend for collaboration. Example using azurerm backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "azure-storage-acc-demo-new.terraform.tfstate"
  }
}
```

Set up the backend storage container once using az cli or a separate Terraform configuration, then run terraform init.

Validation, linting & testing
-----------------------------
- terraform fmt
- terraform validate
- tflint (optional)
- Checkov / terrascan for security scanning (optional)
- Use terraform plan and review before applying in CI

Best practices
--------------
- Keep secrets out of Terraform files and git. Use environment variables, Azure Key Vault, or a CI secret store.
- Use a remote state backend with state locking.
- Use short, reusable modules with clear inputs and outputs.
- Pin provider versions in provider blocks:
  provider "azurerm" {
    version = "~> 3.0"
    features = {}
  }

Contributing
------------
- Open issues for bugs or feature requests.
- Submit PRs for improvements. Keep changes small and well-described.
- Run terraform fmt and terraform validate before opening a PR.

License
-------
Add your preferred license file (e.g., MIT) at the repository root.

Contact / support
-----------------
If you need help with this repo, open an issue and include:
- Terraform version
- azurerm provider version
- commands you ran and full output (plan/apply)

Generated by GitHub Copilot Chat Assistant.

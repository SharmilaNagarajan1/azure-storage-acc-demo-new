terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.50.0"
    }
  }

    cloud {
      organization = "Sharmila"
      workspaces {
        name = "storage-account-demo-workspace"
      }
    }
}

provider "azurerm" {
  features {}
}
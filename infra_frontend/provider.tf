provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateaccount002"
    container_name       = "tfstate"
    key                  = "frontend-terraform.tfstate"
  }
}

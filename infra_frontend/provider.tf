provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateaccount002"
    container_name       = "tfstate"
    key                  = "frontend-terraform.tfstate"
  }
}


# This configuration sets up the AzureRM provider and configures the backend for Terraform state management.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  resource_provider_registration = "none"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateaccount002"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
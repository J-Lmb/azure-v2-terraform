
# This configuration sets up the AzureRM provider and configures the backend for Terraform state management.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount0025"
    container_name       = "tfstate1"
    key                  = "terraform.tfstate"
  }
}
# Azure Web App name for the Streamlit application
variable "webapp_name" {
  type        = string
  description = "Name of the Azure Web App for Streamlit"
}

# Resource group name where all resources will be created
variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
  default     = "rg-tfstate"
}

# Azure region for resource deployment
variable "location" {
  type        = string
  description = "Azure region for resource deployment"
  default     = "East US"
}

# App Service Plan name
variable "app_service_plan_name" {
  type        = string
  description = "Name of the Azure App Service Plan"
}

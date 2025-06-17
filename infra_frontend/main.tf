# Reference the existing resource group (created by previous deployments)
data "azurerm_resource_group" "frontend" {
  name = var.resource_group_name
}

# Reference the existing App Service Plan (created by previous deployments)
data "azurerm_service_plan" "frontend" {
  name                = var.app_service_plan_name
  resource_group_name = data.azurerm_resource_group.frontend.name
}

# Reference the existing Linux Web App (created by previous deployments)
data "azurerm_linux_web_app" "frontend" {
  name                = var.webapp_name
  resource_group_name = data.azurerm_resource_group.frontend.name
}

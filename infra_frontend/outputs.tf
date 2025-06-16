# Output the URL of the deployed Streamlit application
output "frontend_url" {
  description = "URL of the deployed Streamlit application"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

# Output the Web App name for use in deployment steps
output "webapp_name" {
  description = "Name of the Azure Web App"
  value       = azurerm_linux_web_app.frontend.name
}

# Output the resource group name
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_linux_web_app.frontend.resource_group_name
}

# Output the App Service Plan name
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.frontend.name
}

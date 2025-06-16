output "function_app_name" {
  value = azurerm_linux_function_app.argus.name
}

output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.argus.endpoint
}

output "storage_account_name" {
  value = azurerm_storage_account.argus.name
}

output "logic_app_name" {
  value = azurerm_logic_app_workflow.argus_logic.name
}
output "logic_app_id" {
  value = azurerm_logic_app_workflow.argus_logic.id
}
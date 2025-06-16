resource "azurerm_logic_app_workflow" "argus_logic" {
  name                = "${local.prefix_logic}${var.environmentName}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  

  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0"
  # To define the workflow, use the azurerm_logic_app_action_custom resource or inline actions/triggers as per the provider documentation.
  # The 'definition' attribute is not supported in this resource.

  parameters = {
    "$connections" = jsonencode({
      "value" = {
        "azureblob" = {
          "connectionId" = "/subscriptions/${var.subscription_id}/resourceGroups/${try(data.azurerm_resource_group.argus.name, azurerm_resource_group.argus.name)}/providers/Microsoft.Web/connections/azureblob"
          "connectionName" = "azureblob"
          "id" = "/subscriptions/${var.subscription_id}/providers/Microsoft.Web/locations/${var.location}/managedApis/azureblob"
        }
      }
    })
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environmentName
  }
}

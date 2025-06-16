resource "azurerm_resource_group" "argus" {
  name     = "${local.prefix_rg}${var.environmentName}"
  location = var.location
}

resource "azurerm_storage_account" "argus" {
  name                     = "${local.prefix_storage}${replace(lower(var.environmentName), "-", "")}"
  resource_group_name      = azurerm_resource_group.argus.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cosmosdb_account" "argus" {
  name                = "${local.prefix_cosmos}${replace(lower(var.environmentName), "-", "")}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "argus" {
  name                = "doc-extracts"
  resource_group_name = azurerm_resource_group.argus.name
  account_name        = azurerm_cosmosdb_account.argus.name
}

resource "azurerm_cosmosdb_sql_container" "documents" {
  name                = "documents"
  resource_group_name = azurerm_resource_group.argus.name
  account_name        = azurerm_cosmosdb_account.argus.name
  database_name       = azurerm_cosmosdb_sql_database.argus.name
  partition_key_paths  = "/partitionKey"
  default_ttl         = -1
}

resource "azurerm_cosmosdb_sql_container" "configuration" {
  name                = "configuration"
  resource_group_name = azurerm_resource_group.argus.name
  account_name        = azurerm_cosmosdb_account.argus.name
  database_name       = azurerm_cosmosdb_sql_database.argus.name
  partition_key_paths  = "/partitionKey"
  default_ttl         = -1
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "${local.prefix_log_analytics}${var.environmentName}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  retention_in_days   = 30
}

resource "azurerm_application_insights" "insights" {
  name                = "${local.prefix_insights}${var.environmentName}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log.id
}

resource "azurerm_app_service_plan" "argus" {
  name                = "${local.prefix_plan}${var.environmentName}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_cognitive_account" "argus" {
  name                = "${local.prefix_cog}${replace(lower(var.environmentName), "-", "")}"
  location            = var.location
  resource_group_name = azurerm_resource_group.argus.name
  kind                = "FormRecognizer"
  sku_name            = "S0"
}

resource "azurerm_linux_function_app" "argus" {
  name                       = "${local.prefix_func}${var.environmentName}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.argus.name
  service_plan_id            = azurerm_app_service_plan.argus.id
  storage_account_name       = azurerm_storage_account.argus.name
  storage_account_access_key = azurerm_storage_account.argus.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.9"
    }
    always_on                = true
    application_insights_key = azurerm_application_insights.insights.instrumentation_key

    container_registry_use_managed_identity = false
    linux_fx_version                       = "DOCKER|argus.azurecr.io/argus-backend:latest"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                     = "python"
    FUNCTIONS_EXTENSION_VERSION                  = "~4"
    COSMOS_DB_ENDPOINT                           = azurerm_cosmosdb_account.argus.endpoint
    COSMOS_DB_DATABASE_NAME                      = azurerm_cosmosdb_sql_database.argus.name
    COSMOS_DB_CONTAINER_NAME                     = azurerm_cosmosdb_sql_container.documents.name
    DOCUMENT_INTELLIGENCE_ENDPOINT               = azurerm_cognitive_account.argus.endpoint
    WEBSITES_ENABLE_APP_SERVICE_STORAGE          = false
    WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT    = 1
    FUNCTIONS_WORKER_PROCESS_COUNT               = 1
    AZURE_OPENAI_ENDPOINT                        = var.azure_openai_endpoint
    AZURE_OPENAI_KEY                             = var.azure_openai_key
    AZURE_OPENAI_MODEL_DEPLOYMENT_NAME           = var.azure_openai_model_deployment_name
  }
}

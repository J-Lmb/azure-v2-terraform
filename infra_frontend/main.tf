resource "azurerm_resource_group" "frontend" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_app_service_plan" "frontend" {
  name                = var.app_service_plan
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_linux_web_app" "frontend" {
  name                = var.app_name
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  service_plan_id     = azurerm_app_service_plan.frontend.id

  site_config {
    linux_fx_version = "PYTHON|3.11"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "true"
    "PORT"                                = "8501"
  }
}

# Reference the existing resource group (created by previous deployments)
data "azurerm_resource_group" "frontend" {
  name = var.resource_group_name
}

# Create App Service Plan for hosting the Streamlit application
# Using Linux with B1 SKU for cost-effective deployment
resource "azurerm_service_plan" "frontend" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.frontend.location
  resource_group_name = data.azurerm_resource_group.frontend.name
  os_type             = "Linux"
  sku_name            = "B1"

  tags = {
    Environment = "Production"
    Application = "StreamlitFrontend"
    ManagedBy   = "Terraform"
  }
}

# Create Linux Web App for Streamlit application
resource "azurerm_linux_web_app" "frontend" {
  name                = var.webapp_name
  location            = data.azurerm_resource_group.frontend.location
  resource_group_name = data.azurerm_resource_group.frontend.name
  service_plan_id     = azurerm_service_plan.frontend.id

  site_config {
    # Python 3.11 runtime for Streamlit compatibility
    application_stack {
      python_version = "3.11"
    }
    
    # Always on to prevent cold starts
    always_on = true
  }

  app_settings = {
    # Disable App Service storage for containerized apps
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    
    # Enable build during deployment for Python apps
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    
    # Port configuration for Streamlit (default 8501, but Azure expects 8000)
    "PORT" = "8000"
    
    # Streamlit specific settings
    "STREAMLIT_SERVER_PORT" = "8000"
    "STREAMLIT_SERVER_ADDRESS" = "0.0.0.0"
  }

  tags = {
    Environment = "Production"
    Application = "StreamlitFrontend"
    ManagedBy   = "Terraform"
  }
}

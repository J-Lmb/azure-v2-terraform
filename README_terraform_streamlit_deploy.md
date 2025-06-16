# Terraform-Based Streamlit Frontend Deployment Guide

This guide explains how to use the `terraform-streamlit-deploy.yml` GitHub Actions workflow to deploy a Streamlit application to Azure App Service using Terraform for Infrastructure as Code (IaC).

---

## 🏗️ Architecture Overview

This Terraform-based deployment creates:
- **Azure Resource Group** (`rg-tfstate`)
- **Azure App Service Plan** (Linux, B1 SKU)
- **Azure Linux Web App** (Python 3.11 runtime)
- **Streamlit Application Deployment** (automated via GitHub Actions)

---

## 📋 Prerequisites

### 1. Azure Resources
- **Azure Subscription** with Contributor access
- **Service Principal** with appropriate permissions

### 2. Development Tools
- **Terraform** (v1.5.7 or later)
- **Azure CLI** (latest version)
- **Git** and **GitHub** repository

### 3. Project Structure
```
your-repo/
├── .github/workflows/
│   └── terraform-streamlit-deploy.yml
├── frontend/
│   ├── app.py                    # Main Streamlit application
│   ├── requirements.txt          # Python dependencies
│   └── [other app files]
└── infra_frontend/
    ├── main.tf                   # Infrastructure resources
    ├── variables.tf              # Input variables
    ├── outputs.tf                # Output values
    ├── provider.tf               # Provider configuration
    └── terraform.tfvars          # Variable values
```

---

## 🔐 Setup Instructions

### Step 1: Create Azure Service Principal

Run the following Azure CLI command (replace `<SUBSCRIPTION_ID>`):

```bash
az ad sp create-for-rbac \
  --name "terraform-streamlit-deploy" \
  --role "Contributor" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>" \
  --sdk-auth
```

**Save the JSON output** - you'll need it for GitHub Secrets.

### Step 2: Configure GitHub Secrets

In your GitHub repository: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `ARM_CLIENT_ID` | Service Principal Application ID | `12345678-1234-1234-1234-123456789012` |
| `ARM_CLIENT_SECRET` | Service Principal Password | `your-client-secret` |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID | `87654321-4321-4321-4321-210987654321` |
| `ARM_TENANT_ID` | Azure Tenant ID | `11111111-2222-3333-4444-555555555555` |
| `AZURE_LOGIN_SP_CREDENTIALS` | Complete JSON from Step 1 | `{"clientId":"...","clientSecret":"..."}` |
| `AZURE_WEBAPP_NAME` | Your Web App name | `my-argus-frontend-streamlit` |
| `AZURE_WEBAPP_PLAN` | Your App Service Plan name | `my-argus-frontend-plan` |

---

## 🚀 Deployment Workflow

### Automatic Deployment
The workflow triggers automatically on:
- **Push to `main` branch**
- **Manual trigger** via GitHub Actions UI

### Manual Deployment
1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Deploy Streamlit Frontend via Terraform**
4. Click **Run workflow**

---

## 📝 Workflow Explanation

### Phase 1: Preparation
1. **Checkout code** - Downloads repository content
2. **Setup Python 3.11** - Prepares build environment
3. **Install dependencies** - Installs Streamlit packages
4. **Archive application** - Creates deployment zip

### Phase 2: Infrastructure
5. **Setup Terraform** - Installs Terraform CLI
6. **Azure Login** - Authenticates with Service Principal
7. **Terraform Init** - Initializes working directory
8. **Terraform Validate** - Checks configuration syntax
9. **Terraform Plan** - Reviews infrastructure changes
10. **Terraform Apply** - Creates/updates Azure resources

### Phase 3: Application Deployment
11. **Deploy Application** - Uploads zip to Web App
12. **Configure Settings** - Sets Streamlit startup command
13. **Output URLs** - Shows deployment and portal links

---

## 🔧 Customization Options

### Infrastructure Customization

Edit `infra_frontend/terraform.tfvars`:

```hcl
# Application configuration
webapp_name           = "your-app-name"
app_service_plan_name = "your-plan-name"

# Resource configuration  
resource_group_name = "your-resource-group"
location           = "East US"  # or your preferred region
```

### App Service Plan Scaling

In `infra_frontend/main.tf`, modify the SKU:

```hcl
resource "azurerm_service_plan" "frontend" {
  # ... other settings ...
  sku_name = "B2"  # Options: B1, B2, B3, S1, S2, S3, P1v2, P2v2, P3v2
}
```

### Application Settings

Add custom environment variables in `main.tf`:

```hcl
resource "azurerm_linux_web_app" "frontend" {
  # ... other settings ...
  
  app_settings = {
    # Existing settings...
    
    # Custom application settings
    "CUSTOM_API_KEY"    = "your-api-key"
    "DEBUG_MODE"        = "false"
    "CACHE_TIMEOUT"     = "3600"
  }
}
```

---

## 🛠️ Local Development & Testing

### Test Terraform Configuration

```bash
# Navigate to infrastructure directory
cd infra_frontend

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment (dry run)
terraform plan

# Apply changes (creates resources)
terraform apply

# Destroy resources (cleanup)
terraform destroy
```

### Test Streamlit App Locally

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
pip install -r requirements.txt

# Run Streamlit app
streamlit run app.py
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. **Application Error Page**
- **Cause**: Startup command not set correctly
- **Solution**: Workflow automatically sets: `streamlit run app.py --server.port=8000 --server.address=0.0.0.0`

#### 2. **Terraform Authentication Failed**
- **Cause**: Incorrect Service Principal credentials
- **Solution**: Verify all ARM_* secrets are correctly set

#### 3. **Resource Already Exists**
- **Cause**: Resources exist outside Terraform management
- **Solution**: Import existing resources or use different names

#### 4. **Deployment Package Not Found**
- **Cause**: Zip creation failed or wrong path
- **Solution**: Check workflow logs for packaging step

### Debug Steps

1. **Check Workflow Logs**:
   - Go to Actions tab in GitHub
   - Click on failed workflow run
   - Review step-by-step logs

2. **Verify Azure Resources**:
   ```bash
   # Check resource group
   az group show --name rg-tfstate
   
   # Check app service plan
   az appservice plan show --name your-plan-name --resource-group rg-tfstate
   
   # Check web app
   az webapp show --name your-app-name --resource-group rg-tfstate
   ```

3. **Check Application Logs**:
   - Azure Portal → Your Web App → Monitoring → Log stream
   - Or via CLI: `az webapp log tail --name your-app-name --resource-group rg-tfstate`

---

## 🔒 Security Best Practices

### Infrastructure Security
- ✅ Use managed identities where possible
- ✅ Apply least-privilege access principles
- ✅ Enable HTTPS only
- ✅ Regular security updates

### Secrets Management
- ✅ Store sensitive data in GitHub Secrets
- ✅ Never commit credentials to repository
- ✅ Rotate Service Principal credentials regularly
- ✅ Use Azure Key Vault for application secrets

### Network Security
- ✅ Consider virtual network integration for production
- ✅ Implement proper firewall rules
- ✅ Use custom domains with SSL certificates

---

## 📊 Monitoring & Maintenance

### Application Insights
Add Application Insights to `main.tf`:

```hcl
resource "azurerm_application_insights" "frontend" {
  name                = "${var.webapp_name}-insights"
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  application_type    = "web"
}

# Add to web app app_settings:
"APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.frontend.instrumentation_key
```

### Cost Management
- Monitor costs via Azure Cost Management
- Set up budget alerts
- Consider autoscaling for production workloads

---

## 🔗 Useful Links

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Streamlit Deployment Guide](https://docs.streamlit.io/deployment)
- [GitHub Actions for Azure](https://github.com/Azure/actions)

---

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review workflow and Terraform logs
3. Consult Azure and Streamlit documentation
4. Open an issue in your repository with detailed error logs

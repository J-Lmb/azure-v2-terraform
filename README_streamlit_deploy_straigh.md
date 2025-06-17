# Streamlit Frontend Azure App Service Deployment Guide

This guide explains how to create a GitHub Actions workflow (`streamlit-frontend-deploy.yml`) to deploy a Streamlit app to Azure App Service, including how to provision and configure all required Azure resources, set up secrets, and understand each workflow command.

---

## 1. Prerequisites

- **Azure Subscription**: You need an active Azure subscription.
- **Azure CLI**: Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- **GitHub Repository**: Your Streamlit app code should be in a GitHub repo, with the frontend code in a `frontend/` folder.
- **App Structure**: Ensure your main Streamlit file (e.g., `app.py`) is in `frontend/` and `requirements.txt` lists all dependencies.

---

## 2. Required Azure Resources

You will need:
- **Resource Group** (e.g., `rg-tfstate`)
- **App Service Plan** (e.g., `my-argus-frontend-plan`)
- **Web App** (e.g., `my-argus-frontend-streamlit`)

### How to Create These Resources

#### a. Resource Group
- In Azure Portal: Search for "Resource groups" > "Create" > Fill in details > "Review + create"
- Or via CLI:
  ```sh
  az group create --name rg-tfstate --location EastUS
  ```

#### b. App Service Plan
- In Azure Portal: Search for "App Service Plans" > "Create" > Fill in details (Linux, B1 or higher)
- Or via CLI:
  ```sh
  az appservice plan create --name my-argus-frontend-plan --resource-group rg-tfstate --sku B1 --is-linux
  ```

#### c. Web App
- In Azure Portal: Search for "App Services" > "Create" > Fill in details (Python 3.11, Linux, use above plan)
- Or via CLI:
  ```sh
  az webapp create --name my-argus-frontend-streamlit --resource-group rg-tfstate --plan my-argus-frontend-plan --runtime "PYTHON:3.11"
  ```

---

## 3. Azure Service Principal & GitHub Secrets

### a. Create a Service Principal
Run this command (replace `<SUBSCRIPTION_ID>`):
```sh
az ad sp create-for-rbac --name "github-actions-deploy" --role contributor --scopes /subscriptions/<SUBSCRIPTION_ID> --sdk-auth
```
Copy the JSON output.

### b. Add GitHub Secrets
In your repo: Settings > Secrets and variables > Actions > New repository secret. Add:
- `AZURE_LOGIN_SP_CREDENTIALS`: Paste the JSON from above
- `AZURE_WEBAPP_NAME`: Your web app name (e.g., `my-argus-frontend-streamlit`)
- `AZURE_WEBAPP_PLAN`: Your app service plan name (e.g., `my-argus-frontend-plan`)
- `AZURE_WEBAPP_RG`: Your resource group (e.g., `rg-tfstate`)

---

## 4. Creating the Workflow File

Create `.github/workflows/streamlit-frontend-deploy.yml` with the following content:

```yaml
name: Deploy Streamlit Frontend to Azure App Service

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    env:
      AZURE_WEBAPP_NAME: ${{ secrets.AZURE_WEBAPP_NAME }}
      AZURE_WEBAPP_RG: ${{ secrets.AZURE_WEBAPP_RG }}
      AZURE_WEBAPP_PLAN: ${{ secrets.AZURE_WEBAPP_PLAN }}
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Archive Streamlit app
        run: |
          zip -r streamlit-frontend.zip .

      - name: Azure CLI Login
        uses: azure/login@v2
        with:
          CREDS: ${{ secrets.AZURE_LOGIN_SP_CREDENTIALS }}

      - name: Ensure Resource Group Exists
        run: |
          az group show --name rg-tfstate || az group create --name "rg-tfstate" --location "EastUS"

      - name: Ensure App Service Plan Exists
        run: |
          if [ -z "$AZURE_WEBAPP_PLAN" ]; then
            echo "AZURE_WEBAPP_PLAN is not set!" && exit 1
          fi
          if ! az appservice plan show --name "$AZURE_WEBAPP_PLAN" --resource-group rg-tfstate; then
            az appservice plan create --name "$AZURE_WEBAPP_PLAN" --resource-group rg-tfstate --sku B1 --is-linux
          fi

      - name: Ensure Web App Exists
        run: |
          az webapp show --name $AZURE_WEBAPP_NAME --resource-group "rg-tfstate" || \
          az webapp create --name $AZURE_WEBAPP_NAME --resource-group "rg-tfstate" --plan $AZURE_WEBAPP_PLAN --runtime "PYTHON:3.11"

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.AZURE_WEBAPP_NAME }}
          slot-name: 'production'
          package: frontend/streamlit-frontend.zip

      - name: Post deployment - Show Web App URL
        run: |
          echo "Deployed to: https://${{ env.AZURE_WEBAPP_NAME }}.azurewebsites.net"
```

---

## 5. Explanation of Workflow Steps

- **Checkout code**: Pulls your repo code into the runner.
- **Set up Python**: Installs Python 3.11 for dependency installation and packaging.
- **Install dependencies**: Installs all Python packages listed in `requirements.txt`.
- **Archive Streamlit app**: Zips the contents of the `frontend/` directory for deployment.
- **Azure CLI Login**: Authenticates the runner to Azure using your Service Principal.
- **Ensure Resource Group Exists**: Checks for the resource group, creates it if missing.
- **Ensure App Service Plan Exists**: Checks for the app service plan, creates it if missing.
- **Ensure Web App Exists**: Checks for the web app, creates it if missing.
- **Deploy to Azure Web App**: Uploads and deploys the zipped app to Azure App Service.
- **Post deployment**: Prints the deployed app's URL.

---

## 6. Troubleshooting

- **Application Error Page**: Usually means the app failed to start. Check:
  - The main file is named `app.py` and is at the root of the zip.
  - All dependencies are in `requirements.txt`.
  - We need to think about Port Binding: Streamlit must listen on port 8000 and address 0.0.0.0 for Azure.
  - Set the Startup Command in Azure Portal to:
    ```
    streamlit run app.py --server.port=8000 --server.address=0.0.0.0
    ```
- **No package found error**: Ensure the `package:` path in the deploy step matches where the zip is created.
- **Permission errors**: Ensure your Service Principal has Contributor access to the resource group.

---

## 7. References
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Streamlit Deployment Guide](https://docs.streamlit.io/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)

---

## 8. Support
If you encounter issues, check the Azure App Service logs in the Azure Portal under your Web App > Monitoring > Log stream, or open an issue in your repository.

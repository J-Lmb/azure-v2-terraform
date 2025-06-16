
# ARGUS Infrastructure Deployment

## 🚀 Overview

This project provisions and manages the complete **ARGUS Azure infrastructure** using **Terraform**. It automates the deployment of critical cloud resources, including:

- **Function App** (Docker-based)
- **Cosmos DB** (with containers)
- **Azure Storage Account**
- **Application Insights & Log Analytics**
- **Cognitive Services (Document Intelligence)**
- **Logic App** (email trigger to blob)
- **GitHub Actions** workflow for CI/CD

---

## 📁 Project Structure

```
ARGUS/
├── .github/workflows/terraform-deploy.yml   # GitHub Actions CI/CD pipeline
└── infra/                         # Terraform-based IaC directory
    ├── main.tf                    # Core Azure resources
    ├── logic_app.tf               # Logic App deployment using external JSON
    ├── logic_app.json             # Logic App definition
    ├── outputs.tf                 # Terraform output values
    ├── provider.tf                # Azure provider and backend config
    ├── terraform.tfvars           # Input values for variables
    ├── variables.tf               # Variable definitions
    ├── abbreviations.json         # Resource-type-based naming prefixes
    └── locals.tf                  # Decodes abbreviations and defines naming prefixes
```

---

## 🛠️ Prerequisites

- Azure subscription with Contributor permissions
- A service principal with the following secrets stored in GitHub:
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
- GitHub repository to host this project

---

## 🔄 Deployment Flow

### Step 1: Code Push

On every push to the `main` branch, GitHub Actions triggers the CI/CD pipeline defined in `.github/workflows/terraform-deploy.yml`.

### Step 2: Terraform Workflow

GitHub Actions runs the following stages from the `infra/` directory:

1. **Terraform Init**  
   Initializes the backend using remote state (Azure Blob Storage).

2. **Terraform Validate**  
   Ensures your configuration is syntactically correct.

3. **Terraform Plan**  
   Shows the proposed infrastructure changes.

4. **Terraform Apply**  
   Provisions the Azure resources automatically.

---

### 🔹 `locals.tf`
This Terraform file dynamically loads abbreviations.json using jsondecode(), and creates reusable local variables (prefixes) for resource naming throughout the deployment.
locals {
  abbreviations = jsondecode(file("${path.module}/abbreviations.json"))

  prefix_func     = local.abbreviations.webSitesFunctions
  prefix_storage  = local.abbreviations.storageStorageAccounts
  prefix_cosmos   = local.abbreviations.documentDBDatabaseAccounts
}
----

## 🔐 Secrets Management

In your GitHub repo, go to:

**Settings → Secrets and variables → Actions → New repository secret**

Add the following:

| Secret Name            | Description                     |
|------------------------|---------------------------------|
| `ARM_CLIENT_ID`        | App registration client ID      |
| `ARM_CLIENT_SECRET`    | App registration client secret  |
| `ARM_SUBSCRIPTION_ID`  | Azure subscription ID           |
| `ARM_TENANT_ID`        | Azure tenant ID                 |

---

## ⚙️ Infrastructure Components

### ✅ `main.tf`
Provisions core components:
- Function App (with Docker image from ACR)
- Cosmos DB with `documents` and `configuration` containers
- App Insights & Log Analytics
- Storage Account (Hot-tier)
- Cognitive Services

### ✅ `logic_app.tf` & `logic_app.json`
Deploys a Logic App that:
- Triggers on incoming email with attachments
- Uploads the attachments to a blob container (`datasets/`)

### ✅ `provider.tf`
Configures Azure provider and backend (remote state in a storage account).

### ✅ `terraform.tfvars` & `variables.tf`
Define and inject environment-specific values like:
- `environmentName`
- `location`
- `azurePrincipalId`

---

## 🧪 Outputs

After deployment, Terraform provides:
- Function App URL
- Cosmos DB endpoint
- Logic App name
- Storage account name

---

## 📣 Notes

- Ensure the `terraform.tfvars` values match your deployment environment.
- Replace placeholder secrets (`<secure-var>`) with real values via Key Vault or GitHub Secrets.
- The deployment is idempotent — you can run it multiple times without duplicating resources.

---



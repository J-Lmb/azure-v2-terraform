variable "environmentName" {
  type = string
}

variable "location" {
  type = string
}

variable "azurePrincipalId" {
  type = string
}

variable "client_id" {
  type        = string
  description = "Azure service principal client ID"
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = "Azure service principal client secret"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_openai_key" {
  type        = string
  description = "openai key"
}

variable "azure_openai_model_deployment_name" {
  type        = string
  description = "openai deploy name"
}

variable "azure_openai_endpoint" {
  type        = string
  description = "openai endpoint"
}
# This locals block defines abbreviations for various Azure resources used in the Terraform configuration.
# It reads from a JSON file named abbreviations.json located in the same module directory.

locals {
  abbreviations = jsondecode(file("${path.module}/abbreviations.json"))

  prefix_rg         = local.abbreviations.resourcesResourceGroups
  prefix_storage    = local.abbreviations.storageStorageAccounts
  prefix_cosmos     = local.abbreviations.documentDBDatabaseAccounts
  prefix_func       = local.abbreviations.webSitesFunctions
  prefix_plan       = local.abbreviations.webServerFarms
  prefix_logic      = local.abbreviations.logicWorkflows
  prefix_insights   = local.abbreviations.insightsComponents
  prefix_log_analytics = local.abbreviations.operationalInsightsWorkspaces
  prefix_cog        = local.abbreviations.cognitiveServicesAccounts
}

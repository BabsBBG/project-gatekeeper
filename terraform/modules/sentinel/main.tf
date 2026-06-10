resource "azurerm_resource_group" "gatekeeper" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = "hlx-law-sentinel"
  location            = azurerm_resource_group.gatekeeper.location
  resource_group_name = azurerm_resource_group.gatekeeper.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    project = "Gatekeeper"
  }
}

# Enable Sentinel
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.sentinel.id
}

# Example analytics rule – Break‑Glass Access
resource "azurerm_sentinel_alert_rule_scheduled" "breakglass" {
  name                       = "HLX-DETECT-001-BreakGlassAccess"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
  display_name               = "Break-Glass Account Access"
  severity                   = "High"
  enabled                    = true

  query = <<-EOT
    SigninLogs
    | where TimeGenerated > ago(24h)
    | where UserPrincipalName in ("bg-01@bbgseclab.onmicrosoft.com", "bg-02@bbgseclab.onmicrosoft.com")
    | project TimeGenerated, UserPrincipalName, IPAddress, Location
  EOT

  query_frequency = "PT5M"
  query_period    = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
  tactics = ["InitialAccess"]
}
output "azure_logs_loganalytics_workspaceid" {
  value = "${azurerm_log_analytics_workspace.allogs.workspace_id}"
}

output "azure_logs_loganalytics_workspacekey" {
  value = "${azurerm_log_analytics_workspace.allogs.primary_shared_key}"
}

output "azure_logs_loganalytics_workspace_url" {
  value = "${azurerm_log_analytics_workspace.allogs.portal_url}"
}

output "access_key1_storage_account_backend" {
  value = "${azurerm_storage_account.stor.primary_access_key}"
}
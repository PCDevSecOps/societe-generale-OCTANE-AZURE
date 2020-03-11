
resource "null_resource" "variable" {
  provisioner "local-exec" {
    command = "write-host subscription: ${var.subscription_id}  client_id:${var.client_id}  tenant_id:${var.tenant_id} "
    interpreter = ["PowerShell", "-Command"]
  }
}


provider "azurerm" {
  subscription_id = "${var.subscription_id}"	    
  client_id       = "${var.client_id}"	   
  client_secret   = "${var.client_secret}"	
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "logs_rg" {
  name     = "log-analytics-ciap-host-socle-${var.location}"
  location = "${var.location}"
}


resource "azurerm_log_analytics_workspace" "allogs" {
  name                = "ciap-hosting-workspace"
  location            = "${azurerm_resource_group.logs_rg.location}"
  resource_group_name = "${azurerm_resource_group.logs_rg.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 365
}

resource "azurerm_log_analytics_solution" "loganalyse" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.logs_rg.location}"
  resource_group_name   = "${azurerm_resource_group.logs_rg.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.allogs.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.allogs.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


resource "azurerm_resource_group" "backendrg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    RGBKD = "RGBKD"
  }

}

resource "azurerm_storage_account" "stor" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.backendrg.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = ["azurerm_resource_group.backendrg"]
}

resource "null_resource" "delay2min" {
  provisioner "local-exec" {
    command = "Start-Sleep 120"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = ["azurerm_resource_group.backendrg", "azurerm_storage_account.stor"]
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = "${var.storage_account_name}"
  container_access_type = "blob"

  depends_on = ["azurerm_resource_group.backendrg", "azurerm_storage_account.stor", "null_resource.delay2min"]
}


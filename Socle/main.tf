
resource "null_resource" "variable" {
  provisioner "local-exec" {
    command     = "write-host subscription: ${var.subscription_id}  client_id:${var.client_id}  tenant_id:${var.tenant_id} "
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
  tags = {
    yor_trace = "dcd9a7db-83be-48ee-a0fb-5f0c4c9bc0f8"
  }
}


resource "azurerm_log_analytics_workspace" "allogs" {
  name                = "ciap-hosting-workspace"
  location            = "${azurerm_resource_group.logs_rg.location}"
  resource_group_name = "${azurerm_resource_group.logs_rg.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags = {
    yor_trace = "aafd04f7-6bb4-45b3-a633-8f28f13e858c"
  }
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
  tags = {
    yor_trace = "39a3394f-210a-4e12-bb71-6e3bb008fa30"
  }
}


resource "azurerm_resource_group" "backendrg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    RGBKD = "RGBKD"
  }

  tags = {
    yor_trace = "0f4d1acf-1e2f-42d0-9c99-fa025d1d1cc6"
  }
}

resource "azurerm_storage_account" "stor" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.backendrg.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = ["azurerm_resource_group.backendrg"]
  tags = {
    yor_trace = "12afa345-cad0-4297-b02a-1fda9e1140de"
  }
}

resource "null_resource" "delay2min" {
  provisioner "local-exec" {
    command     = "Start-Sleep 120"
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


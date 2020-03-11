resource "azurerm_storage_account" "stor" {
  name                     = "${var.storage_account_name1}${var.randominstance}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}


resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "Start-Sleep 15"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = ["azurerm_storage_account.stor"]
}


resource "azurerm_storage_container" "container" {
  name                  = "hostingconfigurationbl"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.stor.name}"
  container_access_type = "private"

  depends_on = ["azurerm_storage_account.stor", "null_resource.delay"]
}

resource "null_resource" "delay1" {
  provisioner "local-exec" {
    command = "Start-Sleep 35"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = ["azurerm_storage_account.stor"]
}

#copy ansible roles through storage acount
resource "null_resource" "downloadhostingconfig" {
  provisioner "local-exec" {
    command = "powershell -file .\\modules\\admin\\01_fileshare\\scripts\\copyfile_to_blob.ps1 ${azurerm_storage_account.stor.name} ${azurerm_storage_account.stor.primary_access_key} ${var.storage_account_blob_share_name} $localFile"
    
    environment  {
      storageAccountName               = "${var.storage_account_name1}"
      containerName                    = "${azurerm_storage_container.container.name}"
      localFile                        = "${var.hosting_configuration_zip_file}"
      primaryStorageAccountKey         = "${azurerm_storage_account.stor.primary_access_key}"
      pathterraformzip                 =  "${path.module}\\..\\..\\..\\"
      pathterraformsourceansible       =  "${path.module}\\..\\..\\..\\..\\..\\${var.hosting_source_ansible}"
    }

  }

  depends_on = ["azurerm_storage_container.container", "null_resource.delay1"]
}


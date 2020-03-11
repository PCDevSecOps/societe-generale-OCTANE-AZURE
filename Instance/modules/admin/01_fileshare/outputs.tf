output "access_key1_storage_account_fileshare" {
  value = "${azurerm_storage_account.stor.primary_access_key}"

}


output "blob_endpoint" {
  value = "${azurerm_storage_account.stor.primary_blob_endpoint}"
}




output "copyhostingshell" {
  value = "${null_resource.downloadhostingconfig.id}"
}


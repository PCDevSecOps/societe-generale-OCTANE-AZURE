output "admin-hosting-id" {
  value = "${azurerm_virtual_network_peering.admin-hosting.id}"
}


output "hosting-admin-id" {
  value = "${azurerm_virtual_network_peering.hosting-admin.id}"
}

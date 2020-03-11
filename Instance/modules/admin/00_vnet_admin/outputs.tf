output "admin_vnet_id" {
  value = "${azurerm_virtual_network.vnet.id}"
}


output "vnet_name" {
  value = "${azurerm_virtual_network.vnet.name}"
}


output "subnet_up_id" {

  value = "${azurerm_subnet.subnet_admin.id}"
}


output "hosting_vnet_id" {
  value = "${azurerm_virtual_network.vnet.id}"
}

output "vnet_name" {
  value = "${azurerm_virtual_network.vnet.name}"
}


output "subnet_mid_id" {
  value = "${azurerm_subnet.subnet_mid.id}"
}

output "subnet_low_id" {
  value = "${azurerm_subnet.subnet_low.id}"
}
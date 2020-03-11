resource "azurerm_virtual_network_peering" "admin-hosting" {
  name                         = "admin-to-hosting"
  resource_group_name          = "${var.resource_group_name_admin}"
  virtual_network_name         = "${var.vnet_admin_name}"
  remote_virtual_network_id    = "${var.vnet_hosting_id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false


depends_on = ["null_resource.wait","null_resource.admin_hosting_vnet_id"]


}


resource "azurerm_virtual_network_peering" "hosting-admin" {
  name                         = "hosting-to-admin"
  resource_group_name          = "${var.resource_group_name_hosting}"
  virtual_network_name         =  "${var.vnet_hosting_name}"
  remote_virtual_network_id    = "${var.vnet_admin_id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = ["azurerm_virtual_network_peering.admin-hosting","null_resource.admin_hosting_vnet_id","null_resource.wait"]
}


resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "Start-Sleep -Seconds 60"
    interpreter = ["PowerShell", "-Command"]
  }
}


resource "null_resource" "admin_hosting_vnet_id" {

 provisioner "local-exec" {

   environment {
     depends_on_vnet_admin_id   =   "${var.vnet_admin_id}"
     depends_on_vnet_hosting_id  =   "${var.vnet_hosting_id}"
   }
   command = "echo depends_on_vnets"
 }

}
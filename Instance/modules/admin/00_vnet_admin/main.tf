resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group_name_vnet}"
}


//------------------------------------------------------

resource "azurerm_network_security_group" "sg_admin" {
  name                 = "${var.prefix_admin1}-sg"

  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name_vnet}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    SGADM = "SGADM"
  }
}

resource "azurerm_subnet" "subnet_admin" {
  name                 = "${var.prefix_admin1}-sub"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name = "${var.resource_group_name_vnet}"

  address_prefix       = "${var.subnet_admin1}"
  network_security_group_id = "${azurerm_network_security_group.sg_admin.id}"

}

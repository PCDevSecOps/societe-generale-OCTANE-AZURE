

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group_name_vnet}"

}


resource "azurerm_network_security_group" "hosting_mid" {
  name                         = "${var.prefix_mid}-sg"
  location                     = "${var.location}"
  resource_group_name = "${var.resource_group_name_mid}"

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
  },
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  security_rule {
    name                       = "HTTPS"
    priority                   = 1012
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },

  tags {
      HOSTINGMID = "HOSTINGMID"
  }
}

resource "azurerm_subnet" "subnet_mid" {
  name                      = "${var.prefix_mid}-sub"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  resource_group_name       = "${var.resource_group_name_vnet}"

  address_prefix            = "${var.subnet_mid}"
  network_security_group_id = "${azurerm_network_security_group.hosting_mid.id}"

}


resource "azurerm_network_security_group" "hosting_low" {
  name                  = "${var.prefix_low}-sg"
  location              = "${var.location}"
  resource_group_name = "${var.resource_group_name_low}"

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
  },
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },

  tags {
      SGLOW = "SGLOW"
  }
}

resource "azurerm_subnet" "subnet_low" {
  name                      = "${var.prefix_low}-sub"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  resource_group_name       = "${var.resource_group_name_vnet}"


  address_prefix            = "${var.subnet_low}"
  network_security_group_id = "${azurerm_network_security_group.hosting_low.id}"

}


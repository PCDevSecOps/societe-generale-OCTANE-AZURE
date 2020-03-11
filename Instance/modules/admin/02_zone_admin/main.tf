
resource "azurerm_storage_account" "stor" {
  name                     = "${var.prefix_variable}${var.hostname}${var.randominstance}stor"
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}


resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "Start-Sleep 60"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = ["azurerm_storage_account.stor"]
}
resource "azurerm_availability_set" "avset" {
  name                = "${var.hostname}-avset"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_lb" "lb" {
  resource_group_name = "${var.resource_group}"

  name     = "${var.hostname}-lb"
  location = "${var.location}"



  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    subnet_id                               = "${var.subnet_id}"
    private_ip_address_allocation           = "Dynamic"
  }


  tags {
    CLBADM = "CLBADM"
  }

}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${var.resource_group}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}


resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name = "${var.resource_group}"

  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${var.resource_group}"

  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}${count.index}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  count = "${var.vmadmincount}"

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${var.subnet_id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                = "${var.hostname}${count.index}-vm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                 = "${var.vmadmincount}"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "${var.hostname}${count.index}-osdisk"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username_admin}"
    admin_password = "${var.admin_password_admin}"

    // custom_data    = "${file("${path.module}/scripts/configuration_admin.sh")}"
    custom_data = "${data.template_cloudinit_config.config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username_admin}/.ssh/authorized_keys"
      key_data = "${var.pub_key_admin}"
    }
  }
  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  
  tags  = {
    admin ="admin"
  }

  depends_on = ["null_resource.example", "null_resource.delay"]
}


resource "azurerm_virtual_machine_extension" "ciap-hosting-admin-extension" {
  name                = "${var.hostname}-admin-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
    name                      = "OmsAgentForLinux"  
    publisher                 = "Microsoft.EnterpriseCloud.Monitoring"
    type                      = "OmsAgentForLinux"
    type_handler_version      = "1.7"
    auto_upgrade_minor_version = "true"
    settings              = "{\"workspaceId\": \"${var.azure_logs_loganalytics_workspaceid}\"}"
    protected_settings    = "{\"workspaceKey\": \"${var.azure_logs_loganalytics_workspacekey}\"}"
}


resource "null_resource" "example"   {
  triggers =  {
    hosting_configuration_blob_endpoint  = "${var.hosting_configuration_blob_endpoint}"
    depend_on_hosting_vm                 = "${var.depend_on_hosting_vm}"
    depend_on_vnet_peering_admin_hosting = "${var.depend_on_vnet_peering_admin_hosting}"
    depend_on_vnet_peering_hosting_admin = "${var.depend_on_vnet_peering_hosting_admin}"
    hosting_configuration_blob_endpoint  = "${var.hosting_configuration_blob_endpoint}"
    depend_on_hosting_vm                 = "${var.depend_on_hosting_vm}"
    depend_on_vmmids_id                   = "${var.depend_on_vmmids_id}"
  }
}


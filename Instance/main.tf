
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


terraform {
  backend "azurerm" {}
}



resource "random_integer" "instance" {
  min = 101
  max = 50000
}
# create ressource group for vnet adminitration zone
resource "azurerm_resource_group" "vnetadmin_rg" {
  # name     = "${var.prefix_admin_vnet}-rg" # temporairement
  name     = "${var.prefix_admin_vnet}-${var.location}-${random_integer.instance.result}-rg"
  location = "${var.location}"
  tags {
    RGADM = "RGADM"
  }
  depends_on = ["random_integer.instance"]
  tags = {
    yor_trace = "975f9e57-c93f-48be-bd0a-2c8ff7827e5a"
  }
}

# create ressource group for vnet hosting zone
resource "azurerm_resource_group" "vnethosting_rg" {
  name     = "${var.prefix_hosting_vnet}-${var.location}-${random_integer.instance.result}-rg"
  location = "${var.location}"
  tags {
    RGOCT = "RGOCT"
  }
  tags = {
    yor_trace = "9017b6af-c229-4449-9b61-a582095b085f"
  }
}

# create ressource group for "MID" group
resource "azurerm_resource_group" "mid_rg" {
  name     = "${var.prefix_hosting_mid}-${var.location}-${random_integer.instance.result}-rg"
  location = "${var.location}"

  tags {
    RGMID = "RGMID"
  }
  tags = {
    yor_trace = "a1bbd762-1f59-41bf-9371-484a17d621aa"
  }
}

# create ressource group for "LOW" group
resource "azurerm_resource_group" "low_rg" {
  name     = "${var.prefix_hosting_low}-${var.location}-${random_integer.instance.result}-rg"
  location = "${var.location}"

  tags {
    RGLOW = "RGLOW"
  }
  tags = {
    yor_trace = "e33c8e41-ad64-4e21-8855-f2a40be5ea91"
  }
}





//********************************************************************************
//                         fileshare                                            //
//********************************************************************************
# Create blob storage
module "fileshare" {

  source = "modules/admin/01_fileshare"

  resource_group_name             = "${azurerm_resource_group.vnetadmin_rg.name}"
  randominstance                  = "${random_integer.instance.result}"
  storage_account_file_share_name = "${var.storage_account_fileshare_name_hosting}"
  # storage_account_name            = "${var.storage_account_name_octanconfig}"

  storage_account_blob_share_name = "${var.storage_account_blob_name_hosting}"
  hosting_configuration_zip_file  = "${var.hosting_configuration_zip_file}"

  hosting_source_ansible = "${var.hosting_source_ansible}"
}


//********************************************************************************
//                               Hosting  vnet                                   //
//********************************************************************************
# create vnet HOSTING
module "hostingvnet" {
  source = "modules/hosting/00_vnet_hosting"

  prefix_vnet = "${var.prefix_hosting_vnet}"
  prefix_mid  = "${var.prefix_hosting_mid}"
  prefix_low  = "${var.prefix_hosting_low}"
  location    = "${var.location}"

  resource_group_name_vnet = "${azurerm_resource_group.vnethosting_rg.name}"
  resource_group_name_mid  = "${azurerm_resource_group.mid_rg.name}"
  resource_group_name_low  = "${azurerm_resource_group.low_rg.name}"
}


//********************************************************************************
//                         admin   vnet                                        //
//********************************************************************************
# Create administrtion ressource
module "adminvnet" {
  source = "modules/admin/00_vnet_admin"

  prefix_vnet              = "${var.prefix_admin_vnet}"
  prefix_admin1            = "${var.prefix_admin_admin1}"
  location                 = "${var.location}"
  resource_group_name_vnet = "${azurerm_resource_group.vnetadmin_rg.name}"
}


//********************************************************************************
//                         vnet peerig admin <--> Hosting                       //
//********************************************************************************
# Create peering between ADMIN zone with Hosting zone
module "vnetpeering-admin-hosting" {
  source = "modules/peer-admin-hosting"

  vnet_hosting_name = "${module.hostingvnet.vnet_name}"
  vnet_admin_name   = "${module.adminvnet.vnet_name}"

  resource_group_name_admin   = "${azurerm_resource_group.vnetadmin_rg.name}"
  resource_group_name_hosting = "${azurerm_resource_group.vnethosting_rg.name}"

  vnet_admin_id   = "${module.adminvnet.admin_vnet_id}"
  vnet_hosting_id = "${module.hostingvnet.hosting_vnet_id}"
}


#create VMs MID
module "midvm" {
  source         = "modules/hosting/02_zone_filtred_mid/01_zone_filtred_mid_waf"
  randominstance = "${random_integer.instance.result}"
  subnet_id      = "${module.hostingvnet.subnet_mid_id}"
  prefix_mid     = "${var.prefix_hosting_mid}"
  location       = "${var.location}"
  resource_group = "${azurerm_resource_group.mid_rg.name}"

  dns_name       = "${var.dns_name_vmmid}${random_integer.instance.result}"
  lb_ip_dns_name = "${var.lb_ip_dns_name_vmmid}${random_integer.instance.result}"

  pub_key_waf    = "${var.pub_key_waf}"
  admin_username = "${var.admin_username_waf}"
  admin_password = "${var.admin_password_waf}"
  ssh_port       = "${var.ssh_port_waf}"

  stack                                = "${var.stack}"
  azure_logs_loganalytics_workspaceid  = "${var.azure_logs_loganalytics_workspaceid}"
  azure_logs_loganalytics_workspacekey = "${var.azure_logs_loganalytics_workspacekey}"

}


#create VMs LOW
module "lowvm" {
  source = "modules/hosting/03_zone_private_low/01_zone_private_low_fw"

  randominstance = "${random_integer.instance.result}"
  subnet_id      = "${module.hostingvnet.subnet_low_id}"
  prefix_low     = "${var.prefix_hosting_low}"
  location       = "${var.location}"
  resource_group = "${azurerm_resource_group.low_rg.name}"

  dns_name       = "${var.dns_name_vmfw}"
  lb_ip_dns_name = "${var.lb_ip_dns_name_vmfw}"

  pub_key_fw     = "${var.pub_key_fw}"
  admin_username = "${var.admin_username_fw}"
  admin_password = "${var.admin_password_fw}"
  ssh_port       = "${var.ssh_port_fw}"

  stack = "${var.stack}"

  azure_logs_loganalytics_workspaceid  = "${var.azure_logs_loganalytics_workspaceid}"
  azure_logs_loganalytics_workspacekey = "${var.azure_logs_loganalytics_workspacekey}"

}

//********************************************************************************
//                                    admin  VMS                               //
//********************************************************************************

#create VMs admin and share file
module "adminvm" {
  source         = "modules/admin/02_zone_admin"
  randominstance = "${random_integer.instance.result}"
  subnet_id      = "${module.adminvnet.subnet_up_id}"
  prefix_admin   = "${var.prefix_admin_admin1}"
  location       = "${var.location}"
  resource_group = "${azurerm_resource_group.vnetadmin_rg.name}"
  pub_key_admin  = "${var.pub_key_admin}"

  hosting_configuration_zip_file = "${var.hosting_configuration_zip_file}"

  // file share name
  storage_account_fileshare_name = "${var.storage_account_fileshare_name_hosting}"

  storage_account_blob_name = "${var.storage_account_blob_name_hosting}"

  //blob share name  and deped on
  hosting_configuration_blob_endpoint = "${module.fileshare.blob_endpoint}"

  //file share name and depend on

  access_key1_storage_account_fileshare = "${module.fileshare.access_key1_storage_account_fileshare}"
  # data cloud init
  dns_name        = "${var.dns_name_vmadmin}"
  lb_ip_dns_name  = "${var.lb_ip_dns_name_vmadmin}"
  pub_key_haproxy = "${var.pub_key_haproxy}"

  admin_username_haproxy  = "${var.admin_username_haproxy}"
  ssh_port_haproxy        = "${var.admin_username_haproxy}"
  admin_password_haproxy  = "${var.admin_password_haproxy}"
  vm_ip_addresses_haproxy = ""
  # vm_ip_addresses_haproxy = "${module.upvm.vmups_ip_address}"
  private_key_haproxy = "${file("${path.module}\\..\\Conf\\variables\\private_key_haproxy")}"
  # depend on
  depend_on_hosting_vm                 = "${module.midvm.vm_fqdn}"
  depend_on_vmmids_id                  = "${module.midvm.vmmids_id}"
  depend_on_vnet_peering_admin_hosting = "${module.vnetpeering-admin-hosting.admin-hosting-id}"
  depend_on_vnet_peering_hosting_admin = "${module.vnetpeering-admin-hosting.hosting-admin-id}"
  copyhostingshell                     = "${module.fileshare.copyhostingshell}"

  admin_username_admin = "${var.admin_username_admin}"
  admin_password_admin = "${var.admin_password_admin}"

  environment     = "${var.environment}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  stack           = "${var.stack}"


  clb_up_mid_dns_name  = "${module.midvm.clb_up_mid_dns_name}"
  clb_mid_low_dns_name = "${module.lowvm.clb_mid_low_dns_name}"

  azure_logs_loganalytics_workspaceid  = "${var.azure_logs_loganalytics_workspaceid}"
  azure_logs_loganalytics_workspacekey = "${var.azure_logs_loganalytics_workspacekey}"
}

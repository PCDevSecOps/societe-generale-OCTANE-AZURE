variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default = "adminhosting"
}

variable "resource_group" {
}

variable "prefix_variable" {
    default = "c"

}

variable "vmadmincount" {
   default = "1"
}

variable "randominstance" {
  
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
}

variable "lb_ip_dns_name" {
  description = "DNS for Load Balancer IP"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1ms"
}


//Offer          Publisher               Sku
//-------------  ----------------------  ------------------
//CentOS         OpenLogic               7.5


variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "7-CI"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username_admin" {
  description = "administrator user name"
//  default     = "cloud-user"
}


variable "admin_password_admin" {
  description = "administrator password (recommended to disable password auth)"
//  default = "Password1234!"
}

variable "pub_key_admin" {

}
variable "ssh_port" {
  default     = 50001
}

variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default = "scripts/configuration_admin.sh"
}

variable "subnet_id" {
  description = "VM name referenced also in storage-related names."
}

variable "prefix_admin" {
}



//////////////////////////////////////////////////
// cloud init
variable "access_key1_storage_account_fileshare" {}

variable "storage_account_fileshare_name" {}

variable "storage_account_blob_name" {}

variable "hosting_configuration_zip_file" {}

variable "admin_username_haproxy" {}

variable "admin_password_haproxy" {}

variable "ssh_port_haproxy" {}

variable "vm_ip_addresses_haproxy" {
}

variable "private_key_haproxy" {}

variable "pub_key_haproxy" {}

variable "clb_up_mid_dns_name" {}

variable "clb_mid_low_dns_name" {}


variable "hosting_configuration_blob_endpoint" {}

variable "depend_on_hosting_vm" {}

variable "copyhostingshell" {}

variable "depend_on_vnet_peering_admin_hosting" {}

variable "depend_on_vnet_peering_hosting_admin" {}

variable "depend_on_vmmids_id" {}

variable "environment" {
  type = "string"
}

variable "stack" {
  type = "string"
}




//////////////////////////////////////////////////////////////////////
# azure rm provider parameters
variable "subscription_id" {
  type = "string"
}
# azure rm provider parameters
variable "client_id" {
  type = "string"
}
# azure rm provider parameters
variable "client_secret" {
  type = "string"
}
# azure rm provider parameters
variable "tenant_id" {
  type = "string"
}

variable "azure_logs_loganalytics_workspaceid" {
  description = "azure logs log analytics variables"
}
variable "azure_logs_loganalytics_workspacekey" {
  description = "azure logs log analytics variables"
}

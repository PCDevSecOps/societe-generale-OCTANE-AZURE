variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default     = "waf"
}

variable "resource_group" {}

variable "prefix_variable" {
  default = "c"
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make waf the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
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

variable "admin_username" {
  description = "administrator user name"
}

variable "ssh_port" {}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
}

variable "pub_key_waf" {}

variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."

  default = "scripts/configuration_waf.sh"
}

variable "subnet_id" {
  description = "VM name referenced also in storage-related names."
}

variable "prefix_mid" {

}

variable "randominstance" {
}
variable "stack" {}

variable "azure_logs_loganalytics_workspaceid" {
  description = "azure logs log analytics variables"
}
variable "azure_logs_loganalytics_workspacekey" {
  description = "azure logs log analytics variables"
}

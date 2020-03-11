variable "stack" {}

# prefix vnet
variable "prefix_admin_vnet" {
  type    = "string"
  default = "admin"
}

# prefix for subnet admin
variable "prefix_admin_admin1" {
  type    = "string"
  default = "admin1"
}

# prefix for vnet hosting
variable "prefix_hosting_vnet" {
  type    = "string"
  default = "hosting"
}

# prefix for subnet "UP" zone
variable "prefix_hosting_up" {
  type    = "string"
  default = "up"
}

# prefix for subnet "MID" zone
variable "prefix_hosting_mid" {
  type    = "string"
  default = "mid"
}

# prefix for subnet "LOW" zone
variable "prefix_hosting_low" {
  type    = "string"
  default = "low"
}

variable "location" {
  description = "The location/region where ressource are created. Changing this forces a new resource to be created."
  default     = "northeurope"
}



//////////////////////////////////////////////////////////////////////
#variable "clb_up_mid_dns_name" { }
//////////////////////////////////////////////////////////////////////
// file share parameters
variable "storage_account_name_octanconfig" {
  default     = "hostingconfigurationsa"
}

variable "storage_account_fileshare_name_hosting" {
  default     = "hostingconfigurationfs"
}

variable "storage_account_blob_name_hosting" {
  default     = "hostingconfigurationbl"
}

variable "hosting_configuration_zip_file" {
  default     = "ansible.zip"
}


variable "hosting_source_ansible" {
  default     = "ansible"
}

// tempo
variable "primaryStorageAccountKey" {
  default     = ""
}


//////////////////////////////////////////////////////////////////////
// vmup
variable "dns_name_vmup" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "mbvmup"
}

variable "lb_ip_dns_name_vmup" {
  description = "DNS for Load Balancer IP"
  default = "mbvmup"
}

variable "pub_key_haproxy" {
}


variable "admin_username_haproxy" {
  description = "administrator user name"
  default     = "cloud-user"
}

variable "ssh_port_haproxy" {
  default     = 50001
}

variable "admin_password_haproxy" {
  description = "administrator password (recommended to disable password auth)"
  default = "Password1234!"
}



//////////////////////////////////////////////////////////////////////
// vm mid
variable "dns_name_vmmid" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "azurecoemb"
}

variable "lb_ip_dns_name_vmmid" {
  description = "DNS for Load Balancer IP"
  default = "azurecoemb"
}

variable "pub_key_waf" {
}

variable "admin_username_waf" {
  description = "administrator user name"
  default     = "cloud-user"
}

variable "ssh_port_waf" {
  default     = 50001
}

variable "admin_password_waf" {
  description = "administrator password (recommended to disable password auth)"
  default = "Password1234!"
}


//////////////////////////////////////////////////////////////////////
// vm low
variable "dns_name_vmfw" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "mbvmlow"
}

variable "lb_ip_dns_name_vmfw" {
  description = "DNS for Load Balancer IP"
  default = "mbvmlow"
}

variable "pub_key_fw" {
}
variable "admin_username_fw" {
  description = "administrator user name"
  default     = "cloud-user"
}

variable "ssh_port_fw" {
  default     = 50001
}

variable "admin_password_fw" {
  description = "administrator password (recommended to disable password auth)"
  default = "Password1234!"
}


//////////////////////////////////////////////////////////////////////
// vmadmin
variable "dns_name_vmadmin" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "yfvmadmin"
}

variable "lb_ip_dns_name_vmadmin" {
  description = "DNS for Load Balancer IP"
  default = "yfvmadmin"
}

variable "pub_key_admin" {
}

variable "admin_username_admin" {
  description = "administrator user name"
  default     = "cloud-user"
}

variable "admin_password_admin" {
  description = "administrator password (recommended to disable password auth)"
  default = "Password1234!"
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

//////////////////////////////////////////////////////////////////////

variable "environment" {
  type = "string"
}

variable "azure_logs_loganalytics_workspaceid" {
  description = "azure logs log analytics variables"
}
variable "azure_logs_loganalytics_workspacekey" {
  description = "azure logs log analytics variables"
}




//////////////////////////////////////////////////////////////////////
/// backend  terraform hosting

variable "location" {
  description = "The location/region where ressource are created. Changing this forces a new resource to be created."
  default     = "northeurope"
}

# resource group where to store storage account
variable "resource_group_name" {

}

# Storage account name
variable "storage_account_name1" {
  default = "iaphostconfig"
}

# file share name
variable "storage_account_file_share_name" {
}

variable "randominstance" {
  
}

# file share name
variable "storage_account_blob_share_name" {
}


variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "hosting_configuration_zip_file" {
}



variable "hosting_source_ansible" {

}


variable "saccountname" {
  default = "hostingconfigurationsa"
}

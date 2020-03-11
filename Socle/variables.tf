
//////////////////////////////////////////////////////////////////////
/// Socle  terraform hosting

variable "location" {
  description = "The location/region where ressource are created. Changing this forces a new resource to be created."
  default     = "northeurope"
}


variable "resource_group_name" {
  default     = "referential-rg"
}

variable "storage_account_name" {
  default     = "vhostingbackendterraform"
}

variable "container_name" {
  type = "string"
  default = "tfstate"
}

variable "subscription_id" {
  type = "string"
}

variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "tenant_id" {
  type = "string"
}

variable "environment" {
  type = "string"
}


variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "hosting-vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "192.168.0.0/23"
}


variable "subnet_mid" {
  description = "The address prefix to use for the subnet."
  default     = "192.168.0.0/25"
}


variable "subnet_low" {
  description = "The address prefix to use for the subnet."
  default     = "192.168.1.0/25"
}


 variable "resource_group_name_vnet" {
   type = "string"
  description = "The name of the resource group in which to create the ressouces up."

}


variable "resource_group_name_mid" {
  type = "string"
  description = "The name of the resource group in which to create  the ressouces mid."
}

variable "resource_group_name_low" {
  type = "string"
  description = "The name of the resource group in which to create the ressouces low."
}



variable "location" {
    type = "string"
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}


variable "prefix_vnet" {
  type = "string"
}


variable "prefix_mid" {
    type = "string"
}

variable "prefix_low" {
    type = "string"
}







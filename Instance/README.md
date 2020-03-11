# AZURE cIAP HOSTING  

## Presentation

---

There are six roles:

* common : common tasks
* lb : shunt streams based on rules
* waf : performs security tasks for HTTP/HTTPS streams
* fw : filter access 

The Terraform Script aims to build all needed components for Hosting stack.

## Usage

---

Powershell Scripts are provided to prepare and launch terraform .

### Terraform variables

This file is the barebone for the cIAP Hosting infrastructure deployment. 

You must customize the variables section on both *admin* and *Hosting* Modules, all resources are based upon it.

```
variable "address_space" {
    description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
    default     = "x.x.x.x/24"
}

variable "subnet_admin1" {
    description = "The address prefix to use for the subnet."
    default     = "x.x.x.x/24"
}
```
---

```
variable "address_space" {
    description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
    default     = "x.x.x.x/23"
}

variable "subnet_mid" {
    description = "The address prefix to use for the subnet."
    default     = "x.x.x.x/25"
}

variable "subnet_low" {
    description = "The address prefix to use for the subnet."
    default     = "x.x.x.x/25"
}
```

---

Refer to install section form ore Details

---


# Instance Tree

```
Azure cIAP HOSTING Instance

├─ Conf
│  ├─ config.instance.template.json
│  ├─ libs
│  │  └─ retryblock.psm1
│  ├─ privatekeys
│  ├─ samples
│  │  ├─ error.sample.log
│  │  └─ sample.log
│  └─ variables
│     └─ backend.tfvars
├─ Initialize-AzureCIAPHosting.ps1
├─ Instance
│  ├─ main.tf
│  ├─ modules
│  │  ├─ admin
│  │  │  ├─ 00_vnet_admin
│  │  │  │  ├─ main.tf
│  │  │  │  ├─ outputs.tf
│  │  │  │  └─ variables.tf
│  │  │  ├─ 01_fileshare
│  │  │  │  ├─ main.tf
│  │  │  │  ├─ outputs.tf
│  │  │  │  ├─ scripts
│  │  │  │  │  └─ copyfile_to_blob.ps1
│  │  │  │  └─ variables.tf
│  │  │  └─ 02_zone_admin
│  │  │     ├─ data.tf
│  │  │     ├─ main.tf
│  │  │     ├─ outputs.tf
│  │  │     ├─ scripts
│  │  │     │  └─ configuration_admin.sh
│  │  │     └─ variables.tf
│  │  ├─ hosting
│  │  │  ├─ 00_vnet_octane
│  │  │  │  ├─ main.tf
│  │  │  │  ├─ outputs.tf
│  │  │  │  └─ variables.tf
│  │  │  ├─ 02_zone_filtred_mid
│  │  │  │  └─ 01_zone_filtred_mid_waf
│  │  │  │     ├─ data.tf
│  │  │  │     ├─ main.tf
│  │  │  │     ├─ outputs.tf
│  │  │  │     ├─ scripts
│  │  │  │     │  └─ configuration_waf.sh
│  │  │  │     └─ variables.tf
│  │  │  └─ 03_zone_private_low
│  │  │     └─ 01_zone_private_low_fw
│  │  │        ├─ data.tf
│  │  │        ├─ main.tf
│  │  │        ├─ outputs.tf
│  │  │        ├─ scripts
│  │  │        │  └─ configuration_fw.sh
│  │  │        └─ variables.tf
│  │  └─ peer-admin-octane
│  │     ├─ main.tf
│  │     ├─ outputs.tf
│  │     └─ variables.tf
│  ├─ outputs.tf
│  ├─ privatekeys
│  ├─ README.md
│  └─ variables.tf
├─ New-AzureCIAPHosting.ps1
└─ Remove-AzureCIAPHosting.ps1

```
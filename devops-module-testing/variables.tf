variable "application_acronym" {
  type = string
  description = "The acronym for the application or project.  This should be limited to no more that 5 characters.  For example, `ABCD`, `MSFT`, or `TSLA`."
}

variable "availability_set_id" {
  default = null
  type    = string
  description = "Specifies the ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created."
}

variable "auto_upgrade_minor_version" {
  default = false
  type    = bool
  description = "Specifies if the platform deploys the latest minor version update to the type_handler_version specified."
}

variable "admin_username" {
  default = "vmadmin01"
  type    = string
  description = "The admin username on the machine."
}

variable "admin_password" {
  type = string
  description = "The admin password to be used on the virtual machine.  This is a sensitive value and should come directly from a key vault."
  sensitive = true
}

variable "count_value" {
  default = 1
  type = number
  description = "The number of virtual machines to create.  For example, `2`."
}

variable "data_disk_size" {
  default = [200]
  type = list(number)
  description = "The size of the data disks to be created.  For example, `[200]`."
}

variable "data_disk_count" {
  default = 0
  type    = number
  description = "The number of data disks to create."
}

variable "enforce_vm_naming_convention" {
  default = true
  type    = bool
  description = "To be removed"
}

variable "ip_configuration_name" {
  default = ""
  type    = string
  description = "To be removed"
}

variable "network_interface_card_name" {
  default = ""
  type    = string
  description = "To be removed"
}

variable "offer" {
  default = "WindowsServer"
  type    = string
  description = "Specifies the offer of the image used to create the virtual machines."
}

variable "os_disk_override" {
  default = {
    storage_account_type = "Standard_LRS"
    os_disk_size         = "200"
  }
  type = map(string)
  description = "An override that allows you to specify a custom storage account type and os disk size."
}

variable "os_type_letter" {
  default = "W"
  type    = string
  description = "To be removed and refactored"
}
variable "publisher" {
  default = "MicrosoftWindowsServer"
  type    = string
  description = "Specifies the Publisher of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created."
}

variable "project_name" {
  type = string
  description = "The name of the project."
}

variable "resource_group_name" {
  type = string
  description = "The resource group that the virtual machine will be deployed into."
}

variable "resource_group_location" {
  default = "eastus"
  type = string
  description = "The location of the resource group that the virtual machine will be deployed in."
}

variable "subnet_id" {
  type = string
  description = "The subnet where the virtual machine will be deployed."
}

variable "storage_uri" {
  type = string
  description = "The primary blob endpoint to use for the storage account."
}

variable "sku" {
  default = "2016-Datacenter"
  type    = string
  description = "Specifies the SKU of the image used to create the virtual machines."
}
variable "storage_os_disk" {
  default = ""
  type    = string
  description = "To be removed"
}

variable "template_file" {
  type = string
  description = "The file used for configuring the custom script extension."
}

variable "tags" {
  type = map(string)
  description = "A map of strings used to add tags during the deployment."
}

variable "user_assigned_identity" {
  default = null
  type = object(
    {
      type         = string
      identity_ids = list(string)
    }
  )
  description = "A map of user assigned identities to be created."
}

variable "vm_region" {
  default = "use"
  type    = string
  description = "The acronym for the region where the vm is to be deployed.  For example, `use`, `wus`, or `use2`."
}

variable "vm_workload_desc" {
  default = "bld"
  type = string
  description = "An acronym for the machine purpose.  For example, `wk` for a workstation or `sql` for a self-hosted SQL server on Windows"
}

variable "vm_environment" {
  type = string
  description = "The acronym for the deployment environment.  This should be `dv`, `qa`, `ut`, `st`, or `pd`."
}

variable "virtual_machine_name" {
  default = ""
  type    = string
  description = "To be removed"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
  type = string
  description = "The size of the virtual machine to be created.  For example, `Standard_D2s_v3`."
}

variable "vm_name_suffix" {
  default = ""
  type    = string
  description = "To be removed"
}

variable "vm_image_version" {
  default = "latest"
  type    = string
  description = "The image version of the virtual machine."
}

variable "enable_automatic_updates" {
  default = false
  type    = bool
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created."
}

variable "patch_mode" {
  default = "AutomaticByOS"
  type    = string
  description = "Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform."
}

variable "data_disk_storage_account_type" {
  default = "Standard_LRS"
  type    = string
  description = "The data disk sku to use fo the vm."
}

variable "timezone" {
  default = "US Eastern Standard Time"
  type    = string
  description = "Specifies the Time Zone which should be used by the Virtual Machine."
}
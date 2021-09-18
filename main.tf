resource "azurerm_network_interface" "network_interface_card" {
  count = var.count_value

  name                = var.enforce_vm_naming_convention == true ? "VM${upper(var.vm_region)}${upper(var.project_name)}${upper(var.vm_workload_desc)}${count.index + 1}${upper(var.vm_environment)}-NIC${count.index + 1}" : (var.network_interface_card_name == "" ? "UEMC${upper(var.application_acronym)}${upper(var.project_name)}${count.index + 1}${upper(var.vm_environment)}${var.vm_name_suffix}-nic" : var.network_interface_card_name) #USE THIS VARIABLE
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  ip_configuration {
    #name                          = "UEMC${var.application_acronym}${var.application_name}${count.index+1}${var.vm_environment}-config"
    name                          = var.enforce_vm_naming_convention == true ? "VM${var.vm_region}${var.project_name}${var.vm_workload_desc}${count.index + 1}${var.vm_environment}-NIC${count.index + 1}-config" : (var.ip_configuration_name == "" ? "UEMC${var.application_acronym}${var.project_name}${count.index + 1}${var.vm_environment}${var.vm_name_suffix}-config" : var.ip_configuration_name) #USE THIS VARIABLE"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "virtual_machine" {
  count = var.count_value

  name                  = var.enforce_vm_naming_convention == true ? "VM${upper(var.os_type_letter)}${upper(var.vm_region)}${upper(var.project_name)}${upper(var.vm_workload_desc)}${count.index + 1}${upper(var.vm_environment)}" : (var.virtual_machine_name == "" ? "UEMC${upper(var.application_acronym)}${upper(var.project_name)}${count.index + 1}${upper(var.vm_environment)}${var.vm_name_suffix}" : var.virtual_machine_name) #USE THIS VARIABLE"
  computer_name         = var.enforce_vm_naming_convention == true ? "VM${var.vm_region}${var.project_name}${var.vm_workload_desc}${count.index + 1}${var.vm_environment}" : (var.virtual_machine_name == "" ? "UEMC${var.application_acronym}${var.project_name}${count.index + 1}${var.vm_environment}${var.vm_name_suffix}" : var.virtual_machine_name)                                                                              #USE THIS VARIABLE"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [element(azurerm_network_interface.network_interface_card.*.id, count.index)]
  size                  = var.vm_size
  availability_set_id   = var.availability_set_id
  admin_username        = var.enforce_vm_naming_convention == true ? "VM${var.vm_region}${var.project_name}${var.vm_workload_desc}${count.index + 1}${var.vm_environment}ADMIN" : (var.admin_username == "" ? lower("${var.application_acronym}${var.project_name}${count.index + 1}${var.vm_environment}${var.vm_name_suffix}admin") : "${var.admin_username}") #USE THIS VARIABLE
  admin_password        = var.admin_password
  license_type          = "Windows_Server"
  boot_diagnostics { storage_account_uri = var.storage_uri }
  provision_vm_agent       = true
  enable_automatic_updates = var.enable_automatic_updates
  patch_mode               = var.patch_mode
  timezone                 = var.timezone

  tags = var.tags


  lifecycle {
    prevent_destroy = false
  }
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.vm_image_version
  }
  dynamic "os_disk" {
    for_each = var.os_disk_override == null ? [] : tolist([var.os_disk_override])
    content {
      name                 = var.enforce_vm_naming_convention == true ? "VM${var.vm_region}${var.project_name}${var.vm_workload_desc}${count.index + 1}${var.vm_environment}_OS_Disk" : (var.storage_os_disk == "" ? "UEMC${var.application_acronym}${var.project_name}${count.index + 1}${var.vm_environment}${var.vm_name_suffix}_OSDisk" : var.storage_os_disk) #USE THIS VARIABLE"
      caching              = "ReadWrite"
      storage_account_type = var.os_disk_override.storage_account_type
      disk_size_gb         = var.os_disk_override.os_disk_size
    }
  }
  dynamic "identity" {
    for_each = var.user_assigned_identity == null ? [] : tolist([var.user_assigned_identity])
    content {
      type         = var.user_assigned_identity.type
      identity_ids = var.user_assigned_identity.identity_ids
    }
  }

}

resource "azurerm_managed_disk" "data_disk" {
  count = var.count_value == 0 ? 0 : var.count_value * var.data_disk_count

  name                 = var.enforce_vm_naming_convention == true ? "VM${var.vm_region}${var.project_name}${var.vm_workload_desc}${ceil((count.index + 1) / (var.data_disk_count * 1.0))}${var.vm_environment}_DataDisk_${(count.index % var.data_disk_count) + 1}" : (var.virtual_machine_name == "" ? "UEMC${upper(var.application_acronym)}${upper(var.project_name)}${count.index + 1}${upper(var.vm_environment)}${var.vm_name_suffix}" : var.virtual_machine_name) #USE THIS VARIABLE"
  resource_group_name  = var.resource_group_name
  location             = var.resource_group_location
  storage_account_type = var.data_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = element(var.data_disk_size, count.index % var.data_disk_count)

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  count = var.count_value == 0 ? 0 : var.count_value * var.data_disk_count

  virtual_machine_id = element(azurerm_windows_virtual_machine.virtual_machine.*.id, ceil((count.index + 1) * 1.0 / var.data_disk_count) - 1)
  managed_disk_id    = element(azurerm_managed_disk.data_disk.*.id, count.index)
  lun                = count.index % var.data_disk_count
  caching            = "ReadOnly"
  create_option      = "Attach"
}


resource "azurerm_virtual_machine_extension" "custom_ext_win_vm" {
  count = var.count_value

  name                       = "CustomScriptExtension"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.virtual_machine.*.id, count.index)
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = var.auto_upgrade_minor_version
  settings                   = <<SETTINGS
    {
      "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(var.template_file)}')) | Out-File -filepath win_initialise_data_disk.ps1\" && powershell -ExecutionPolicy Unrestricted -File win_initialise_data_disk.ps1"
    }
SETTINGS

  tags = var.tags
}

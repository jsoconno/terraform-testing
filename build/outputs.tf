output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "vm_name" {
  value = module.windows_vm.vm_name[0]
}

output "license_type" {
  value = module.windows_vm.license_type[0]
}
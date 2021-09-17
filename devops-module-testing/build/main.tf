resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "test" {
    name = "RGP-USE-TEST-DV"
    location = "eastus"

    tags = var.tags
}

module "windows_vm" {
  source                     = "../"

  count_value = 1

  vm_region                  = "USE"
  project_name               = "TEST"
  application_acronym        = "TEST"
  vm_workload_desc           = "SRV"
  vm_environment             = "DV"

  resource_group_name        = azurerm_resource_group.test.name
  resource_group_location    = azurerm_resource_group.test.location

  subnet_id                  = data.azurerm_subnet.test.id

  availability_set_id        = null

  data_disk_count            = 2
  vm_size                    = "Standard_D2s_v3"

  storage_uri                = data.azurerm_storage_account.test.primary_blob_endpoint

  data_disk_size             = [200]
  data_disk_storage_account_type = "Premium_LRS"
  
  template_file              = data.template_file.ps1.rendered

  admin_password             = random_password.password.result

  tags                       = var.tags
}
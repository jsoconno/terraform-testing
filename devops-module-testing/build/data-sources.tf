# Key Vault
data "azurerm_key_vault" "test" {
  name                = "your-key-vault"
  resource_group_name = "RGP-SAMPLE"
}

# Storage Account
data "azurerm_storage_account" "test" {
  name                = "yourstorageaccount"
  resource_group_name = "RGP-SAMPLE"
}

# Subnet
data "azurerm_subnet" "test" {
  name                 = "your-subnet"
  virtual_network_name = "your-vnet"
  resource_group_name  = "RGP-SAMPLE"
}

# Files
data "template_file" "ps1" {
  template = "${file("win_initialise_data_disk.ps1")}"
}

# data "template_file" "xml" {
#   template = "${file("windows-config.xml.tpl")}"
# }

data "azurerm_client_config" "current" {
}
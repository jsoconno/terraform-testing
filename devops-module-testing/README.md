# Windows VM Module
A Terraform module that creates `n` number of virtual machines, network interface cards, and data disks.  It also enables the custom script extension on the virtual machine.

## Author
jsoconno@gmail.com

## Usage

You can refrence the [config](config/main.tf) file in this repositiory for an example of how to use this module.  In general, you can reference this module using its pinned version from the repository as shown below.

```Terraform
module "windows_vm" {
    source = "git::https://dev.azure.com/your-org/your-project/_git/terraform-module-windows-vm?ref=v1.0.5"

    count = 1 # Make this whatever number you like

    ### Add all attributes here ###
}
```

## Input Variables and Outputs
Inputs and outputs to this module can be determined by looking at the defintions in the `variables.tf` and `outputs.tf` files.

Where possible, it is a good idea to reference resources directly when passing values to the module for inputs.  For example, `azurerm_resource_group.example.name` to get the resource group name or `azurerm_subnet.example.id` to get the subnet id.  

All sensitive values should come from Azure Key Vault as part of pipeline exeuction.
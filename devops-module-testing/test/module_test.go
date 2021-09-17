package test

import (
	"os"
	"testing"
	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/azure"
)

func TestTerraformModule(t *testing.T) {

	// The client secret must be set to this value to use the Azure DevOps pipeline task environment variables
	clientSecret := os.Getenv("servicePrincipalKey")

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options {

		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../build",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"client_secret": clientSecret,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables.
	subscriptionID := terraform.Output(t, terraformOptions, "subscription_id")
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	virtualMachineName := terraform.Output(t, terraformOptions, "vm_name")
	licenseType := terraform.Output(t, terraformOptions, "license_type")

	// Get the virtual machine object
	virtualMachine := azure.GetVirtualMachine(t, virtualMachineName, resourceGroupName, subscriptionID)

	t.Run("the virtual machine is created", func(t *testing.T) {
		// Check if the virtual machine exists.
		assert.True(t, azure.VirtualMachineExists(t, virtualMachineName, resourceGroupName, subscriptionID))

		// Check that the name matches what is expected
		assert.Equal(t, virtualMachineName, *virtualMachine.Name)
	})

	t.Run("the virtual machine license type is windows server", func(t *testing.T) {
		// Check that the license type matches what is expected
		assert.Equal(t, licenseType, *virtualMachine.LicenseType)
	})
}
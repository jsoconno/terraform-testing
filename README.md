# Terraform Testing Patterns

## Introduction

The purpose of this repository is to provide an example setup for how you can test your Terraform modules for code quality, security, and reliability with open source tools.

While this example uses Azure DevOps and a Terraform module example for Azure, the same principles, approaches, and structures can be used for any Terraform module on any cloud provider with some minor changes.  

## Assumptions
The steps outlined are assuming that:
* You are using a MacBook for local development
* You are using a self-hosted Windows agent with all of the required binaries in your PATH
* You are creating one repository per module (great for versioning)
* You have an Azure subscription
* You are using Azure DevOps
* You have a service connection configured in Azure DevOps with the appropriate access to the environment for infra deployment

## Dependencies

Below is the software you will need installed.  The commands provided are for setup for local development on a Mac.  Binaries will have to be collected and added to PATH for the Windows agent.  Relevant links to binary installers are provided where possible.

### Terraform
Terraform will serve as the platform for automating the creation of our infrastructure.  Version 1.0.0 or later is recommended.
#### Install
```
brew install tfenv
tfenv install latest
```
You can find more information on downloading Terraform [here](https://www.terraform.io/downloads.html).


### TFSec
TFSec will provide a configurable tool for security scanning.  Version 0.39.0 or later is recommended.
#### Install
```
brew install tfsec
```
You can find more information on TFSec [here](https://github.com/aquasecurity/tfsec).

You can also just download the binary file [here](https://github.com/aquasecurity/tfsec/releases).
### TFLint
TFLint will provide code quality checks.  Version 0.32.0 or later is recommended.
#### Install
```
brew install tflint
```
You can find more information on TFLint [here](https://github.com/terraform-linters/tflint).

You can also just download the binary file [here](https://github.com/terraform-linters/tflint/releases).

### Go
Golang will provide the runtime for running integration tests using the available Terratest modules.  Another utility called the `terratest_log_parser` will also be required for parsing Terratest output.
#### Install
```
brew install Go
```
Once it is installed, you will need to update your `.bash_profile` with the following:
```
export GOPATH=$HOME/go-workspace # don't forget to change your path correctly!
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
```
Next we need to install some dependencies that will be used with go for working with Terraform and Azure.
```
go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/gruntwork-io/terratest/modules/azure
```

You can find more information on installing Go [here](https://golang.org/doc/install).

You can also just download the binary file [here](https://golang.org/dl/).
### Terratest Log Parser
The terratest_log_parser utility will allow us parse logs generated when running Terratest tests.
#### Install
First we need to install the `gruntworks-install` command line tool.
```
curl -LsS https://raw.githubusercontent.com/gruntwork-io/gruntwork-installer/master/bootstrap-gruntwork-installer.sh | bash /dev/stdin --version v0.0.22
```
You then need to create a [GitHub access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) to install scripts and binaries from private GitHub repos and export it as an environment variable.
```
export GITHUB_OAUTH_TOKEN="(your secret token)"
```
And finally install the parser:
```
gruntwork-install --binary-name 'terratest_log_parser' --repo 'https://github.com/gruntwork-io/terratest' --tag 'v0.13.13'
```
You should be able to see that it installed by running `gruntwork-install`.  After this process, feel free to delete the access token.

If you struggled with this last part, me too.  You should check out the Terratest documentation for [Debugging interleaved test output](https://terratest.gruntwork.io/docs/testing-best-practices/debugging-interleaved-test-output/#installing-the-utility-binaries) and the [Github repo](https://github.com/gruntwork-io/terratest/blob/master/modules/logger/parser/parser.go).

You can also just download the binary file [here](https://github.com/gruntwork-io/terratest/releases).

## Azure Service Principal

The pipeline runs under the context of an Azure DevOps service connection.  To configure a service connection in Azure DevOps, you will need a service principal in Azure.  That service principal should be given RBAC permissions to the scope where you plan on deploying and the following API permissions:

* **Azure Active Directory Graph**
  * Application.ReadWrite.OwnedBy
  * Directory.ReadWrite.All
* **Microsoft Graph**
  * User.Read

The details about your tenant and service principal should be updated in the `build/terraform.tfvars` file.

## Repo Structure
Below is an overview of the structure of this repo.

```
module-root
│
├── build/
│   ├── .tfsec
│   ├── data-sources.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
│
├── pipeline/
│   └── azure-pipeline.yml
│
├── test/
│   ├── test_output/
│   │   └── *.xml
│   ├── go.mod
│   ├── go.sum
│   └── module_test.go
│
├── .gitignore
├── main.tf
├── outputs.tf
├── README.md
└── variables.tf
```
The repository `root` contains the files that you always have has part of your module definition including:

* A `main.tf` file where all data sources, resources, versions, and other details are maintained
* A `variables.tf` file that defines the inputs for your module as well as their defaults, types, and descriptions
* An `outputs.tf` file that contians the outputs that may be used by other pipelines and will be referenced when testing your module with Terratest
* A `documentation.md` file that contains all of the details about the module

The `build` folder contains all files used to create the desired module during your tests.  This includes any provider definitions, variable inputs or resource references required.

The `pipeline` folder contains the YAML pipeline that will be used for performing code linting, security scanning, and intergration testing.

The `test` folder contains all of the `.go` files required to run Terratest and test your module.  This includes the main package file `module_test.go` and its dependencies in `go.mod` and `go.sum` (which are created automatically).

This structure can be followed for any module repo to create a standard pattern for structuring your code.

## Running the Code Locally

Once you have the code on your computer and all dependencies installed, you can test that everything is working.

For security scanning with **TFSec**:
1. From root, navigate to the `build` folder with `cd build`
2. Run `terraform init` to initialize the module(s)
3. Run `tfsec . --tfvars-file terraform.tfvars --format JUnit > ../test/test_output/security_scan.xml` to output the security scan results as an XML file under `test/test_output/security_scan.xml`

For code quality results with **TFLint**:
1. From root, run `tflint --enable-rule=terraform_unused_declarations --enable-rule=terraform_naming_convention --enable-rule=terraform_deprecated_interpolation --enable-rule=terraform_comment_syntax --enable-rule=terraform_typed_variables --enable-rule=terraform_unused_required_providers --enable-rule=terraform_standard_module_structure --enable-rule=terraform_documented_variables --format junit`

For integration testing with **Terratest**:
1. From root, navigate to the `test` folder with `cd test`
2. Run `go mod init module_test` and `go mod tidy` to configure dependencies
3. Open the `module_test.go` file
4. Run `export servicePrincipalKey=your-spn-client-secret` to set the environment variable that will be used in the Go test
5. Run `go test -v -timeout 60m` to run the tests

## Running Code in the Pipeline

The `azure-pipelines.yml` file in the `pipeline` folder contains a YAML definition of the pipeline and is set up to run on a Windows self-hosted agent.

First create a new repo called `terraform-module-windows-vm`.  Then clone this code and put it in your repository.

Then, go to Azure DevOps Pipelines and select new pipeline following the prompts to set up a pipeline based on your Git repo.  Select the Azure pipelines file.

Now, you will need to update the YAML file with the name of your agent pool and service connection.  Everything else should work as is!

## Voila!

You now have a pipeline that can lint, security scan, and integration test your modules.  With some slight rework, this framework can also be used for testing entire projects.

## Some Other Things

You can add custom security scanning requirements by updating the `config.yml` and `module_tfchecks.yml` files under the `build/.tfsec/` folder.  More details on [custom checks](https://tfsec.dev/docs/custom-checks/) and [exclusions and overrides](https://tfsec.dev/docs/config/) can be found in their documentation.
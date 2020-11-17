![Terraform](https://github.com/18F/federalist-infra/workflows/Terraform/badge.svg)

# Federalist Infra
Terraform configuration for the Federalist platform.

# Requirements
To contain the blast radius of any changes, cloud.gov spaces and deployment credentials must be created prior to running Terraform, the credentials for a given environment should only have permissions to the target environments.

# Repository organization
This repository contains several [environments](#environments) each in their own folder as well as shared [modules](#modules) in the `modules` folder. Each environment is isolated from the others and corresponds to it's own [Terraform state](https://www.terraform.io/docs/state/index.html) file that lives in the configured [Terraform backend](https://www.terraform.io/docs/backends/index.html). All terraform commands should be run from within the directory of the desired environment.

# Getting started
- clone the repository: `git clone git@github.com:18F/federalist-infra.git`
- enter the repository directory: `cd federalist-infra`
- for each desired environment:
  - enter the environment directory: `cd terraform/<environment>`
  - create environment-specific credentials: create a copy of the desired environment's `.secrets.auto.tfvars.example` file named `.secrets.auto.tfvars` and populate with appropriate values
  - create an `aws-vault` profile with the appriopriate values for the [backend credentials](#backend-credentials)
  - initialize terraform: `aws-vault exec <your profile> -- terraform init`

For each environment configured above, you should be able run `terraform plan` to see the potential effects of any changes.

# Configuration
There are 2 sets of credentials needed to run Terraform commands for a desired environment: [backend credentials](#backend-credentials) and [environment-specific credentials](#environment-specific-credentials). The method by which these are provided may differ.

## Backend credentials
Every environment stores its [Terraform state](https://www.terraform.io/docs/state/index.html) file in a shared [Terraform S3 backend](https://www.terraform.io/docs/backends/types/s3.html). The credentials for the backend are always required and should be provided as environment variables without special prefixes. The required values are:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

## Environment-specific credentials
Each environment specifies the credentials it needs in the `variables.tf` file (Ex. [staging](https://github.com/18F/federalist-infra/blob/main/terraform/staging/variables.tf)). We provide these in different ways depending on the environment:

- In CI (Github Actions), they are provided as environment variables by prefacing the variable name with `TF_VAR_` (Ex. [Github action](https://github.com/18F/federalist-infra/blob/main/.github/workflows/terraform.yml#L22))
- Locally, they are provided by the `.secrets.auto.tfvars` file within each environment. This file should be created when initially getting started from the `.secrets.auto.tfvars.example` file in each environment.

See [Terraform variables](https://www.terraform.io/docs/configuration/variables.html) for more details on Terraform variables.

# Environments
## `global`
Contains global configuration that may be leveraged by any environment. This currently includes:
- the backend configuration
- ECR

## `staging`
Contains configuration relevant to the Federalist staging environment.

# Modules
## `queue`
Contains the configuration to create an AWS SQS instance and associated users/policies and a corresponding user-provided service in cloud.gov.

# Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
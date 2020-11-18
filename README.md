![Terraform](https://github.com/18F/federalist-infra/workflows/Terraform/badge.svg)

# Federalist Infra
Terraform configuration for the Federalist platform.

# Requirements
- [Terraform 0.13.2](https://www.terraform.io/downloads.html)
- [AWS Vault](https://github.com/99designs/aws-vault)
- Access to AWS credentials for each environment
- Access to cloud.gov credentials for each environment

Future goals:
- replace Terraform dependency with Docker
- add pre-commit hooks to validate, lint, scan, etc
- add Makefile to standardize commands

# General philosophy
## Credentials
To contain the blast radius of any changes, all credentials used or created by Terraform should only have the fewest permissions necessary within the target environments.

## Repository organization
This repository contains several [environments](#environments) each in their own folder as well as shared [modules](#modules) in the `modules` folder. Each environment is isolated from the others and corresponds to it's own [Terraform state](https://www.terraform.io/docs/state/index.html) file that lives in the configured [Terraform backend](https://www.terraform.io/docs/backends/index.html). All terraform commands should be run from within the directory of the desired environment.

## Deployment
Changes in the Terraform configuration are applied using [Github Actions](https://docs.github.com/en/free-pro-team@latest/actions) according to the [`terraform` workflow](https://github.com/18F/federalist-infra/blob/main/.github/workflows/terraform.yml). When a Github Pull Request is created agains the default branch (`main`), the `terraform` job is run for *each* environment with the results of the corresponding `terraform plan` added as a comment to the Pull Request. This output should be reviewed in detail before the Pull Request is approved, `terraform apply` is only run hen the Pull Request is merged to the default branch.

## Development
Modifying Terraform configuration can be tricky business because we can't fully test the changes before actually applying them and we want any changes to happen as part of the CI/CD pipeline. To mitigate the risks as much as we can, we will do the following for every change:
- Validate with `terraform validate` (enforced by CI)
- Format with `terraform format` (enforced by CI)
- Run `terraform plan` locally to inspect the potential changes (also run in CI)
- Thoroughly review Pull Requests
- (TODO) Lint with [TFLint](https://github.com/terraform-linters/tflint)
- (TODO) Security Scan with [TFSEC](https://github.com/tfsec/tfsec)

# Getting started
- clone the repository: `git clone git@github.com:18F/federalist-infra.git`
- enter the repository directory: `cd federalist-infra`
- for each desired environment:
  - enter the environment directory: `cd terraform/<environment>`
  - create environment-specific credentials: create a copy of the desired environment's `.secrets.auto.tfvars.example` file named `.secrets.auto.tfvars` and populate with appropriate values
  - create an `aws-vault` profile with the appriopriate values for the [backend credentials](#backend-credentials)
  - initialize terraform: `aws-vault exec --no-session <your profile> -- terraform init`

For each environment configured above, you should be able run `terraform plan` to see the potential effects of any changes.

# Details
## Configuration
There are 2 sets of credentials needed to run Terraform commands for a desired environment: [backend credentials](#backend-credentials) and [environment-specific credentials](#environment-specific-credentials). The method by which these are provided may differ.

### Backend credentials
Every environment stores its [Terraform state](https://www.terraform.io/docs/state/index.html) file in a shared [Terraform S3 backend](https://www.terraform.io/docs/backends/types/s3.html). The credentials for the backend are always required and should be provided as environment variables without special prefixes. The required values are:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

### Environment-specific credentials
Each environment specifies the credentials it needs in the `variables.tf` file (Ex. [staging](https://github.com/18F/federalist-infra/blob/main/terraform/staging/variables.tf)). We provide these in different ways depending on the environment:

- In CI (Github Actions), they are provided as environment variables by prefacing the variable name with `TF_VAR_` (Ex. [Github action](https://github.com/18F/federalist-infra/blob/main/.github/workflows/terraform.yml#L22))
- Locally, they are provided by the `.secrets.auto.tfvars` file within each environment. This file should be created when initially getting started from the `.secrets.auto.tfvars.example` file in each environment.

See [Terraform variables](https://www.terraform.io/docs/configuration/variables.html) for more details on Terraform variables.

## Environments
### `global`
Contains global configuration that may be leveraged by any environment.

Components:
- Terraform backend (AWS S3, AWS DynamoDB)
- Build container image repository (AWS ECR)

### `staging`
Contains configuration relevant to the Federalist staging environment.
Components:
- Build queue and credentials (AWS SQS, CF UPS)
- Monitoring and alerting (AWS Cloudwatch, AWS SNS)

Note: When creating this enviroment, the SNS subscription to send emails to `federalist-alerts@gsa.gov` must be created manually in the console as it is currently not supported by Terraform.

## Modules
### `queue`
Contains the configuration to create an AWS SQS instance and associated users/policies and a corresponding user-provided service in cloud.gov.

### `sns`
Contains the configuration to create an AWS SNS instance and associated users/policies.

# Contributing
Before commiting your changes, please sure the configuration and format is valid by running `terraform validate` and `terraform format`. In the future, pre-commit hooks will be added to ensure this happens automatically.

# Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
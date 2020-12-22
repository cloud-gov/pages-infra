![Terraform](https://github.com/18F/federalist-infra/workflows/Terraform/badge.svg)

# Federalist Infra
[Terraform](https://www.terraform.io/) configuration for the Federalist platform.

# Requirements
- [Terraform 0.13.2](https://www.terraform.io/downloads.html)
- Access to AWS, cloud.gov, and CircleCI credentials for each environment

Future goals:
- replace local Terraform dependency with Docker
- add pre-commit hooks to validate, lint, scan, etc
- add Makefile to standardize commands
- add auto-generated module documentation
- add automation around bootstrapping

# General philosophy
## Credentials
To contain the blast radius of any changes, all credentials used or created by Terraform should only have the fewest permissions necessary within the target environments.

## Repository organization
Groups of related configuration are organized into *root* and *shared* [Terraform modules](https://www.terraform.io/docs/configuration/blocks/modules/index.html), which are pretty much exactly like they sound. *Root* modules correspond to environments or other groups of configuration and are isolated from each other with distinct [Terraform state](https://www.terraform.io/docs/state/index.html) files while *shared* modules provide a way to re-use common configuration. When Terraform is run, it is always for a single *root* module.

### Root modules
- `backend`: Configures the [Terraform backend](https://www.terraform.io/docs/backends/index.html) ([Terraform S3 backend](https://www.terraform.io/docs/backends/types/s3.html)). Only run once, locally with MFA-protected admin credentials, when bootstrapping the entire repository. See ([Bootstrapping the backend](#bootstrapping-the-backend)).
- `bootstrap-env`: Bootstraps a new environment/AWS account. Only run once, locally with MFA-protected admin credentials, when adding a new environment/AWS account. See ([Bootstrapping environments](#bootstrapping-environments)).
- `staging`: Configures the staging environment
- `production`: Configures the production environment
### Shared modules
- `ecr`: AWS ECR instance for `federalist-garden-build` docker images
- `queue`: AWS SQS queue and associated AWS CloudWatch alarms
- `shared`: Common infrastructure configuration for all environments
- `sns`*: AWS SNS topic used for AWS CloudWatch alarms.

***Note: When first creating SNS resources, the subscription to send emails to `federalist-alerts@gsa.gov` must be created manually in the console as it is currently not supported by Terraform.**

## AWS Account Setup
While we want to simplify our configuration as much as possible and minimize the number of credentials, we have to work with the following constraints:

- Each Federalist environment may have resources in both AWS Commercial and AWS GovCloud
- Each Federalist environment requires isolated AWS accounts
- AWS cross-account permissions do not work between AWS Commercial and AWS GovCloud
- Best practice is to maintain "admin" accounts seperate from the accounts which contain the resources managed by Terraform
- Single Terraform backend

The result is that we have 3 AWS account-pairs:
- Admin
- Production
- Staging

each with a Commercial and GovCloud account and we only need 3 sets of credentials:
- Backend
- Commercial
- GovCloud

regardless of the number of environments. 

In the event that we wish to add another non-production environment, we will re-use the Staging environment, making sure to tag resources appropriately.

To achieve this we:

- Use a single Terraform backend that lives in the AWS Admin GovCloud account and is configured in `./terraform/backend` *root* module (see [Bootstrapping the backend](#bootstrapping-the-backend)). Credentials for the IAM user with access to this backend is required for every *root* module.

- configure a `terraform-user-role` in each environment account, with permissions to manage Terraform resources within the account and in each Admin account we configure a `terraform-user` with permissions to assume the specific role in each environment account for the same *platform* (Commercial/GovCloud) (see [Bootstrapping environments](#bootstrapping-environments)).

# Getting started
1. clone the repository: `git clone git@github.com:18F/federalist-infra.git`
2. enter the repository directory: `cd federalist-infra`
3. create the shared backend configuration by creating a copy of `./terraform/.backend-config.tfvars.example` named `./terraform/.backend-config.tfvars` and populating the credentials for the `terraform-backend` user in AWS Admin GovCloud
4. for each desired environment (`staging` or `production`):
    1. enter the environment directory: `cd terraform/<environment>`
    2. create environment-specific credentials by creating a copy of the desired environment's `.secrets.auto.tfvars.example` file named `.secrets.auto.tfvars` and populate with appropriate values
    3. initialize terraform: `terraform init -backend-config=../.backend-config.tfvars`

Within each environment, you should be able run `terraform plan` to see the potential effects of any changes.

# Development
Modifying Terraform configuration can be tricky business because we can't fully test the changes before actually applying them and we want any changes to happen as part of the CI/CD pipeline. To mitigate the risks as much as we can, we will do the following for every change:
1. Validate with `terraform validate` (enforced by CI)
2. Format with `terraform format` (enforced by CI)
3. Run `terraform plan` locally to inspect the potential changes (also run in CI)
4. Thoroughly review pull requests
5. (TODO) Lint with [TFLint](https://github.com/terraform-linters/tflint)
6. (TODO) Security Scan with [TFSEC](https://github.com/tfsec/tfsec)

# CI/CD
Changes in the Terraform configuration are applied using [Github Actions](https://docs.github.com/en/free-pro-team@latest/actions) according to the [`terraform` workflow](https://github.com/18F/federalist-infra/blob/main/.github/workflows/terraform.yml). When a Github pull request is created against the default branch (`main`), the `terraform` job is run for *each* configured environment (`staging`, `production`) with the results of the corresponding `terraform plan` added as a comment to the pull request. This output should be reviewed in detail before the pull request is approved. `terraform apply` is only run when the pull request is merged to the default branch.

Note: Only the `staging` and `production` *root* modules should be run in CI.

### Environment Variables
#### Terraform Backend
These credentials correspond to the `terraform-backend` user configured in the AWS Admin GovCloud account:
- `BACKEND_AWS_ACCESS_KEY_ID`
- `BACKEND_AWS_SECRET_ACCESS_KEY`
- `BACKEND_AWS_DEFAULT_REGION`

#### AWS
These credentials correspond to the `terraform-user` user configured in the specified platform AWS Admin account:
- `TF_VAR_aws_access_key_govcloud`
- `TF_VAR_aws_secret_key_govcloud`
- `TF_VAR_aws_access_key_commercial`
- `TF_VAR_aws_secret_key_commercial`

#### Cloud Foundry
These correspond to the space deployer credentials in each environment (`federalist-staging-deployer-circle`, `federalist-production-deployer-circle`):
- `CF_USER_STAGING`
- `CF_PASSWORD_STAGING`
- `CF_USER_PRODUCTION`
- `CF_PASSWORD_PRODUCTION`

#### CircleCI
CircleCI API Key
- `TF_VAR_circleci_api_key`

# Boostrapping
To ensure that we can use least-privilege credentials when provisioning resources with Terraform, it is necessary to have some bootstrapping steps that are run once with privileged credentials in a local environment.

### Bootstrapping the backend
This only needs to be done once, and only when starting completely from scratch. Since the Terraform configuration includes the resources user for storing the Terraform state, we must create the resources first using local state, then add the backend configuration which makes use of those resources. Terraform is smart enough to recognize when the backend configuration changes.

Requirements:
- Admin credentials for the AWS Admin GovCloud account

Working locally on your GSA machine, perform the following steps:
1. `cd terraform/backend`
2. ensure admin credentials are in environment (eg `aws-vault exec <your admin profile> bash`)
3. comment out the `backend` block in `./main.tf`
4. `terraform init`
5. `terraform plan`
6. verify the plan is correct
7. `terraform apply`
8. make note of the backend access key and secret in the outputs
9. create the backend config file as described in [Getting started](#getting-started) with the credentials from the previous step
10. uncomment the `backend` block in `./main.tf`
11. `terraform init -backend-config=../.backend-config.tfvars`
12. `terraform plan`
13. verify no changes need to be made
14. ensure `.backend-config.tfvars` will NOT be checked into version control

### Bootstrapping admin accounts
Each AWS Admin account must contain a dummy user with the ability to assume a role in a target account that will allow it manage Terraform resources. This allows the use of only one set of credentials for each platform (commercial, govcloud) and limits the required permissions.

Requirements:
- Console access to AWS Admin Commercial and GovCloud accounts

In the AWS Console for each platform
1. create a user named `terraform-user`
2. add the inline policy:
  ```
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resources": [<staging_role_arn>, <production_role_arn>, ...]
        }
    ]
  }
  ```
  where each `<role_arn>` corresponds to the assume role arn created when bootstrapping an environment. These can be added now if they are known, or they can be added as created later on. They will look like: `arn:aws-us-gov:iam::<account id>:role/terraform-user-role`.

### Bootstrapping environments
Before using Terraform to manage resources for a Federalist environment, we need to create a role with appropriate permissions in each AWS account associated with the environment. Since a Federalist environment may need to manage resources in both Commercial and GovCloud accounts AND accounts on different AWS platforms cannot interact, we must run this step for each one. In the steps below, `platform` refers to either `commercial` or `govcloud`. This only needs to be done once when creating an environment completely from scratch. 
 
Requirements:
- Admin credentials for the target AWS account
- Console access to AWS Admin account for the target platform
- The backend credentials file as described in [Getting started](#getting-started).

Working locally on your GSA machine, perform the following steps:
1. `cd terraform/bootstrap-env`
2. remove existing backend configuration with `rm -rf .terraform` 
3. ensure admin creds are in environment (eg `aws-vault exec <your admin profile> bash`)
4. `terraform init -backend-config=../.backend-config.tfvars -backend-config="key=bootstrap-staging-<platform>/terraform.tfstate"`
5. `terraform plan -var="aws_platform=<platform>"`
6. verify the plan is correct
7. `terraform apply -var="aws_platform=<platform>"`
8. make note of the outputted value for `assume_role_arn` (you will need this for 2 subsequent steps)
9. In the AWS Console for the AWS Admin account responsible for the target platform, add the outputted role arn to allowed resources in the trust policy for the `terraform-user`.
10. Create a new *root* module for the environment by copy/pasting an existing one, making sure to update all variables as appropriate including `aws_assume_role_arn_<platform>` outputted above

# Contributing
Before commiting your changes, please be sure the configuration and format is valid by running `terraform validate` and `terraform format`. In the future, pre-commit hooks will be added to ensure this happens automatically.

# Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.

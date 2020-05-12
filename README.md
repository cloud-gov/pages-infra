# Federalist Infra
Terraform configuration for the Federalist platform

# Requirements
To contain the blast radius of any changes, cloud.gov spaces and deployment credentials must be created prior to running Terraform, the credentials for a given environment should only have permissions to the target environments.

# Environment configuration

## Running locally
All variables and secrets should be provided in a `secrets.auto.tfvars` file within each target environment. The required values are described in the variables file for each environment, ex: [dev variables)](/dev/variables.tf).

## Running in CI
All variables and secrets should be provided as environment variables on the platform. The name of the environment variable is the name of the Terraform variable prefixed with `TF_VAR_`. Ex. `TF_VAR_uev_key` will be used as the value for the variable `uev_key`.

# Running
- Change directory into the appropriate environment: `cd dev`
- Create secrets if necessary in `./.secrets.auto.tfvars`
- Initialize terraform if necessary: `terraform init -backend-config=./.secrets.auto.tfvars`
- Run plan and confirm all changes: `terraform plan`
- Apply the changes: `terraform apply`

# Running locally
TBD

# Examples
## Creating a new environment

### Create a cloud.gov space
- Create a new space `cf create-space <space-name> -o gsa-18f-federalist`
- Target the new space: `cf target -s <space-name>`

### Create cloud.gov deployer credentials
- Create a deployer account for Terraform to use: `cf create-service cloud-gov-service-account space-deployer terraform-user`
- Create a service key for the deployer account: `cf create-service-key terraform-user terraform-user-key`
- View the credentials for later configuration: `cf service-key terraform-user terraform-user-key`

### Create an encryption key for user environment variables
This should be a cryptographically secure, random string. To generate one using `node`:
```
  node -e 'console.log(require("crypto").randomBytes(32).toString("hex"));'
```

### Create the Terraform
Create a new folder for the environment in this repo by using an existing one as a template, making sure to update the secrets to the values just generated.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
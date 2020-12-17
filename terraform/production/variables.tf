#
# Secrets/variables to be provided via environment variables or in `secrets.auto.tfvars.`
# When provided via environment variables, the names must be prefixed with `TF_VAR_`
# Ex. `TF_VAR_cf_user="foobarbaz"`
#

#
# AWS
#
variable "aws_access_key_govcloud" {
  type        = string
  description = "AWS GovCloud access key id"
}

variable "aws_secret_key_govcloud" {
  type        = string
  description = "AWS GovCloud secret access key"
}

variable "aws_region_govcloud" {
  type        = string
  description = "AWS GovCloud default region"
}

variable "aws_assume_role_arn_govcloud" {
  type        = string
  description = "ARN of AWS GovCloud terraform user role to assume."
}

# variable "aws_access_key_commercial" {
#   type        = string
#   description = "AWS Commercial access key id"
# }

# variable "aws_secret_key_commercial" {
#   type        = string
#   description = "AWS Commercial secret access key"
# }

# variable "aws_region_commercial" {
#   type        = string
#   description = "AWS Commercial default region"
# }

#
# CircleCI
#
variable "circleci_api_key" {
  type        = string
  description = "CircleCI API key"
}

#
# Cloud Foundry
#
variable "cf_user" {
  type        = string
  description = "cloud.gov deployer account user"
}

variable "cf_password" {
  type        = string
  description = "cloud.gov deployer account password"
}
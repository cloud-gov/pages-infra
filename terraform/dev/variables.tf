variable "cf_api_url" {
  type        = string
  description = "cloud.gov api url"
}

variable "org_name" {
  type        = string
  description = "cloud.gov organization name"
}

variable "env" {
  type        = string
  description = "cloud.gov environment name (ex: dev, staging,cf_api_url production)"
}

# Secrets to be provided via environment variables or in `secrets.auto.tfvars.`
# When provided via environment variables, the names must be prefixed with `TF_VAR_`
# Ex. `TF_VAR_cf_user="foobarbaz"`
variable "access_key" {
  type        = string
  description = "AWS access key id"
}

variable "secret_key" {
  type        = string
  description = "AWS secret access key"
}

variable "region" {
  type        = string
  description = "AWS default region"
}

variable "cf_user" {
  type        = string
  description = "cloud.gov deployer account user"
}

variable "cf_password" {
  type        = string
  description = "cloud.gov deployer account password"
}

# variable "uev_key" {
#   type        = string
#   description = "User Environment Variables encryption key"
# }

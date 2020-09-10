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

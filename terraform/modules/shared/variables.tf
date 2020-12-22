variable "cf_env" {
  type        = string
  description = "cloud.gov environment name (staging, production)"

  validation {
    condition     = can(regex("^(staging|production)$", var.cf_env))
    error_message = "Variable 'cf_env' must be either 'staging' or 'production'."
  }
}
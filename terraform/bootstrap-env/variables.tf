variable "aws_platform" {
  type        = string
  description = "aws platform destination ('commercial' or 'govcloud')"

  validation {
    condition     = can(regex("^(commercial|govcloud)$", var.aws_platform))
    error_message = "Variable 'aws_platform' must be either 'commercial' or 'govcloud'."
  }
}
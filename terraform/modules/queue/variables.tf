variable "aws_user_name" {
  type        = string
  description = "Unique name used when creating the AWS user with permissions for the created queue"
}

variable "space" {
  type        = string
  description = "Id of the Cloud Foundry Space in which the service credentials will be created"
}

variable "service_name" {
  type        = string
  description = "Name of the created Cloud Foundry service which will contain the IAM credentials to access the created queue"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the created user and queue"
  default     = {}
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
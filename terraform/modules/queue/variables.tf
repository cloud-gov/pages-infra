variable "name_prefix" {
  type        = string
  description = "Name used to prefix all service and resource names"
}

variable "space" {
  type        = string
  description = "Id of the Cloud Foundry Space in which the service credentials will be created"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to services and resources"
  default     = {}
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "sns_topic" {
  type        = string
  description = "SNS topic to receive alarms"
}
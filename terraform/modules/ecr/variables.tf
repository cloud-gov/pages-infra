variable "name_prefix" {
  type        = string
  description = "Name used to prefix all service and resource names"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to services and resources"
  default     = {}
}
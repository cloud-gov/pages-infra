variable "bucket" {
  type        = string
  description = "Globally unique S3 bucket name"
}

variable "table" {
  type        = string
  description = "Dynamo DB table name"
}
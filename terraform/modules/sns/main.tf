terraform {
  required_version = "~> 0.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
  }
}

data "aws_caller_identity" "default" {}

resource "aws_sns_topic" "topic" {
  name              = "${var.name_prefix}-sns-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = var.tags
}

# The "email" protocol is not currently supported by Terraform since it needs to be manually confirmed
# This needs to be added manually in the console
#
# resource "aws_sns_topic_subscription" "topic_subscription" {
#   topic_arn = aws_sns_topic.topic.arn
#   protocol  = "email"
#   endpoint  = "federalist-alerts@gsa.gov"
# }
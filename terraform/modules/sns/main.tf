terraform {
  required_version = "~> 0.13.2"

  # community providers must be specified in every module... 
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
  }
}

data "aws_caller_identity" "default" {}

resource "aws_sns_topic" "topic" {
  name = "${var.name_prefix}-alerts"
  
  tags = var.tags
}

resource "aws_sns_topic_policy" "topic_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.topic_policy_document.json
}

# The "email" protocol is not currently supported by Terraform since it needs to be manually confirmed
# This needs to be added manually in the console
#
# resource "aws_sns_topic_subscription" "topic_subscription" {
#   topic_arn = aws_sns_topic.topic.arn
#   protocol  = "email"
#   endpoint  = "federalist-alerts@gsa.gov"
# }

data "aws_iam_policy_document" "topic_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"
    resources = [aws_sns_topic.topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [data.aws_caller_identity.default.account_id]
    }
  }
}
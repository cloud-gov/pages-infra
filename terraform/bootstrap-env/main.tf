terraform {
  required_version = "~> 0.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }
  }

  backend "s3" {
    # The values here MUST be hardcoded
    # AWS credentials MUST be provided by environment variables or credentials file    
    bucket         = "federalist-terraform"
    dynamodb_table = "federalist-terraform-locks"
    region         = "us-gov-west-1"
    encrypt        = true
  }
}

provider "aws" {}

data "aws_caller_identity" "current" {}

locals {
  admin_accounts = {
    commercial = {
      account    = "558661175615"
      arn_prefix = "arn:aws"
    }

    govcloud = {
      account    = "902034094800"
      arn_prefix = "arn:aws-us-gov"
    }
  }
}

locals {
  account    = local.admin_accounts[var.aws_platform].account
  arn_prefix = local.admin_accounts[var.aws_platform].arn_prefix
}

resource "aws_iam_role" "terraform_user_role" {
  name               = "terraform-user-role"
  description        = "Manage resources with Terraform."
  assume_role_policy = data.aws_iam_policy_document.terraform_user_assume_role_policy_document.json
}

data "aws_iam_policy_document" "terraform_user_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["${local.arn_prefix}:iam::${local.account}:user/terraform-user"]
    }
  }
}

resource "aws_iam_policy_attachment" "terraform_user_policy_attachment" {
  name       = "terraform-user-policy-attachment"
  roles      = [aws_iam_role.terraform_user_role.name]
  policy_arn = aws_iam_policy.terraform_user_policy.arn
}

resource "aws_iam_policy" "terraform_user_policy" {
  name        = "terraform-user-policy"
  description = "Manage resources with Terraform."
  policy      = data.aws_iam_policy_document.terraform_user_policy_document.json
}

data "aws_iam_policy_document" "terraform_user_policy_document" {
  #
  # Cloudwatch
  #
  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource"
    ]
    resources = ["*"]
  }

  #
  # IAM
  #
  statement {
    actions = [
      "iam:GetPolicyVersion",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:GetPolicy",
      "iam:UpdateUser",
      "iam:AttachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:DeletePolicy",
      "iam:DeleteUser",
      "iam:CreateUser",
      "iam:TagUser",
      "iam:CreateAccessKey",
      "iam:CreatePolicy",
      "iam:UntagUser",
      "iam:GetUserPolicy",
      "iam:PutUserPolicy",
      "iam:GetUser",
      "iam:CreatePolicyVersion",
      "iam:DetachUserPolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      "iam:ListAttachedUserPolicies"
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = ["${local.arn_prefix}:iam::${data.aws_caller_identity.current.account_id}:group/Administrators"]
  }

  #
  # SNS
  #
  statement {
    actions = [
      "sns:TagResource",
      "sns:GetTopicAttributes",
      "sns:DeleteTopic",
      "sns:CreateTopic",
      "sns:SetTopicAttributes",
      "sns:UntagResource",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:ListTagsForResource"
    ]
    resources = ["*"]
  }

  #
  # SQS
  #
  statement {
    actions = [
      "sqs:TagQueue",
      "sqs:ListQueues",
      "sqs:RemovePermission",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:AddPermission",
      "sqs:UntagQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "sqs:CreateQueue",
      "sqs:SetQueueAttributes"
    ]
    resources = ["*"]
  }
}
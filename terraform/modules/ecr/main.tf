terraform {
  required_version = "~> 0.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }
  }
}

resource "aws_ecr_repository" "federalist_ecr" {
  name = "${var.name_prefix}-ecr"

  tags = var.tags
}

data "aws_iam_policy_document" "ecr_read_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      aws_ecr_repository.federalist_ecr.arn
    ]
  }
}

data "aws_iam_policy_document" "ecr_write_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:TagResource",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.federalist_ecr.arn
    ]
  }
}

resource "aws_iam_user" "federalist_ecr_read" {
  name = "${var.name_prefix}-ecr-read"

  tags = var.tags
}

resource "aws_iam_access_key" "federalist_ecr_read_access_key" {
  user = aws_iam_user.federalist_ecr_read.name
}

resource "aws_iam_user_policy" "federalist_ecr_read" {
  name   = "${var.name_prefix}-ecr-read"
  user   = aws_iam_user.federalist_ecr_read.name
  policy = data.aws_iam_policy_document.ecr_read_policy.json
}

resource "aws_iam_user" "federalist_ecr_write" {
  name = "${var.name_prefix}-ecr-write"

  tags = var.tags
}

resource "aws_iam_access_key" "federalist_ecr_write_access_key" {
  user = aws_iam_user.federalist_ecr_write.name
}

resource "aws_iam_user_policy" "federalist_ecr_write" {
  name   = "${var.name_prefix}-ecr-write"
  user   = aws_iam_user.federalist_ecr_write.name
  policy = data.aws_iam_policy_document.ecr_write_policy.json
}

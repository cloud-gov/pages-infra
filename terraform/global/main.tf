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
    bucket         = "federalist-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "federalist-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "federalist-terraform-state"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "federalist-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ecr_repository" "federalist_ecr" {
  name = "federalist/garden-build"
}

data "aws_iam_policy_document" "ecr_read_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "arn:aws-us-gov:ecr:::*",
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
      "arn:aws-us-gov:ecr:::*",
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
  name = "federalist-ecr-read"
}

resource "aws_iam_access_key" "federalist_ecr_read_access_key" {
  user = aws_iam_user.federalist_ecr_read.name
}

resource "aws_iam_user_policy" "federalist_ecr_read" {
  name   = "federalist-ecr-read"
  user   = aws_iam_user.federalist_ecr_read.name
  policy = data.aws_iam_policy_document.ecr_read_policy.json
}

resource "aws_iam_user" "federalist_ecr_write" {
  name = "federalist-ecr-write"
}

resource "aws_iam_access_key" "federalist_ecr_write_access_key" {
  user = aws_iam_user.federalist_ecr_write.name
}

resource "aws_iam_user_policy" "federalist_ecr_write" {
  name   = "federalist-ecr-write"
  user   = aws_iam_user.federalist_ecr_write.name
  policy = data.aws_iam_policy_document.ecr_write_policy.json
}
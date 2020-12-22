# Global configuration should only be run locally with admin
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
    key            = "backend/terraform.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "federalist-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "federalist-terraform"

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

resource "aws_iam_user" "terraform_backend_user" {
  name = "terraform-backend"
}

resource "aws_iam_access_key" "terraform_backend_user_access_key" {
  user = aws_iam_user.terraform_backend_user.name
}

resource "aws_iam_user_policy" "terraform_backend_user_policy" {
  name   = "terraform-backend-user-policy"
  user   = aws_iam_user.terraform_backend_user.name
  policy = data.aws_iam_policy_document.terraform_backend_user_policy.json
}

data "aws_iam_policy_document" "terraform_backend_user_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_state.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }
}
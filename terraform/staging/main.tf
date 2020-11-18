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

  backend "s3" {
    # The values here MUST be hardcoded
    # AWS credentials MUST be provided by environment variables or credentials file
    bucket         = "federalist-terraform-state"
    key            = "staging/terraform.tfstate"
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

provider "cloudfoundry" {
  api_url      = var.cf_api_url
  user         = var.cf_user
  password     = var.cf_password
  app_logs_max = 30
}

data "aws_region" "current" {}

data "cloudfoundry_space" "space" {
  org_name = var.org_name
  name     = var.env
}

locals {
  prefix = "federalist-${var.env}"

  tags = {
    Environment = var.env
  }
}

module "sns" {
  source = "../modules/sns"

  name_prefix = "${local.prefix}-alerts"

  tags = local.tags
}


module "queue" {
  source = "../modules/queue"

  name_prefix = local.prefix
  space       = data.cloudfoundry_space.space.id
  aws_region  = data.aws_region.current.name
  sns_topic   = module.sns.arn
  
  tags = local.tags
}
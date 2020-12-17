terraform {
  required_version = "~> 0.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }

    circleci = {
      source  = "mrolla/circleci"
      version = "0.4.0"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
  }
}

# provider "aws" {
#   alias = "commercial"
# }

provider "aws" {
  alias = "govcloud"
}

# data "aws_region" "current_commercial" {
#   provider = aws.commercial
# }

data "aws_region" "current_govcloud" {
  provider = aws.govcloud
}

data "cloudfoundry_space" "space" {
  org_name = "gsa-18f-federalist"
  name     = var.cf_env
}

locals {
  prefix = "federalist-${var.cf_env}"

  tags = {
    Environment = var.cf_env
  }
}

module "sns" {
  source = "../sns"
  providers = {
    aws = aws.govcloud
  }

  name_prefix = "${local.prefix}-alerts"

  tags = local.tags
}

module "queue" {
  source = "../queue"
  providers = {
    aws = aws.govcloud
  }

  name_prefix = local.prefix
  space       = data.cloudfoundry_space.space.id
  aws_region  = data.aws_region.current_govcloud.name
  sns_topic   = module.sns.arn

  tags = local.tags
}

module "ecr" {
  source = "../ecr"
  providers = {
    aws = aws.govcloud
  }

  name_prefix = local.prefix

  tags = local.tags
}

locals {
  circleci_env_vars = {
    AWS_ECR_READ_KEY     = module.ecr.read_key
    AWS_ECR_READ_SECRET  = module.ecr.read_secret
    AWS_ECR_WRITE_KEY    = module.ecr.write_key
    AWS_ECR_WRITE_SECRET = module.ecr.write_secret
    AWS_ECR_URL          = module.ecr.url
    AWS_ECR_REGION       = data.aws_region.current_govcloud.name
  }
}

resource "circleci_environment_variable" "circleci_env_vars" {
  for_each = local.circleci_env_vars

  name         = "${each.key}_${upper(var.cf_env)}"
  value        = each.value
  project      = "federalist-garden-build"
  organization = "18F"
}
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

  backend "s3" {
    # The values here MUST be hardcoded
    # AWS credentials MUST be provided by environment variables or credentials file
    bucket         = "federalist-terraform"
    key            = "production/terraform.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "federalist-terraform-locks"
    encrypt        = true
  }
}

# provider "aws" {
#   alias      = "commercial"
#   access_key = var.aws_access_key_commercial
#   secret_key = var.aws_secret_key_commercial
#   region     = var.aws_region_commercial

#   assume_role {
#     role_arn =  var.aws_assume_role_arn_commercial
#   }
# }

provider "aws" {
  alias      = "govcloud"
  access_key = var.aws_access_key_govcloud
  secret_key = var.aws_secret_key_govcloud
  region     = var.aws_region_govcloud

  assume_role {
    role_arn = var.aws_assume_role_arn_govcloud
  }
}

provider "circleci" {
  api_token    = var.circleci_api_key
  vcs_type     = "github"
  organization = "18F"
}

provider "cloudfoundry" {
  api_url      = "https://api.fr.cloud.gov"
  user         = var.cf_user
  password     = var.cf_password
  app_logs_max = 30
}

module "shared" {
  source = "../modules/shared"
  providers = {
    aws.govcloud = aws.govcloud
  }

  cf_env = "production"
}

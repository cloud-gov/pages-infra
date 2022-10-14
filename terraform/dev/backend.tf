# The backend configuration does not accept variables...
terraform {
  backend "s3" {
    bucket         = "cg-4baedab7-b526-4b1c-b20d-8b4f5bbf159e"
    key            = "dev/terraform.tfstate"
    region         = "us-gov-west-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.15.5"
    }
  }
}

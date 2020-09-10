module "backend" {
  source = "../modules/backend"

  bucket = "federalist-commercial-terraform-state"
  table  = "federalist-terraform-locks"
}

# The backend configuration does not accept variables...
terraform {
  backend "s3" {
    bucket         = "federalist-commercial-terraform-state"
    key            = "dev/terraform.tfstate"
    dynamodb_table = "federalist-terraform-locks"
    encrypt        = true
  }
}
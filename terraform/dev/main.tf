data "aws_region" "current" {}

data "cloudfoundry_space" "space" {
  org_name = var.org_name
  name     = var.env
}

data "cloudfoundry_domain" "fr" {
  name = "fr.cloud.gov"
}

data "cloudfoundry_service" "rds" {
  name = "aws-rds"
}

data "cloudfoundry_service" "redis" {
  name = "redis32"
}

data "cloudfoundry_service" "service_account" {
  name = "cloud-gov-service-account"
}

resource "cloudfoundry_service_instance" "database" {
  name         = "federalist-${var.env}-rds"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.rds.service_plans["medium-psql"]
}

resource "cloudfoundry_service_instance" "redis" {
  name         = "federalist-${var.env}-redis"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["standard-ha"]
}

resource "cloudfoundry_service_instance" "service_account" {
  name         = "federalist-deploy-user"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.service_account.service_plans["space-deployer"]
}

resource "cloudfoundry_user_provided_service" "uev_key" {
  name  = "federalist-${var.env}-uev-key"
  space = data.cloudfoundry_space.space.id
  credentials = {
    key = var.uev_key
  }
}

module "queue" {
  source = "../modules/queue"

  aws_user_name = "federalist-${var.env}-sqs"
  space         = data.cloudfoundry_space.space.id
  service_name  = "federalist-${var.env}-sqs-creds"
  aws_region    = data.aws_region.current.name

  tags = {
    Environment = var.env
  }
}

resource "cloudfoundry_route" "builder" {
  domain   = data.cloudfoundry_domain.fr.id
  space    = data.cloudfoundry_space.space.id
  hostname = "federalist-builder-${var.env}"
}

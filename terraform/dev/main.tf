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
  name = "aws-elasticache-redis"
}

data "cloudfoundry_service" "s3" {
  name = "s3"
}

resource "cloudfoundry_service_instance" "database" {
  name         = "pages-${var.env}-rds"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.rds.service_plans["micro-psql"]
}

resource "cloudfoundry_service_instance" "redis" {
  name         = "pages-${var.env}-redis"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["redis-dev"]
}

resource "cloudfoundry_service_instance" "s3-build-logs" {
  name         = "pages-${var.env}-s3-build-logs"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.s3.service_plans["basic"]
}

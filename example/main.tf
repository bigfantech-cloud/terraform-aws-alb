provider "aws" {
  region = "us-east-1"
}

module "network" {
  source  = "bigfantech-cloud/network/aws"
  version = "a.b.c" # find latest version from https://registry.terraform.io/modules/bigfantech-cloud/network/aws/latest

  cidr_block   = "10.0.0.0/16"
  project_name = "abc"
  environment  = "dev"
}

module "alb" {
  source  = "bigfantech-cloud/alb-ecs/aws"
  version = "a.b.c" # find latest version from https://registry.terraform.io/modules/bigfantech-cloud/ecs-alb/aws/latest

  project_name             = "abc"
  environment              = "dev"
  vpc_id                   = module.network.vpc_id
  subnets                  = module.network.public_subnet_ids
  target_group_port        = 80
  default_certificate_arn  = "arn:::"
  log_bucket_force_destroy = false


  targetgroup_for = {
    server = { healthcheck_path = "/login" }
    admin = {
      healthcheck_path     = "/"
      healthcheck_protocol = "HTTP"
      healthcheck_matcher  = 200
    }
    client = {}
  }

  listener_rules = {
    "server"      = ["*server.com*"]
    "adminportal" = ["*adminportal.com*"]
  }
}

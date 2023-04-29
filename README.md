# Purpose:

Used in ECS Fargate setup.

To create, Application Load Balancer, ALB access log setup, S3 bucket to save the access logs,
IAM policy to the S3 buckets.

1. ALB listener = port 80, redirect to port 443.
2. ALB listener = port 443, forward to target group.

3. Security Group = egress allowed on all the ports, and protocols.
   ingress rule = port 80 open
   ingress rule = port 443 open.

# Steps to create the resources

1. Call the module from your tf code.
2. Specify the variable inputs.

Example:

```
provider "aws
  region = "us-east-1"

module "network
  source        = "bigfantech-cloud/network/aws"
  version       = "1.0.0"
  cidr_block    = "10.0.0.0/16"
  project_name  = "abc"
  environment   = "dev"


module "alb {
  source      = "bigfantech-cloud/alb-ecs/aws"
  version     = "1.0.0"

  project_name             = "abc"
  environment              = "dev"
  vpc_id                   = module.network.vpc_id
  subnets                  = module.network.public_subnet_ids
  log_bucket_force_destroy = true

  targetgroup_for          = {
                              server = {healthcheck_path = "/login"}
                              admin = {
                                healthcheck_path = "/"
                                healthcheck_protocol = "HTTP"
                                healthcheck_matcher =200
                              }
                              client = {}
                            }

  target_group_port        = 80
  default_certificate_arn  = "arn:::"

  listener_rules = {
    "server"      = ["*server.com*"]
    "adminportal" = ["*adminportal.com*"]
  }
}



```

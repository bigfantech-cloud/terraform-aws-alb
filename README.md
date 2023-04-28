# Purpose:

Used in ECS Fargate setup.

To create, Application Load Balancer, ALB access log setup, S3 bucket to save the access logs,
IAM policy to the S3 buckets.

1. ALB listener = port 80, redirect to port 443.
2. ALB listener = port 443, forward to target group.

3. Security Group = egress allowed on all the ports, and protocols.
   ingress rule = port 80 open
   ingress rule = port 443 open.

## Variable Inputs:

#### REQUIRED:

```
- project_name
- environment
- vpc_id
- subnets
- target_group_port             (ex: 80)
- default_ssl_certificate_arn   SSL cert. ACM ARN for HTTPS listener.
- target_group_target_type      LB Target Goup target type. Ex: instance, ip, lambda, alb.
                                Default = ip.
- targetgroup_for
    Map of, Target Group identifier to map of optional Target Group configs
    `healthcheck_path`, `healthcheck_protocol`, `healthcheck_matcher`
    No. of objects in map = No. of Target Group created.
      example:
        targetgroup_for = {
          server = {healthcheck_path = "/login"}
          admin = {
            healthcheck_path = "/"
            healthcheck_protocol = "HTTP"
            healthcheck_matcher =200
          }
          client = {}
        }
```

#### OPTIONAL:

```
- listener_rules                  Map of Listener Rule specification.  Format: Target Group Identifier = ["domain"]
                                  This Rule creates "forward" action with "host_header" condition.
                                  For any other actions/conditions, create Listener Rule resource outside this module.

                                  Ex: {
                                        "server"      = ["*server.com*"]
                                        "adminportal" = ["*adminportal.com*"]
                                      }
                                  Default     = {}

- additional_ssl_certificate_arn  List of additional SSL server certificate ARN.
                                  This does not replace the default certificate on the listener.

- internal                        Is ALB internal: true/false, default = false".
                                  (Pass priv. Subnet if internal).

- http_ingress_cidr_blocks        List of CIDR blocks allowed to access the Load Balancer through HTTP.
                                  Default     = ["0.0.0.0/0"]

- https_ingress_cidr_blocks       List of CIDR blocks allowed to access the Load Balancer through HTTPS.
                                  Default     = ["0.0.0.0/0"]

- ssl_policy                      The name of the SSL Policy for the listener.

- log_bucket_force_destroy        Delete all objects from the bucket so that the bucket can be
                                  destroyed without error (e.g. `true` or `false`)
                                  Default     = false

- deregistration_delay
    specifies the time, in seconds, that an ALB should wait before changing the routing
    of traffic from a target that is being taken out of service. This allows the target to finish in-flight requests before traffic is redirected.
    Default = 100
```

## Major Resources created:

- ALB [1]
- S3 bucket [1]

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

3. Apply: From terminal run following commands.

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

!! You have successfully created ALB components !!

---

## OUTPUTS

```
- alb_log_bucket_id:
  "ALB log S3 bucket ID"

- alb_log_bucket_arn:
  "ALB log S3 bucket ARN"

#----
#ALB
#----

- alb_id:
  "ALB ID"

- alb_arn:
  "ALB ARN"

- alb_dns_name
  "LB DNS name"

- alb_zone_id
  "LB zone ID"

- alb_http_listener_arn
  "ALB HTTP listener ARN"

- alb_https_listener_arn
  "ALB HTTPS listener ARN"


- alb_target_group_arn_list
  "List of ALB Target Groups ARN"

- alb_target_group_arn_map
  "Map of ALB Target Groups ARN to Target Group name identifier"

#-----
#SECURITY GROUPS
#-----

 alb_security_group_id:
  "ID of Security Group attached to ECS ALB."

```

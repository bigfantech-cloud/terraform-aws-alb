#-----
# S3 BUCKET
#-----

variable "random_string" {
  description = "Creates 3 digit random number for S3 bucket name suffix if enabled. Default = false."
  default     = "false"
}

variable "log_bucket_force_destroy" {
  description = "Delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
  type        = bool
  default     = false
}
#-----
# ALB
#-----

variable "internal" {
  description = "is ALB internal: true/false, default internal = false"
  default     = "false"
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "subnets" {
  description = <<-EOF
  "A list of private subnet IDs to attach to the LB if it is INTERNAL.
  OR list of public subnet IDs to attach to the LB if it is NOT internal."
  EOF
  type        = list(string)
}

#----------------
# LB SG AND LB LISTENERS
#----------------

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssl_policy" {
  description = "The name of the SSL Policy for the listener. . Required if var.https_ports is set."
  type        = string
  default     = null
}

variable "default_ssl_certificate_arn" {
  description = "The ARN of the default SSL server certificate."
  type        = string
  default     = null
}

variable "additional_ssl_certificate_arn" {
  description = <<EOF
  List of additional SSL server certificate ARN.
  This does not replace the default certificate on the listener.
  EOF
  type        = list(string)
  default     = []
}

variable "additional_security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
  default     = []
}

variable "listener_rules" {
  description = <<-EOF
  Map of Listener Rule specification.  Format: Target Group Identifier = ["domain"]
  This Rule creates "forward" action with "host_header" condition.
  For any other actions/conditions, create Listener Rule resource outside this module.
  
  Ex: {
        "server"      = ["*server.com*"]
        "adminportal" = ["*adminportal.com*"]
      }

  default     = {}
  EOF
  type        = map(any)
  default     = {}

}

#------
#TARGET GROUP
#------

variable "targetgroup_for" {
  description = <<-EOF
  Map of Target Group identifier to map of optional Target Group configs
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
  EOF
  type        = map(any)
}


variable "target_group_port" {
  description = "The target group port"
  type        = number
  default     = 80
}

variable "target_group_target_type" {
  description = "LB Target Goup target type. Ex: instance, ip, lambda, alb. Default = ip"
  type        = string
  default     = "ip"
}

variable "deregistration_delay" {
  description = "delay to desigster fargate spot tasks"
  type        = number
  default     = 100
}

variable "stickiness_enabled" {
  description = "Boolean to enable / disable stickiness. Default = true."
  type        = bool
  default     = true
}

variable "stickiness_type" {
  description = "Target Goup Stickiness type. Possible values are lb_cookie, app_cookie. Default = lb_cookie"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_name" {
  description = <<-EOF
  Name of the application based cookie. Only needed when type is app_cookie.
  AWSALB, AWSALBAPP, and AWSALBTG prefixes are reserved and cannot be used.
  Default = null
  EOF
  type        = string
  default     = null
}

variable "stickiness_cookie_duration" {
  description = <<-EOF
  Only used when the type is lb_cookie.
  The time period, in seconds, during which requests from a client should be routed to the same target.
  After this time period expires, the load balancer-generated cookie is considered stale.
  The range is 1 second to 1 week (604800 seconds).
  Default = 86400.
  EOF
  type        = number
  default     = 86400
}


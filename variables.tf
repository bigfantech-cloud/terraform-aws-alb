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
  Map of Listener Rule specification.
  This Rule creates "forward" action with `host_header`/`path_pattern` condition.
  
  example: {
    server = {
      host_header             = ["*server.com*"] # optional, either `host_header` or `path_pattern` required
      path_pattern            = ["/login/*"]     # optional, either `host_header` or `path_pattern` required
    }
    adminportal = {
      host_header             = ["*adminportal.com*"] 
    }
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
  EOF
  type        = map(any)
}

variable "target_group_port" {
  description = "The target group port"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "LB Target Goup target type. example: instance, ip, lambda, alb. Default = ip"
  type        = string
  default     = "ip"
}

variable "target_deregistration_delay" {
  description = <<-EOT
    Time, in seconds, that an ALB should wait before changing the routing
    of traffic from a target that is being taken out of service.
    This allows the target to finish in-flight requests before traffic is redirected. Default = 100
  EOT
  type        = number
  default     = 100
}

variable "target_stickiness_config" {
  description = <<-EOT
  Map of stickiness configs, containing
  - `type`            = Possible values are lb_cookie, app_cookie.
  - `cookie_name`     = (optional) Name of the application based cookie. Only needed when `type` is app_cookie.
                        AWSALB, AWSALBAPP, and AWSALBTG prefixes are reserved and cannot be used.
  - `cookie_duration` = (optional) Only used when the `type` is lb_cookie.
                        The time period, in seconds, during which requests from a client should be routed to the same target.
                        After this time period expires, the load balancer-generated cookie is considered stale.
                        The range is 1 second to 1 week (604800 seconds).

  default = {
    stickiness_type            = "lb_cookie"
    stickiness_cookie_name     = null
    stickiness_cookie_duration = 86400
  }

  to disable stickiness, set `target_stickiness_config = {}`
  EOT
  type = object({
    stickiness_type            = optional(string)
    stickiness_cookie_name     = optional(string)
    stickiness_cookie_duration = optional(number)
  })
  default = {
    stickiness_type            = "lb_cookie"
    stickiness_cookie_name     = null
    stickiness_cookie_duration = 86400
  }
}


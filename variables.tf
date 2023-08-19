#-----
# S3 BUCKET
#-----

variable "log_bucket_force_destroy" {
  description = "Delete all objects from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "log_bucket_transition_days" {
  description = "Days after which log bucket objects are transitioned to Glacier. Default = 180"
  type        = number
  default     = 180
}

variable "log_bucket_expiry_days" {
  description = "Days after which log bucket objects are deleted. Default = 365"
  type        = number
  default     = 365
}

#-----
# ALB
#-----

variable "internal" {
  description = "Is ALB internal. Default = false"
  default     = false
}

variable "vpc_id" {
  description = "VPC ID to create resources in"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to associate to the LB"
  type        = list(string)
}

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed on port 80 in LB SG"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed on port 443 in LB SG"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssl_policy" {
  description = "Name of the SSL Policy for the listener. Default = null"
  type        = string
  default     = null
}

variable "default_ssl_certificate_arn" {
  description = "The ARN of the default SSL server certificate"
  type        = string
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
  description = <<EOF
  Map of Target Group identifier to Listener `host_header`, `path_pattern` condition. This creates "forward" action to the given Target Group.
  Either `host_header` or `path_pattern` is requried.
  EOF
  type = map(object({
    host_header  = optional(list(string))
    path_pattern = optional(list(string))
  }))
  default = {}
}

#------
#TARGET GROUP
#------

variable "targetgroup_for" {
  description = "Map of Target Group identifier to Target Group configs"
  type = map(object({
    port                 = optional(number)
    protocol             = optional(string)
    protocol_version     = optional(string)
    target_type          = optional(string)
    slow_start           = optional(number)
    deregistration_delay = optional(number)
    ip_address_type      = optional(string)
    preserve_client_ip   = optional(bool)
    enabled              = optional(bool)
    type                 = optional(string)
    cookie_name          = optional(string)
    cookie_duration      = optional(number)
    enabled              = optional(bool)
    path                 = optional(string)
    protocol             = optional(string)
    port                 = optional(number)
    matcher              = optional(number)
    interval             = optional(number)
    timeout              = optional(number)
    unhealthy_threshold  = optional(number)
  }))
}

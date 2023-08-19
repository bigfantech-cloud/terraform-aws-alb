# BigFantech-Cloud

We automate your infrastructure.
You will have full control of your infrastructure, including Infrastructure as Code (IaC).

To hire, email: `bigfantech@yahoo.com`

# Purpose of this code

> Terraform module

To create Application Load Balancer with multiple targets.

1. ALB listener:
   - port 80, redirect to port 443.
   - port 443, forward to target group.
2. Security Group
   - egress allowed on all the ports, and protocols.
   - ingress rule = port 80, port 443 open

## Variables

### Required Variables

| Name                          | Description                                                      | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Default |
| ----------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `vpc_id`                      | VPC ID to create resources in                                    | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |         |
| `subnets`                     | List of subnet IDs to associate to the LB                        | list(string)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |         |
| `default_ssl_certificate_arn` | The ARN of the default SSL server certificate for HTTPS listener | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |         |
| `targetgroup_for`             | Map of Target Group identifier to Target Group configs           | map(object({<br>port = number<br>protocol = optional(string)<br>protocol_version = optional(string)<br>target_type = optional(string)<br>slow_start = optional(number)<br>deregistration_delay = optional(number)<br>ip_address_type = optional(string)<br>preserve_client_ip = optional(bool)<br>enabled = optional(bool)<br>type = optional(string)<br>cookie_name = optional(string)<br>cookie_duration = optional(number)<br>enabled = optional(bool)<br>path = optional(string)<br>protocol = optional(string)<br>port = optional(number)<br>matcher = optional(number)<br>interval = optional(number)<br>timeout = optional(number)<br>unhealthy_threshold = optional(number)<br>})) |         |

### Optional Variables

| Name                             | Description                                                                                                                                                                                         | Type                                                                                                 | Default       |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------- |
| `log_bucket_force_destroy`       | Delete all objects from the bucket so that the bucket can be destroyed without error                                                                                                                | bool                                                                                                 | false         |
| `log_bucket_transition_days`     | Days after which log bucket objects are transitioned to Glacier                                                                                                                                     | number                                                                                               | 180           |
| `log_bucket_expiry_days`         | Days after which log bucket objects are deleted                                                                                                                                                     | number                                                                                               | 365           |
| `internal`                       | is ALB internal                                                                                                                                                                                     | bool                                                                                                 | true          |
| `http_ingress_cidr_blocks`       | List of CIDR blocks allowed to access the Load Balancer through HTTP                                                                                                                                | list(string)                                                                                         | ["0.0.0.0/0"] |
| `https_ingress_cidr_blocks`      | List of CIDR blocks allowed to access the Load Balancer through HTTPS                                                                                                                               | list(string)                                                                                         | ["0.0.0.0/0"] |
| `ssl_policy`                     | Name of the SSL Policy for the listener                                                                                                                                                             | string                                                                                               | null          |
| `listener_rules`                 | Map of Target Group identifier to Listener `host_header`, `path_pattern` condition. This creates "forward" action to the given Target Group.<br>Either `host_header` or `path_pattern` is requried. | map(object({<br>host_header = optional(list(string))<br>path_pattern = optional(list(string))<br>})) | {}            |
| `additional_ssl_certificate_arn` | List of additional SSL server certificate ARN. This does not replace the default certificate on the listener                                                                                        | list(string)                                                                                         | []            |
| `additional_security_groups`     | A list of security group IDs to assign to the LB                                                                                                                                                    | list(string)                                                                                         | []            |

### Example config

> Check the `example` folder in this repo

### Outputs

| Name                        | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `alb_log_bucket_id`         | ALB log S3 bucket ID                                         |
| `alb_log_bucket_arn`        | ALB log S3 bucket ARN                                        |
| `alb_id`                    | ALB ID                                                       |
| `alb_arn`                   | ALB ARN                                                      |
| `alb_dns_name`              | LB DNS name                                                  |
| `alb_zone_id`               | LB zone ID                                                   |
| `alb_http_listener_arn`     | ALB HTTP listener ARN                                        |
| `alb_https_listener_arn`    | ALB HTTPS listener ARN                                       |
| `alb_target_group_arn_list` | List of ALB Target Groups ARN                                |
| `alb_target_group_arn_map`  | Map of ALB Target Groups ARN to Target Group name identifier |
| `alb_security_group_id`     | ID of Security Group attached to ALB                         |

# BigFantech-Cloud

We automate your infrastructure.
You will have full control of your infrastructure, including Infrastructure as Code (IaC).

To hire, email: `bigfantech@yahoo.com`

# Purpose of this code

> Terraform module

To create Application Load Balancer, ALB access log setup to S3 bucket.

1. ALB listener = port 80, redirect to port 443.
2. ALB listener = port 443, forward to target group.
3. Security Group = egress allowed on all the ports, and protocols.
   ingress rule = port 80 open
   ingress rule = port 443 open

## Variables

### Required Variables

| Name                          | Description                                                                                                                                                                                                         | Default |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `vpc_id`                      | VPC ID to create resources in                                                                                                                                                                                       |         |
| `subnets`                     | list of private subnet IDs to attach to the LB                                                                                                                                                                      |         |
| `default_ssl_certificate_arn` | The ARN of the default SSL server certificate for HTTPS listener                                                                                                                                                    |         |
| `targetgroup_for`             | Target group config. Map of, Target Group identifier to map of optional Target Group configs `healthcheck_path`, `healthcheck_protocol`, `healthcheck_matcher`. No. of objects in map = No. of Target Group created |         |

### Optional Variables

| Name                             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default                                                                                                        |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `log_bucket_force_destroy`       | Delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | false                                                                                                          |
| `log_bucket_transition_days`     | Days after which log bucket objects are transitioned to Glacier | 180 |
| `log_bucket_expiry_days`         | Days after which log bucket objects are deleted                 | 365 |
| `internal`                       | is ALB internal                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | false                                                                                                          |
| `http_ingress_cidr_blocks`       | List of CIDR blocks allowed to access the Load Balancer through HTTP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | ["0.0.0.0/0"]                                                                                                  |
| `https_ingress_cidr_blocks`      | List of CIDR blocks allowed to access the Load Balancer through HTTPS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ["0.0.0.0/0"]                                                                                                  |
| `ssl_policy`                     | Name of the SSL Policy for the listener                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | null                                                                                                           |
| `listener_rules`                 | Map of Listener Rule specification. This Rule creates "forward" action with `host_header`/`path_pattern` condition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | {}                                                                                                             |
| `target_group_port`              | The target group port                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | 80                                                                                                             |
| `target_deregistration_delay`    | Time, in seconds, that an ALB should wait before changing the routing of traffic from a target that is being taken out of service. This allows the target to finish in-flight requests before traffic is redirected                                                                                                                                                                                                                                                                                                                                                                                                   | 100                                                                                                            |
| `target_stickiness_config`       | Map of stickiness configs, containing<br>- `type` = Possible values are lb_cookie, app_cookie.<br>- `cookie_name` = (optional) Name of the application based cookie. Only needed when `type` is app_cookie. AWSALB, AWSALBAPP, and AWSALBTG prefixes are reserved and cannot be used.<br>- `cookie_duration` = (optional) Only used when the `type` is lb_cookie. The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to `1` week (`604800` seconds). | {<br>type = "lb_cookie"<br>cookie_name = null<br>cookie_duration = 86400<br>} |
| `additional_ssl_certificate_arn` | List of additional SSL server certificate ARN. This does not replace the default certificate on the listener                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | []                                                                                                             |
| `additional_security_groups`     | A list of security group IDs to assign to the LB                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | []                                                                                                             |

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

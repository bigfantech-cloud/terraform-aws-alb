#----
#S3 LOG BUCKETS
#----

output "alb_log_bucket_id" {
  description = "ALB log S3 bucket ID"
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_log_bucket_arn" {
  description = "ALB log S3 bucket ARN"
  value       = aws_s3_bucket.alb_logs.arn
}

#----
#ALB
#----

output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.alb.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "LB DNS name"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "LB zone ID"
  value       = aws_lb.alb.zone_id
}

output "alb_http_listener_arn" {
  description = "ALB HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "alb_https_listener_arn" {
  description = "ALB HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}

output "alb_target_group_arn_list" {
  description = "List of ALB Target Groups ARN"
  value       = local.target_group_arn
}

output "alb_target_group_arn_map" {
  description = "Map of ALB Target Groups ARN to Target Group name identifier"
  value       = local.target_group_arn_map
}

#-----
#SECURITY GROUPS
#-----

output "alb_security_group_id" {
  description = "ID of Security Group attached to ALB."
  value       = aws_security_group.alb.id
}

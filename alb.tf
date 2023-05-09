locals {
  target_group_arn     = [for v in aws_lb_target_group.alb_https_tg : v.arn]
  target_group_arn_map = { for targetgroup, map in var.targetgroup_for : targetgroup => aws_lb_target_group.alb_https_tg[targetgroup].arn }
}

resource "aws_lb" "alb" {
  name               = "${module.this.id}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups = compact(
    concat(var.additional_security_groups, [aws_security_group.alb.id]),
  )

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  depends_on = [
    aws_s3_bucket.alb_logs
  ]

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-alb"
    },
  )
}

#-----
# LISTENERS
#-----

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.default_ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = local.target_group_arn[0]
  }
}

resource "aws_lb_listener_certificate" "https" {
  for_each = toset(var.additional_ssl_certificate_arn)

  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = each.value
}

resource "aws_lb_listener_rule" "host_header_forward" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.https.arn
  priority     = try(each.value["priority"], 99 - index(keys(var.listener_rules), each.key))

  action {
    type             = "forward"
    target_group_arn = local.target_group_arn_map[each.key]
  }

  dynamic "condition" {
    for_each = can(each.value["host_header"]) ? [each.key] : []

    content {
      host_header {
        values = var.listener_rules[condition.value].host_header
      }
    }
  }

  dynamic "condition" {
    for_each = can(each.value["path_pattern"]) ? [each.key] : []

    content {
      path_pattern {
        values = var.listener_rules[condition.value].path_pattern
      }
    }
  }

  tags = module.this.tags
}

#----------
# TARGET GROUP
#----------

resource "aws_lb_target_group" "alb_https_tg" {
  for_each = var.targetgroup_for

  name                 = "${module.this.id}-${each.key}"
  port                 = var.target_group_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.target_deregistration_delay

  stickiness {
    enabled         = length(var.target_stickiness_config) > 0 ? true : false
    type            = var.target_stickiness_config["type"]
    cookie_name     = var.target_stickiness_config["cookie_name"]
    cookie_duration = var.target_stickiness_config["cookie_duration"]
  }

  health_check {
    path     = try(each.value["healthcheck_path"], "/")
    protocol = try(each.value["healthcheck_protocol"], "HTTP")
    matcher  = try(each.value["healthcheck_matcher"], 200)
  }


  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-${each.key}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


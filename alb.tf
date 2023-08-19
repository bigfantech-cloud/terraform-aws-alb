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
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "URL not associated to any target"
      status_code  = "200"
    }
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
    for_each = each.value["host_header"] != null ? [1] : []

    content {
      host_header {
        values = each.value["host_header"]
      }
    }
  }

  dynamic "condition" {
    for_each = each.value["path_pattern"] != null ? [1] : []

    content {
      path_pattern {
        values = each.value["path_pattern"]
      }
    }
  }

  tags = module.this.tags
}

#----------
# TARGET GROUP
#----------

resource "random_string" "tg_suffix" {
  for_each = var.targetgroup_for

  length      = 1
  min_numeric = 1
  special     = false

  keepers = {
    name            = each.key
    port            = each.value["port"]
    protocol        = each.value["protocol"]
    target_type     = each.value["target_type"]
    vpc             = var.vpc_id
    ip_address_type = each.value["ip_address_type"]
  }
}

resource "aws_lb_target_group" "alb_https_tg" {
  for_each = var.targetgroup_for

  name                 = "${substr(module.this.id, 0, 20)}-${substr(each.key, 0, 9)}-${random_string.tg_suffix[each.key].result}"
  vpc_id               = var.vpc_id
  port                 = coalesce(each.value["port"], 80)
  protocol             = coalesce(each.value["protocol"], "HTTP")
  protocol_version     = coalesce(each.value["protocol_version"], "HTTP1")
  target_type          = coalesce(each.value["target_type"], "ip")
  slow_start           = coalesce(each.value["slow_start"], 0)
  deregistration_delay = coalesce(each.value["target_deregistration_delay"], 100)
  ip_address_type      = coalesce(each.value["ip_address_type"], "ipv4")
  preserve_client_ip   = coalesce(each.value["preserve_client_ip"], null)

  stickiness {
    enabled         = coalesce(each.value["stickiness_enabled"], true)
    type            = coalesce(each.value["stickiness_type"], "lb_cookie")
    cookie_name     = coalesce(each.value["stickiness_cookie_name"], null)
    cookie_duration = coalesce(each.value["stickiness_cookie_duration"], 86400)
  }

  health_check {
    enabled             = coalesce(each.value["healthcheck_enabled"], true)
    path                = coalesce(each.value["healthcheck_path"], "/")
    protocol            = coalesce(each.value["healthcheck_protocol"], "HTTP")
    port                = coalesce(each.value["healthcheck_port"], "traffic-port")
    matcher             = coalesce(each.value["healthcheck_matcher"], 200)
    interval            = coalesce(each.value["healthcheck_interval"], 30)
    timeout             = coalesce(each.value["healthcheck_timeout"], 6)
    unhealthy_threshold = coalesce(each.value["healthcheck_unhealthy_threshold"], 3)
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


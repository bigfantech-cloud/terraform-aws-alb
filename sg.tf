resource "aws_security_group" "alb" {
  name        = "${module.this.id}-alb-sg"
  description = "Controls access to the Load Balancer"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-alb-sg"
    },
  )
}

resource "aws_security_group_rule" "ingress_http" {

  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.http_ingress_cidr_blocks
}

resource "aws_security_group_rule" "ingress_https" {

  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.https_ingress_cidr_blocks
}

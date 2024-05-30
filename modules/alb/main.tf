locals {
  short_region = format("%s%s-%s",
    substr(split("-", var.region)[0], 0, 2),
    substr(split("-", var.region)[1], 0, 1),
    split("-", var.region)[2]
  )

  env_short_names = {
    develop = "dev",
    editor-dev = "dev_ed",
    testing = "test",
    production = "prod"
  }

  full_name = "${replace(var.name_prefix, "_", "-")}-${local.short_region}-${replace(local.env_short_names[var.env], "_", "-")}"
}

resource "aws_lb" "alb" {
  name                      = local.full_name
  internal                  = var.internal
  load_balancer_type        = var.load_balancer_type
  security_groups           = [var.security_groups]
  subnets                   = var.subnet_ids
  enable_deletion_protection = false
  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_listener_port #"443"
  protocol          = var.alb_listener_protocol #"HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${local.full_name}-tg"
  port        = var.target_port
  protocol    = var.target_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = var.health_check_healthy_threshold #3
    interval            = var.health_check_interval #15
    protocol            = var.health_check_protocol #"HTTP"
    port                = var.target_port
    matcher             = var.health_check_matcher #"200"
    timeout             = var.health_check_timeout# 10
    path                = var.health_check_path
    unhealthy_threshold = var.health_check_unhealthy_threshold #3
  }
}

resource "aws_route53_record" "alb_dns_record" {
  zone_id = var.route53_zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

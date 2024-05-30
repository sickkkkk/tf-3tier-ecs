variable "alb_listener_port" {
  description = "Listener port"
  type = string
  default = "443"
}

variable "alb_listener_protocol" {
  description = "Listener protocol"
  type = string
  default = "HTTPS"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS endpoints."
}

variable "dns_name" {
  description = "The DNS name to use for creating the Route 53 record."
}

variable "env" {
  description = "Deploy environment - has the mapping inside module for envs descrepancy"
}

variable "health_check_path" {
  description = "The path for the health check URL. Usually /health, except game server - it doesnt have balancer for now"
}

variable health_check_healthy_threshold {
  description = "Number of healtchecks to consider target healthy"
  type = number
  default = 3
}

variable health_check_interval {
  description = "Interval (in seconds) between health checks"
  type = number
  default = 15
}

variable "health_check_protocol" {
  description = "Healthcheck protocol"
  default = "HTTP"
}

variable "health_check_matcher" {
  description = "HTTP code to match proper healthcheck"
  default = "200"
}

variable "health_check_timeout" {
  description = "Timeout (in seconds) to fail healthcheck"
  type = number
  default = 10
}

variable health_check_unhealthy_threshold {
  description = "Number of failed healthchecks to consider target unhealthy"
  type = number
  default = 3
}
variable "internal" {
  description = "Specifies if the load balancer is internal or external."
  type = string
  default = "false"
}

variable "load_balancer_type" {
  description = "The type of load balancer to create - ALB, NLB, ELB."
}

variable "name_prefix" {
  description = "A prefix for the names of resources created by this module to help with naming."
}

variable "region" {
  description = "The AWS region where the load balancer and other resources will be created."
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone in which to create the DNS record."
}

variable "security_groups" {
  description = "List of security group IDs to attach to the load balancer."
}

variable "subnet_ids" {
  description = "List of subnet IDs to which the load balancer will be attached."
}

variable "target_port" {
  description = "The port on which targets receive traffic, unless overridden when registering specific targets."
}

variable "target_protocol" {
  description = "The protocol to use for routing traffic to the targets (e.g., 'HTTP', 'HTTPS')."
}

variable "vpc_id" {
  description = "The ID of the VPC in which the load balancer is created."
}

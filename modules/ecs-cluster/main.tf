locals {
  aws_region = var.region
  split_region = split("-", local.aws_region)
  short_region = format("%s%s-%s", substr(local.split_region[0], 0, 2), substr(local.split_region[1], 0, 1), local.split_region[2])
  env_short_names = {
    develop = "dev"
    editor-dev = "dev_ed"
    testing = "test"
    production = "prod"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}-${local.short_region}-${local.env_short_names[var.env]}"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = var.service_discovery_private_fqdn
  description = "Backend internal LB domain"
  vpc         = var.vpc_id
}
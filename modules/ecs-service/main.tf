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

resource "aws_service_discovery_service" "service_discovery_endpoint" {
  name = "${var.service_config.task_family}"

  dns_config {
    namespace_id = var.service_config.namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.service_config.task_family}-${local.short_region}-${local.env_short_names[var.env]}"
  cluster         = var.service_config.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.service_config.desired_count

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups    = var.service_config.sg_ids
    subnets            = var.service_config.subnet_ids
    assign_public_ip   = true
  }

  dynamic "load_balancer" {
    for_each = var.service_config.enable_alb ? [1] : []
    content {
      target_group_arn = var.service_config.alb_target_group_arn
      container_name   = var.service_config.container_definitions[0].name
      container_port   = var.service_config.container_definitions[0].portMappings[0].containerPort
    }
  }

  dynamic "service_registries" {
    for_each = var.service_config.enable_service_registry ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.service_discovery_endpoint.arn
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.service_config.task_family}-${local.short_region}-${local.env_short_names[var.env]}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.service_config.execution_role_arn
  network_mode             = var.service_config.network_mode
  cpu                      = var.service_config.container_definitions[0].cpu
  memory                   = var.service_config.container_definitions[0].memory
  container_definitions    = jsonencode(var.service_config.container_definitions)
}

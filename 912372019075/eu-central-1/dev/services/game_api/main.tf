module "game_api_alb" {
  source = "../../../../../modules/alb"

  certificate_arn                = data.terraform_remote_state.landing-zone.outputs.wildcard_dev_cert_arn
  dns_name                       = "game-api.${local.env_short_names[var.env]}.${lower("${var.project_name}")}.${var.root_domain_public_fqdn}"
  env                            = var.env
  health_check_path              = "/health"
  health_check_healthy_threshold = 5
  internal                       = "false"
  load_balancer_type             = "application"
  name_prefix                    = var.service_name
  region                         = var.region
  route53_zone_id                = data.aws_route53_zone.root_domain.id
  security_groups                = data.terraform_remote_state.metacity-core.outputs.auth_service_alb_sg_id
  subnet_ids                     = data.terraform_remote_state.metacity-core.outputs.public_subnet_ids
  target_port                    = var.service_port
  target_protocol                = "HTTP"
  vpc_id                         = data.terraform_remote_state.metacity-core.outputs.vpc_id
}

module "game_api" {
  source = "../../../../../modules/ecs-service"

  env    = var.env
  region = var.region

  service_config = {
    alb_target_group_arn = "${module.game_api_alb.target_group_arn}"
    cluster_id           = "${data.terraform_remote_state.backend-cluster.outputs.ecs_cluster_id}"
    container_definitions = [
      {
        name      = "${var.container_name}"
        image     = "${local.account_number}.dkr.ecr.${local.aws_region}.amazonaws.com/${var.container_name}:${var.version_tag}" #dynamicaly create string using variables
        cpu       = "${var.cpu_size}"
        memory    = "${var.memory_size}"
        essential = true
        portMappings = [
          {
            containerPort = "${var.service_port}"
            hostPort      = "${var.service_port}"
          }
        ]
        environment = [
          for key, value in local.env_vars : {
            name  = key
            value = value
          }
        ]
        secrets = [
          for key, secret in local.secrets : {
            name      = secret.name
            valueFrom = secret.valueFrom
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/backend-logs-${local.short_region}-${local.env_short_names[var.env]}"
            "awslogs-region"        = "${var.region}"
            "awslogs-stream-prefix" = "${var.container_name}"
          }
        }
      }
    ]
    desired_count           = 1
    enable_alb              = true
    enable_service_registry = true
    execution_role_arn      = "${data.terraform_remote_state.metacity-core.outputs.ecs_task_execution_role_arn}"
    network_mode            = "awsvpc"
    service_registry_arn    = "${data.terraform_remote_state.backend-cluster.outputs.private_service_dns_namespace_arn}"
    sg_ids                  = ["${data.terraform_remote_state.metacity-core.outputs.auth_service_ecs_tasks_sg_id}"]
    subnet_ids              = "${data.terraform_remote_state.metacity-core.outputs.public_subnet_ids}"
    task_family             = "${var.service_name}"
    namespace_id            = "${data.terraform_remote_state.backend-cluster.outputs.private_service_dns_namespace_id}"
  }
}

variable "service_config" {
  description = "Configuration for a single ECS service"
  type = object({
    alb_target_group_arn    = optional(string)
    cluster_id              = string
    container_definitions   = list(object({
      name          = string
      image         = string
      cpu           = number
      memory        = number
      essential     = bool
      portMappings = list(object({
        containerPort = number
        hostPort      = number
      }))
      environment   = list(object({
        name = string
        value = string
      }))
      secrets   = list(object({
        name = string
        valueFrom = string
      }))
      logConfiguration = object({
        logDriver    = string
        options      = map(string)
      })
    }))
    desired_count           = number
    enable_alb              = bool
    enable_service_registry = bool
    execution_role_arn      = string
    network_mode            = string
    service_registry_arn    = optional(string)
    sg_ids                  = list(string)
    subnet_ids              = list(string)
    task_family             = string
    namespace_id            = string
  })
}

variable "env" {
  type        = string
  description = "Environment description"
}

variable "region" {
  type        = string
  description = "Default region for resource allocation"
}

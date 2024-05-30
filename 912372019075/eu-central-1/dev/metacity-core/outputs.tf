output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "List if IDs of the public subnets in the VPC"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "List of IDs of the private subnets in the VPC"
}

output "private_subnet_azs" {
  value       = module.vpc.private_subnet_azs
  description = "List of availability zones of the private subnets in the VPC"
}

output "gs_public_sg_id" {
  value       = module.security.gs_public_sg_id
  description = "Dedicated Game Server Security Group"
}

output "dd_backend_instance_profile_arn" {
  value       = module.iam.dd_gs_instance_profile_arn
  description = "ARN for Backend Game Server instance profile"
}

output "db_agent_instance_profile_arn" {
  value       = module.iam.db_agent_instance_profile_arn
  description = "ARN for DB Agent instance profile"
}

output "delivery_server_instance_profile_arn" {
  value       = module.iam.delivery_server_instance_profile_arn
  description = "ARN for Delivery server instance profile"
}

output "auth_service_alb_sg_id" {
  value       = module.security.auth_service_alb_sg_id
  description = "ID for Auth Service LB Security Group"
}

output "auth_service_ecs_tasks_sg_id" {
  value       = module.security.auth_service_ecs_tasks_sg_id
  description = "ID for Auth Service ECS Tasks Security Group"
}

output "backend_db_sg_id" {
  value       = module.security.backend_db_sg_id
  description = "ID for Backend RDS DB Security Group"
}

output "delivery_server_sg_id" {
  value = module.security.delivery_server_sg_id
}

output "nats_server_sg_id" {
  value       = module.security.nats_server_sg_id
  description = "ID for Backend NATS Server Security Group"
}

output "vpc_bastion_sg_id" {
  value       = module.security.vpc_bastion_sg_id
  description = "ID for Backend NATS Server Security Group"
}

output "ecs_task_execution_role_arn" {
  value       = module.iam.ecs_task_execution_role_arn
  description = "ARN for ECS task execution role"
}

output "deploy_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ec2_bastion_instance_profile_arn" {
  value = module.iam.ec2_bastion_instance_profile_arn
}

output "gitlab_master_sg_id" {
  value       = module.security.gitlab_master_sg_id
  description = "SG ID for Gitlab Master instance"
}

output "gitlab_master_instance_profile_arn" {
  value       = module.iam.gitlab_master_instance_profile_arn
  description = "ARN for Gitlab Master server Role"
}

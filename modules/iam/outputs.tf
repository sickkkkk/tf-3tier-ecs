output "ecs_task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}

output "dd_gs_role_arn" {
    value = aws_iam_role.dd_gs_role.arn
}

output "dd_gs_instance_profile_arn" {
    value = aws_iam_instance_profile.dd_backend_instance_profile.arn
}

output "delivery_server_instance_profile_arn" {
  value = aws_iam_instance_profile.delivery_server_instance_profile.arn
}

output "db_agent_role_arn" {
    value = aws_iam_role.db_agent_role.arn
}

output "db_agent_instance_profile_arn" {
    value = aws_iam_instance_profile.db_agent_instance_profile.arn
}

output "ec2_bastion_instance_profile_arn" {
    value = aws_iam_instance_profile.ec2_bastion_instance_profile.arn
}

output "gitlab_master_role_arn" {
  value = aws_iam_role.gitlab_master_role.arn
}

output "gitlab_master_instance_profile_arn" {
    value = aws_iam_instance_profile.gitlab_master_instance_profile.arn
}
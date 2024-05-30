output "auth_service_alb_sg_id" {
  value = aws_security_group.auth_service_alb_sg.id
}
output "auth_service_ecs_tasks_sg_id" {
  value = aws_security_group.auth_service_ecs_tasks_sg.id
}
output backend_db_sg_id {
   value = aws_security_group.backend_db_sg.id
}
output delivery_server_sg_id {
  value = aws_security_group.delivery_server_sg.id
}
output "gs_public_sg_id" {
  value = aws_security_group.gs_public_sg.id
}
output "nats_server_sg_id" {
  value = aws_security_group.nats_server_sg.id
}
output "gitlab_master_sg_id" {
  value = aws_security_group.gitlab_master_sg.id
}
output "vpc_endpoint_ssm_sg_id" {
  value = aws_security_group.vpc_endpoint_ssm_sg.id
}
output "vpc_bastion_sg_id" {
  value = aws_security_group.vpc_bastion_sg.id
}
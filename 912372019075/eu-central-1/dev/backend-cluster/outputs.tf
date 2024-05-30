output "ecs_cluster_id" {
  value = module.backend-cluster.ecs_cluster_id
}

output "private_service_dns_namespace_arn" {
  value = module.backend-cluster.private_service_dns_namespace_arn
} 

output private_service_dns_namespace_id {
    value = module.backend-cluster.private_service_dns_namespace_id
}
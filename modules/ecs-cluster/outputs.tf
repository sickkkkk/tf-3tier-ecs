output ecs_cluster_id {
    value = aws_ecs_cluster.ecs_cluster.id
}

output private_service_dns_namespace_arn {
    value = aws_service_discovery_private_dns_namespace.private.arn
}

output private_service_dns_namespace_id {
    value = aws_service_discovery_private_dns_namespace.private.id
}
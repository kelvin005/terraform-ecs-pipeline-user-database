output "ecs_app_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "ecs_app_service_name" {
  value = aws_ecs_service.app_service.name
}

output "mongo_express_service_name" {
  value = aws_ecs_service.mongo_express_service.name
}



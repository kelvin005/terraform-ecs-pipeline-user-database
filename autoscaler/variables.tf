variable "ecs_app_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecs_app_service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "ecs_mongo_express_service_name" {
  description = "The name of the ECS service for mongo-express"
  type        = string
}

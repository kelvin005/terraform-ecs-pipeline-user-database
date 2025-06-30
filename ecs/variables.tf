variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-2"
}

variable "subnet_main_id" {
  description = "ID of the main subnet"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS cluster service"
  type        = string
  default     = "user-database-app-service"
}
variable "service_family" {
  description = "Family name for the ECS service"
  type        = string
  default     = "user-database-app"
}
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "user_database_app_cluster"
}
variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "user-database-app-task"
}

variable "ecs_task_execution_role"{
    description = "IAM role for ECS task execution"
    type        = string
}
variable "efs_file_system_id"{
    description = "EFS file system ID for the ECS task"
    type        = string
    default     = ""
}
variable "ecs_group_name"{
    description = "Name of the ECS task group"
    type        = string
}
variable "ecr_repository_url" {
    description = "ECR repository URL for the application image"
    type        = string
}
variable "frontend_target_group_arn" {
    description = "ARN of the target group for the ECS service"
    type        = string
}

variable "express_target_group_arn" {
    description = "ARN of the target group for the Mongo Express service"
    type        = string
}
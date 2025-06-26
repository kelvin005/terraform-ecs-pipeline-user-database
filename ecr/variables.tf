variable "ecr_repo_name"{
    description = "Name of the ECR repository"
    type        = string
    default     = "user-database-app-repo"
}
variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-2"
}
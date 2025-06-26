provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# IAM Role and Policies
module "iam_role" {
  source = "./iam-role"
}

# VPC, Subnets, Security Group
module "network" {
  source = "./network"
}

# EFS
module "efs" {
  source             = "./efs"
  subnet_main_id     = module.network.subnet_id
  security_group_id  = module.network.security_group_id
}

# ECR
module "ecr" {
  source = "./ecr"
}

# CloudWatch Log Group
module "cloudwatch_logs" {
  source         = "./cloudwatch-logs"
  log_group_name = "database-app-logs"
}

# ECS Cluster and Services
module "ecs" {
  source                  = "./ecs"
  subnet_main_id          = module.network.subnet_id
  security_group_id       = module.network.security_group_id
  ecs_task_execution_role = module.iam_role.iam_role_arn
  efs_file_system_id      = module.efs.efs_file_system_id
  ecr_repository_url      = module.ecr.repository_url
  ecs_cluster_name        = "database-app-cluster"
}

module "s3_backend" {
  source = "./s3_backend_terraform_state"
  }

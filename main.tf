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
  subnet_main_id     = module.network.subnet_ids
  security_group_id  = module.network.efs_sg_id
  subnet_map = {
  "az1" = module.network.subnet_ids[0]
  "az2" = module.network.subnet_ids[1]
}

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
  subnet_main_id          = module.network.subnet_ids
  security_group_id       = module.network.security_group_id
  ecs_task_execution_role = module.iam_role.iam_role_arn
  efs_file_system_id      = module.efs.efs_file_system_id
  ecr_repository_url      = module.ecr.repository_url
  ecs_cluster_name        = "database-app-cluster"
  ecs_group_name          = module.cloudwatch_logs.log_group_name
  frontend_target_group_arn = module.loadbalancer.frontend_target_group_arn
  express_target_group_arn  = module.loadbalancer.mongo_express_target_group_arn
  mongo_db_security_group = module.network.mongo_db_sg_id
  mongo_express_security_group = module.network.mongo_express_sg_id
  app_security_group = module.network.app_sg_id
  depends_on = [ module.loadbalancer]

}

module "loadbalancer" {
  source                = "./loadbalancer"
  alb_security_group_id = module.network.alb_security_group_id
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.subnet_ids
}

module "autoscaler" {
  source = "./autoscaler"
  ecs_app_cluster_name = module.ecs.ecs_app_cluster_name
  ecs_app_service_name = module.ecs.ecs_app_service_name
  ecs_mongo_express_service_name = module.ecs.mongo_express_service_name
}

  terraform {
  backend "s3" {
    bucket         = "terraform-state-backup-bucketv1"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform_state_backup_database_table"
    encrypt        = true
      }
}


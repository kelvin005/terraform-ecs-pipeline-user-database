provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repo_name
}


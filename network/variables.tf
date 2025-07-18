variable "aws_region" {
  default = "us-east-2"
}

variable "ecr_repo_name" {
  default = "my-app-repo"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_cidr_2" {
  default = "10.0.2.0/24"
}

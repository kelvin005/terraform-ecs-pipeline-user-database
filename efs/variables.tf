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

variable "subnet_map" {
  type = map(string)
}

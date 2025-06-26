variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

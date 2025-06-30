# variable "subnet_main_id" {
#   description = "Main subnet ID for the load balancer"
#   type        = list(string)
# }

variable "vpc_id" {
  description = "VPC ID where the load balancer will be deployed"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

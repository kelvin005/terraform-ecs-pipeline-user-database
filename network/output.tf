
output "subnet_id" {
  value = aws_subnet.subnet_id.id
}
output "security_group_id" {
  value = aws_security_group.app_sg.id
}
output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.app_lb_sg.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [aws_subnet.subnet_id_1.id, aws_subnet.subnet_id_2.id]
}
output "subnet_id_1" {
  value = aws_subnet.subnet_id_1.id
}
output "subnet_id_2" {
  value = aws_subnet.subnet_id_2.id
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

output "mongo_express_sg_id" {
  value = aws_security_group.mongo_express_sg.id
}

output "mongo_db_sg_id" {
  value = aws_security_group.mongo_db_sg.id
}
output "app_sg_id" {
  value = aws_security_group.app_sg.id
}
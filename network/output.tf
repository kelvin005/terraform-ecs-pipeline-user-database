
output "subnet_id" {
  value = aws_subnet.subnet_id.id
}
output "security_group_id" {
  value = aws_security_group.app_sg.id
}
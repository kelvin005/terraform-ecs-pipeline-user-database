output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}
output "mongo_express_target_group_arn" {
  value = aws_lb_target_group.mongo_express_tg.arn
}
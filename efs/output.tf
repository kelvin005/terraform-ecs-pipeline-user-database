output "efs_file_system_id" {
  value = aws_efs_file_system.mongo_data.id
}

output "efs_mount_target_id" {
  value = { for subnet_id, mongo_target in aws_efs_mount_target.mongo_target : subnet_id => mongo_target.id }
}

output "efs_file_system_id" {
  value = aws_efs_file_system.mongo_data.id
}

output "efs_mount_target_id" {
  value = aws_efs_mount_target.mongo_target.id
}

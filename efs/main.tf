provider "aws" {
  region = var.aws_region
}

resource "aws_efs_file_system" "mongo_data" {
  creation_token = "mongo-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  tags = {
    Name = "mongo-efs"
  }
}

resource "aws_efs_mount_target" "mongo_target" {
  file_system_id  = aws_efs_file_system.mongo_data.id
  for_each     = var.subnet_map
  security_groups = [var.security_group_id]
  subnet_id       = each.value
}

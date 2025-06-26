
provider "aws" {
  region = var.aws_region
}

resource "aws_cloudwatch_log_group" "log_group_id" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}

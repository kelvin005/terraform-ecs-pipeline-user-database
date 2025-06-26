terraform {
  backend "s3" {
    bucket         = "terraform-state-backup-bucketv1"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform_state_backup_database_table"
    encrypt        = true
    locking         = true
  }
}

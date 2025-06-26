provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExec_Rolev3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ecr_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_logs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
resource "aws_iam_role_policy_attachment" "ecs_task_efs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}


resource "aws_iam_user_policy_attachment" "terraform_user_ecs" {
  user       = "terraform_user"
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_user_policy_attachment" "terraform_user_efs" {
  user       = "terraform_user"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_user_policy_attachment" "terraform_user_logs" {
  user       = "terraform_user"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_user_policy_attachment" "terraform_user_ec2" {
  user       = "terraform_user"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}



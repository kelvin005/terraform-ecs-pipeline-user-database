provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs_cluster_name
}


resource "aws_ecs_task_definition" "app_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "my-app"
      image     = "${var.ecr_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_main_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "my-app"
    container_port   = 3000
  }
}


resource "aws_ecs_task_definition" "mongo_task" {
  family                   = "mongo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "mongodb"
      image     = "mongo:latest"
      essential = true
      environment = [
        { name = "MONGO_INITDB_ROOT_USERNAME", value = "admin" },
        { name = "MONGO_INITDB_ROOT_PASSWORD", value = "password" },
        { name = "MONGO_URL", value = "mongodb://admin:password@mongodb:27017" }
      ],
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "mongo-storage",
          containerPath = "/data/db"
        }
      ],
      logConfiguration = {
       logDriver = "awslogs",
        options = {
          awslogs-group  = var.ecs_group_name,
          awslogs-region  = var.aws_region,
          awslogs-stream-prefix = "ecs"
        }
      }

    }
  ])
    volume {
        name = "mongo-storage"
        efs_volume_configuration {
        file_system_id = var.efs_file_system_id
        root_directory = "/"
        transit_encryption = "ENABLED"
        }
    } 
}

resource "aws_ecs_service" "mongo_service" {
  name            = "mongo-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.mongo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_main_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  
}

resource "aws_ecs_task_definition" "mongo_express_task" {
  family                   = "mongo-express-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "mongo-express"
      image     = "mongo-express:latest"
      essential = true
      environment = [
        { name = "ME_CONFIG_MONGODB_SERVER", value = "mongodb" },
        { name = "ME_CONFIG_MONGODB_ADMINUSERNAME", value = "admin" },
        { name = "ME_CONFIG_MONGODB_ADMINPASSWORD", value = "password" }
      ],
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "mongo_express_service" {
  name            = "mongo-express-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.mongo_express_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_main_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.express_target_group_arn
    container_name   = "mongo-express"
    container_port   = 8081
  }
}


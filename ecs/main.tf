resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs_cluster_name
}

# ----------------------------
# Service Discovery Namespace
# ----------------------------
resource "aws_service_discovery_private_dns_namespace" "mongo_namespace" {
  name        = "local"
  description = "Private namespace for MongoDB"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "mongo_sd" {
  name         = "mongodb"
  namespace_id = aws_service_discovery_private_dns_namespace.mongo_namespace.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.mongo_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }
}

# ----------------------------
# App Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "app_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "my-app",
      image     = "${var.ecr_repository_url}:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.ecs_group_name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs"
        }
      },
      environment = [
        { name = "MONGO_URL", value = "mongodb://admin:password@mongodb.local:27017" }
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
    subnets         = var.subnet_main_id
    security_groups = [var.app_security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "my-app"
    container_port   = 3000
  }
}

# ----------------------------
# MongoDB Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "mongo_task" {
  family                   = "mongo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "mongodb",
      image     = "mongo:latest",
      essential = true,
      environment = [
        { name = "MONGO_INITDB_ROOT_USERNAME", value = "admin" },
        { name = "MONGO_INITDB_ROOT_PASSWORD", value = "password" }
      ],
      portMappings = [
        {
          containerPort = 27017
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
          awslogs-group         = var.ecs_group_name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "mongo-storage"
    efs_volume_configuration {
      file_system_id     = var.efs_file_system_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "mongo_service" {
  name            = "mongo-db-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.mongo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_main_id
    security_groups = [var.mongo_db_security_group]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mongo_sd.arn
  }
}

# ----------------------------
# Mongo Express Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "mongo_express_task" {
  family                   = "mongo-express-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "mongo-express",
      image     = "${var.ecr_repository_url}:1.0.2",
      essential = true,
      environment = [
        { name = "ME_CONFIG_MONGODB_SERVER", value = "mongodb.local" },
        { name = "ME_CONFIG_MONGODB_ADMINUSERNAME", value = "admin" },
        { name = "ME_CONFIG_MONGODB_ADMINPASSWORD", value = "password" }
      ],
      portMappings = [
        {
          containerPort = 8081
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.ecs_group_name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs"
        }
      }
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
    subnets         = var.subnet_main_id
    security_groups = [var.mongo_express_security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.express_target_group_arn
    container_name   = "mongo-express"
    container_port   = 8081
  }
}

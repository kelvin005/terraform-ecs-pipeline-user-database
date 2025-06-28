# Auto Scaling Target for ECS Service
resource "aws_appautoscaling_target" "ecs_app_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_app_cluster_name}/${var.ecs_app_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
}

# Auto Scaling Policy based on CPU Utilization
resource "aws_appautoscaling_policy" "cpu_scaling_policy" {
  name               = "cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_app_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_app_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_app_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}



# Auto Scaling Target for mongo-express ECS Service
resource "aws_appautoscaling_target" "mongo_express_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_app_cluster_name}/${var.ecs_mongo_express_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 2
}

# Auto Scaling Policy based on CPU Utilization
resource "aws_appautoscaling_policy" "mongo_express_cpu_policy" {
  name               = "mongo-express-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.mongo_express_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.mongo_express_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.mongo_express_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "app_memory_scaling_policy" {
  name               = "app-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_app_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_app_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_app_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 60.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "mongo_express_memory_policy" {
  name               = "mongo-express-memory-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.mongo_express_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.mongo_express_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.mongo_express_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 65.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

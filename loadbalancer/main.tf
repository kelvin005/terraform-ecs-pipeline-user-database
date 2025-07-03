resource "aws_lb" "app_lb" {
  name               = "user-app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids 
  security_groups    = [var.alb_security_group_id]  
}


resource "aws_lb_target_group" "frontend_tg" {
  name     = "user-app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"  

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}
resource "aws_lb_target_group" "mongo_express_tg" {
  name         = "targetgroup-express"
  port         = 8081
  protocol     = "HTTP"
  vpc_id       = var.vpc_id
  target_type  = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}



resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/myapp/*"]
    }
  }
}

resource "aws_lb_listener_rule" "mongo_express_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mongo_express_tg.arn
  }

  condition {
    path_pattern {
      values = ["/express*"]
    }
  }
}



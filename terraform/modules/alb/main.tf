locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_lb" "cloudcart" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "ecs" {
  name        = "${local.name_prefix}-ecs-tg"
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.name_prefix}-ecs-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cloudcart.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

locals {
  name_prefix    = "${var.project_name}-${var.environment}"
  container_name = "cloudcart-api"
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}-api"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-ecs-logs"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${local.name_prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = tostring(var.task_cpu)
  memory = tostring(var.task_memory)

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = var.container_image
      essential = true
      
environment = [
  {
    name  = "DB_HOST"
    value = var.db_host
  },
  {
    name  = "DB_PORT"
    value = "5432"
  },
  {
    name  = "DB_NAME"
    value = var.db_name
  }
]

secrets = [
  {
    name      = "DB_USER"
    valueFrom = "${var.db_secret_arn}:username::"
  },
  {
    name      = "DB_PASSWORD"
    valueFrom = "${var.db_secret_arn}:password::"
  }
]


      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-api-task"
  }
}

resource "aws_ecs_service" "api" {
  count = var.enable_service ? 1 : 0
  name            = "${local.name_prefix}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  health_check_grace_period_seconds = 60

  depends_on = [
    aws_ecs_task_definition.api
  ]

  
lifecycle {
  ignore_changes = [desired_count]

  }


  tags = {
    Name = "${local.name_prefix}-api-service"
  }
}

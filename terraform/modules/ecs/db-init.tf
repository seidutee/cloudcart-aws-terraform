
resource "aws_ecr_repository" "db_init" {
  name                 = "${local.name_prefix}-db-init"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.name_prefix}-db-init"
  }
}

resource "aws_ecs_task_definition" "db_init" {
  family                   = "${local.name_prefix}-db-init"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "cloudcart-db-init"
      image = "${var.ecr_repository_url}:db-init-v1"
      essential = true

      environment = [
        {
          name  = "PGHOST"
          value = var.db_host
        },
        {
          name  = "PGPORT"
          value = "5432"
        },
        {
          name  = "PGDATABASE"
          value = var.db_name
        }
      ]

      secrets = [
        {
          name      = "PGUSER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "PGPASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "db-init"
        }
      }
    }
  ])

  tags = {
    Name = "${local.name_prefix}-db-init"
  }
}

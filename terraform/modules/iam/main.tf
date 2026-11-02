locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid     = "AllowECSTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name = "${local.name_prefix}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name               = "${local.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name = "${local.name_prefix}-ecs-task-role"
  }
}

data "aws_iam_policy_document" "ecs_secrets" {
  statement {
    sid    = "ReadCloudCartDatabaseSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name   = "${local.name_prefix}-ecs-secrets-policy"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ecs_secrets.json
}

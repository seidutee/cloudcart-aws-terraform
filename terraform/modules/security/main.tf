locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name_prefix            = "${local.name_prefix}-alb-"
  description            = "CloudCart ALB security group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# ECS Fargate Security Group
resource "aws_security_group" "ecs" {
  name_prefix            = "${local.name_prefix}-ecs-"
  description            = "CloudCart ECS security group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = {
    Name = "${local.name_prefix}-ecs-sg"
  }
}

# RDS PostgreSQL Security Group
resource "aws_security_group" "rds" {
  name_prefix            = "${local.name_prefix}-rds-"
  description            = "CloudCart database security group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}

# HTTPS ingress to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = toset(var.alb_ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  description = "HTTPS ingress"
}

# ALB to ECS
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"

  description = "Application traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"

  description = "Forward traffic to ECS"
}

# ECS to RDS PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"

  description = "PostgreSQL traffic from ECS"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"

  description = "Database connections from ECS"
}

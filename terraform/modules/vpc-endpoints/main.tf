locals {
  name_prefix = "${var.project_name}-${var.environment}"

  interface_services = {
    ecr_api = "ecr.api"
    ecr_dkr = "ecr.dkr"
    logs    = "logs"
    secrets = "secretsmanager"
  }
}

resource "aws_security_group" "endpoints" {
  name        = "${local.name_prefix}-endpoints-sg"
  description = "HTTPS access to private AWS service endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_from_ecs" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = var.ecs_security_group_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow ECS tasks to reach endpoints over HTTPS"
}

resource "aws_vpc_security_group_egress_rule" "endpoint_responses" {
  security_group_id = aws_security_group.endpoints.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow outbound traffic from endpoint ENIs"
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_services

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-${each.key}-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_app_route_table_ids

  tags = {
    Name = "${local.name_prefix}-s3-endpoint"
  }
}

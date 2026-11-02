data "aws_availability_zones" "available" {
  state = "available"
}

module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  subnet_cidrs       = var.subnet_cidrs
  enable_nat_gateway = var.enable_nat_gateway
}

module "security" {
  source = "../../modules/security"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  alb_ingress_cidrs = var.alb_ingress_cidrs
  app_port          = var.app_port
  database_port     = var.database_port
}

module "ecr" {
  source = "../../modules/ecr"

  project_name          = var.project_name
  environment           = var.environment
  image_tag_mutability  = var.image_tag_mutability
  image_retention_count = var.image_retention_count
}

module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  environment   = var.environment
  db_secret_arn = module.rds.master_secret_arn
}

module "ecs" {
  source = "../../modules/ecs"

  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  container_image        = "${module.ecr.repository_url}:${var.image_tag}"
  execution_role_arn     = module.iam.ecs_task_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  ecs_security_group_id  = module.security.ecs_security_group_id
  target_group_arn       = module.alb.target_group_arn
  db_host                = module.rds.db_endpoint
  db_name                = module.rds.db_name
  db_secret_arn          = module.rds.master_secret_arn
  ecr_repository_url     = module.ecr.repository_url
  enable_service         = var.enable_ecs_service
  depends_on = [
    module.alb,
    module.vpc_endpoints
  ]

}

module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  db_subnet_ids        = module.networking.private_db_subnet_ids
  db_security_group_id = module.security.rds_security_group_id
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}


module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  vpc_id                      = module.networking.vpc_id
  private_app_subnet_ids      = module.networking.private_app_subnet_ids
  private_app_route_table_ids = values(module.networking.private_app_route_table_ids)
  ecs_security_group_id       = module.security.ecs_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = module.security.alb_security_group_id

  description = "Allow HTTP for initial CloudCart testing"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "ecs_https_to_endpoints" {
  security_group_id            = module.security.ecs_security_group_id
  referenced_security_group_id = module.vpc_endpoints.endpoint_security_group_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow ECS HTTPS access to VPC endpoints"
}


data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_s3" {
  security_group_id = module.security.ecs_security_group_id
  prefix_list_id    = data.aws_prefix_list.s3.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow ECS to download ECR image layers from S3"
}

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

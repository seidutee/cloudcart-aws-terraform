data "aws_caller_identity" "current" {}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "CloudCart VPC ID"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "CloudCart subnet IDs"
  value       = module.networking.subnet_ids
}

output "security_group_ids" {
  description = "CloudCart security group IDs"

  value = {
    alb = module.security.alb_security_group_id
    ecs = module.security.ecs_security_group_id
    rds = module.security.rds_security_group_id
  }
}

output "ecr_repository_url" {
  description = "CloudCart container registry URL"
  value       = module.ecr.repository_url
}

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

output "ecs_iam_role_arns" {
  description = "IAM role ARNs for CloudCart ECS tasks"

  value = {
    execution = module.iam.ecs_task_execution_role_arn
    task      = module.iam.ecs_task_role_arn
  }
}

output "ecs_cluster_name" {
  description = "CloudCart ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_task_definition_arn" {
  description = "CloudCart ECS task definition ARN"
  value       = module.ecs.task_definition_arn
}

output "rds_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = module.rds.db_endpoint
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for PostgreSQL credentials"
  value       = module.rds.master_secret_arn
}


output "alb_dns_name" {
  description = "Public DNS name of the CloudCart ALB"
  value       = module.alb.alb_dns_name
}


# output "db_init_repository_url" {
#   value = module.ecs.db_init_repository_url
# }

output "db_init_task_definition_arn" {
  value = module.ecs.db_init_task_definition_arn
}

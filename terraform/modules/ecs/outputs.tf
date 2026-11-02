output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.api.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}


# output "db_init_repository_url" {
#   description = "ECR repository URL for the database initialization image"
#   value       = aws_ecr_repository.db_init.repository_url
# }

output "db_init_task_definition_arn" {
  description = "One-time ECS database initialization task ARN"
  value       = aws_ecs_task_definition.db_init.arn
}

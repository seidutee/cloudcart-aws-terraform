output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgresql.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgresql.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgresql.db_name
}

output "master_secret_arn" {
  description = "RDS-managed master secret ARN"
  value       = aws_db_instance.postgresql.master_user_secret[0].secret_arn
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_secret_arn" {
  description = "RDS-managed Secrets Manager secret ARN"
  type        = string
}

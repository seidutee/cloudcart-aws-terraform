variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC where security groups are created"
  type        = string
}

variable "alb_ingress_cidrs" {
  description = "Allowed HTTPS source CIDRs for the ALB"
  type        = list(string)
}

variable "app_port" {
  description = "Application container port"
  type        = number
  default     = 8080
}

variable "database_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

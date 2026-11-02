variable "project_name" {
  description = "CloudCart project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "container_image" {
  description = "Full ECR image URI including tag"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS application task role ARN"
  type        = string
}

variable "container_port" {
  description = "Flask API container port"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate memory in MiB"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS task security group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "desired_count" {
  description = "Desired number of running ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 20
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "enable_service" {
  description = "Whether to deploy the ECS Fargate service and autoscaling"
  type        = bool
  default     = false
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the db-init image"
  type        = string
}
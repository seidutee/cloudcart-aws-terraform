variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloudcart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for six subnets"
  type = object({
    public_a = string
    public_b = string
    app_a    = string
    app_b    = string
    db_a     = string
    db_b     = string
  })

  default = {
    public_a = "10.0.0.0/24"
    public_b = "10.0.1.0/24"
    app_a    = "10.0.2.0/24"
    app_b    = "10.0.3.0/24"
    db_a     = "10.0.4.0/24"
    db_b     = "10.0.5.0/24"
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways"
  type        = bool
  default     = false
}

variable "alb_ingress_cidrs" {
  description = "Approved HTTPS source CIDRs for the ALB"
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "CloudCart application port"
  type        = number
  default     = 8080
}

variable "database_port" {
  description = "CloudCart PostgreSQL port"
  type        = number
  default     = 5432
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "IMMUTABLE"
}

variable "image_retention_count" {
  description = "Number of tagged ECR images to retain"
  type        = number
  default     = 10
}

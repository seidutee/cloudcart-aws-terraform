variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Two Availability Zones"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones are required."
  }
}

variable "subnet_cidrs" {
  description = "CIDR blocks for public, app and database subnets"
  type = object({
    public_a = string
    public_b = string
    app_a    = string
    app_b    = string
    db_a     = string
    db_b     = string
  })
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private application subnets"
  type        = bool
  default     = false
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_subnet_ids" {
  description = "Private database subnet IDs across two AZs"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "RDS security group ID"
  type        = string
}

variable "db_name" {
  type    = string
  default = "cloudcart"
}

variable "db_username" {
  type    = string
  default = "cloudcartadmin"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

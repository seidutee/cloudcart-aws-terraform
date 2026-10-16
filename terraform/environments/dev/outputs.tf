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


output "endpoint_security_group_id" {
  description = "Security group attached to interface endpoints"
  value       = aws_security_group.endpoints.id
}

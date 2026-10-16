output "vpc_id" {
  description = "CloudCart VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs indexed by logical subnet name"
  value = {
    for key, subnet in aws_subnet.main :
    key => subnet.id
  }
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.main["public_a"].id,
    aws_subnet.main["public_b"].id
  ]
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value = [
    aws_subnet.main["db_a"].id,
    aws_subnet.main["db_b"].id
  ]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "Private application route table IDs"
  value = {
    for az, route_table in aws_route_table.private_app :
    az => route_table.id
  }
}

output "private_db_route_table_ids" {
  description = "Private database route table IDs"
  value = {
    for az, route_table in aws_route_table.private_db :
    az => route_table.id
  }
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs, empty when NAT is disabled"
  value = {
    for az, gateway in aws_nat_gateway.main :
    az => gateway.id
  }
}

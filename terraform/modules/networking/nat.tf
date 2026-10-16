locals {
  nat_azs = var.enable_nat_gateway ? toset(["a", "b"]) : toset([])
}

# Elastic IP for each NAT Gateway.
resource "aws_eip" "nat" {
  for_each = local.nat_azs

  domain = "vpc"

  tags = {
    Name = "${local.resource_prefix}-nat-eip-${each.key}"
  }
}

# One NAT Gateway in each public subnet.
resource "aws_nat_gateway" "main" {
  for_each = local.nat_azs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main["public_${each.key}"].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${local.resource_prefix}-nat-${each.key}"
  }
}

# Add default routes only when NAT is enabled.
resource "aws_route" "private_app_nat" {
  for_each = local.nat_azs

  route_table_id         = aws_route_table.private_app[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

# One private application route table per AZ.
resource "aws_route_table" "private_app" {
  for_each = toset(["a", "b"])

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-private-app-${each.key}-rt"
  }
}

# One isolated database route table per AZ.
resource "aws_route_table" "private_db" {
  for_each = toset(["a", "b"])

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-private-db-${each.key}-rt"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = toset(["a", "b"])

  subnet_id      = aws_subnet.main["app_${each.key}"].id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table_association" "private_db" {
  for_each = toset(["a", "b"])

  subnet_id      = aws_subnet.main["db_${each.key}"].id
  route_table_id = aws_route_table.private_db[each.key].id
}

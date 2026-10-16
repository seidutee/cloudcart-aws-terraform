locals {
  subnets = {
    public_a = {
      cidr   = var.subnet_cidrs.public_a
      az     = var.availability_zones[0]
      public = true
      tier   = "public"
    }
    public_b = {
      cidr   = var.subnet_cidrs.public_b
      az     = var.availability_zones[1]
      public = true
      tier   = "public"
    }
    app_a = {
      cidr   = var.subnet_cidrs.app_a
      az     = var.availability_zones[0]
      public = false
      tier   = "app"
    }
    app_b = {
      cidr   = var.subnet_cidrs.app_b
      az     = var.availability_zones[1]
      public = false
      tier   = "app"
    }
    db_a = {
      cidr   = var.subnet_cidrs.db_a
      az     = var.availability_zones[0]
      public = false
      tier   = "db"
    }
    db_b = {
      cidr   = var.subnet_cidrs.db_b
      az     = var.availability_zones[1]
      public = false
      tier   = "db"
    }
  }

  resource_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.resource_prefix}-vpc"
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${local.resource_prefix}-${replace(each.key, "_", "-")}"
    Tier = each.value.tier
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.resource_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for key, subnet in local.subnets :
    key => subnet if subnet.public
  }

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public.id
}

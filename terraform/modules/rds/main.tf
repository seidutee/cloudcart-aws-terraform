locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_db_subnet_group" "cloudcart" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgresql" {
  identifier = "${local.name_prefix}-postgresql"

  engine         = "postgres"
  engine_version = "16"

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.cloudcart.name
  vpc_security_group_ids = [var.db_security_group_id]

  publicly_accessible = false
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = {
    Name = "${local.name_prefix}-postgresql"
  }
}

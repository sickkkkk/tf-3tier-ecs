locals {
  aws_region = var.region
  split_region = split("-", local.aws_region)
  short_region = format("%s%s-%s", substr(local.split_region[0], 0, 2), substr(local.split_region[1], 0, 1), local.split_region[2])
  env_short_names = {
    develop = "dev"
    editor-dev = "dev_ed"
    testing = "test"
    production = "prod"
  }
}

resource "aws_db_parameter_group" "backend_pg_options" {
  name        = "backend-pg15-${local.short_region}-${replace(local.env_short_names[var.env],"_","-")}"
  family      = "postgres15"
  description = "Custom parameter group for PostgreSQL 15.5"

  parameter {
    name  = "log_connections"
    value = "1"  # Enables logging of each successful connection
  }
}

resource "aws_db_subnet_group" "backend_db" {
  name       = "backend-db-subnet-group-${local.short_region}-${replace(local.env_short_names[var.env],"_","-")}"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "auth_db" {
  identifier = "auth-db-${local.short_region}-${replace(local.env_short_names[var.env],"_","-")}"
  auto_minor_version_upgrade  = false
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.auth_db_database_name
  username             = var.auth_db_master_username
  password             = var.auth_db_master_password
  parameter_group_name = aws_db_parameter_group.backend_pg_options.name
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.backend_db.name
  vpc_security_group_ids = var.db_security_groups_ids
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_instance" "gdb_db" {
  identifier = "gdb-db-${local.short_region}-${replace(local.env_short_names[var.env],"_","-")}"
  auto_minor_version_upgrade  = false
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.gdb_db_database_name
  username             = var.gdb_db_master_username
  password             = var.gdb_db_master_password
  parameter_group_name = aws_db_parameter_group.backend_pg_options.name
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.backend_db.name
  vpc_security_group_ids = var.db_security_groups_ids
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  lifecycle {
    ignore_changes = [password]
  }
}
module "backend_db" {
  source = "../../../../modules/rds"
  /* Authentication service DB */
  auth_db_database_name   = var.auth_db_database_name
  auth_db_master_username = jsondecode(data.aws_secretsmanager_secret_version.auth_db_credentials_latest.secret_string)["POSTGRES_USER"]
  auth_db_master_password = jsondecode(data.aws_secretsmanager_secret_version.auth_db_credentials_latest.secret_string)["POSTGRES_PASSWORD"]

  gdb_db_database_name   = var.gdb_db_database_name
  gdb_db_master_username = jsondecode(data.aws_secretsmanager_secret_version.gdb_db_credentials_latest.secret_string)["POSTGRES_USER"]
  gdb_db_master_password = jsondecode(data.aws_secretsmanager_secret_version.gdb_db_credentials_latest.secret_string)["POSTGRES_PASSWORD"]

  /* Common parameters */
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  /* Network and Security parameters */
  db_subnets             = data.terraform_remote_state.metacity-core.outputs.private_subnet_ids # remote state dependency
  db_security_groups_ids = [data.terraform_remote_state.metacity-core.outputs.backend_db_sg_id] # remote state dependency
  /* ENV & Region parameters */
  env    = var.env
  region = var.region
}
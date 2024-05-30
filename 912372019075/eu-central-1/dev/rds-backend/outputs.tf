output "auth_db_endpoint" {
  value = module.backend_db.auth_db_endpoint
}

output "auth_db_identifier" {
  value = module.backend_db.auth_db_identifier
}

output "auth_db_secret_arn" {
  value = data.aws_secretsmanager_secret_version.auth_db_credentials_latest.arn
}

output "auth_db_database_name" {
  value = var.auth_db_database_name
}

output "gdb_db_endpoint" {
  value = module.backend_db.gdb_db_endpoint
}

output "gdb_db_identifier" {
  value = module.backend_db.gdb_db_identifier
}

output gdb_db_secret_arn {
  value = data.aws_secretsmanager_secret_version.gdb_db_credentials_latest.arn
}

output "gdb_db_database_name" {
  value = var.gdb_db_database_name
}
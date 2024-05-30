output "auth_db_endpoint" {
  value = aws_db_instance.auth_db.endpoint
}

output "auth_db_identifier" {
  value = aws_db_instance.auth_db.identifier
}

output "gdb_db_endpoint" {
  value = aws_db_instance.gdb_db.endpoint
}

output "gdb_db_identifier" {
  value = aws_db_instance.gdb_db.identifier
}

data "terraform_remote_state" "metacity-core" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "core/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "aws_secretsmanager_secret" "auth_db_credentials" {
  name = "dev/rds/auth_db"
}

data "aws_secretsmanager_secret_version" "auth_db_credentials_latest" {
  secret_id = data.aws_secretsmanager_secret.auth_db_credentials.id
}

data "aws_secretsmanager_secret" "gdb_db_credentials" {
  name = "dev/rds/db_interface"
}

data "aws_secretsmanager_secret_version" "gdb_db_credentials_latest" {
  secret_id = data.aws_secretsmanager_secret.gdb_db_credentials.id
}

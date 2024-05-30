locals {
  aws_region   = var.region
  split_region = split("-", local.aws_region)
  short_region = format("%s%s-%s", substr(local.split_region[0], 0, 2), substr(local.split_region[1], 0, 1), local.split_region[2])

  env_short_names = {
    develop    = "dev"
    editor-dev = "dev_ed"
    testing    = "test"
    production = "prod"
  }
  env_vars = {
    FLASK_APP           = "restserver/__init__.py"
    DEPLOY_TIMESTAMP    = timestamp()
    FLASK_DEBUG         = "1"
    DATABASE            = "postgres"
    POSTGRES_HOST       = "${data.terraform_remote_state.rds-backend.outputs.gdb_db_endpoint}"
    POSTGRES_DB         = "${data.terraform_remote_state.rds-backend.outputs.gdb_db_database_name}"
    POSTRGES_PORT       = "5432"
    LOGGER_LEVEL        = "INFO"
    DEFAULT_SOFT_AMOUNT = "10000000000"
    NULL_UUID           = "00000000-0000-0000-0000-000000000000"
    SERVER_TYPE         = "server"
    USER_TYPE           = "user"
  }
  secrets = {
    POSTGRES_USER = {
      name      = "POSTGRES_USER"
      valueFrom = "${data.terraform_remote_state.rds-backend.outputs.gdb_db_secret_arn}:POSTGRES_USER::"
    }
    POSTGRES_PASSWORD = {
      name      = "POSTGRES_PASSWORD"
      valueFrom = "${data.terraform_remote_state.rds-backend.outputs.gdb_db_secret_arn}:POSTGRES_PASSWORD::"
    }
    COGNITO_CLIENT_SECRET = {
      name      = "COGNITO_CLIENT_SECRET"
      valueFrom = "${data.aws_secretsmanager_secret.gdb_misc.arn}:COGNITO_CLIENT_SECRET::"
    }
  }
  account_number = data.aws_caller_identity.current.account_id
}
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
    FLASK_APP                  = "restserver/__init__.py"
    DEPLOY_TIMESTAMP           = timestamp()
    FLASK_DEBUG                = "1"
    DATABASE                   = "postgres"
    POSTGRES_HOST              = "${data.terraform_remote_state.rds-backend.outputs.auth_db_endpoint}"
    POSTGRES_DB                = "${data.terraform_remote_state.rds-backend.outputs.auth_db_database_name}"
    POSTRGES_PORT              = "5432"
    LOGGER_LEVEL               = "DEBUG"
    BRIDGE_API                 = "https://chainbridge-test.proksy.io/api/v1/graphql/"
    BRIDGE_API_REDIRECT_URI    = ""
    AWS_REGION                 = "${var.region}"
    COGNITO_DOMAIN_URL         = "${data.terraform_remote_state.landing-zone.outputs.cognito_domain}.auth.${var.region}.amazoncognito.com"
    COGNITO_LOGIN_REDIRECT_URI = "auth.${local.env_short_names[var.env]}.${lower("${var.project_name}")}.${var.root_domain_public_fqdn}/login"
    STAGE_NAME                 = "${local.env_short_names[var.env]}"
    CLUSTER_NAME_SUB           = "game_backend"
    GAME_SERVER_SUB            = "game_server"
    GAME_API_SUB               = "game_api"
    GAME_API_PORT              = "8085"
    GAME_SERVER_PORT           = "7777"
  }
  secrets = {
    POSTGRES_USER = {
      name      = "POSTGRES_USER"
      valueFrom = "${data.terraform_remote_state.rds-backend.outputs.auth_db_secret_arn}:POSTGRES_USER::"
    }
    POSTGRES_PASSWORD = {
      name      = "POSTGRES_PASSWORD"
      valueFrom = "${data.terraform_remote_state.rds-backend.outputs.auth_db_secret_arn}:POSTGRES_PASSWORD::"
    }
    AWS_KEY = {
      name      = "AWS_KEY"
      valueFrom = "${data.aws_secretsmanager_secret.auth_server_misc.arn}:AWS_KEY::"
    }
    AWS_SECRET_KEY = {
      name      = "AWS_SECRET_KEY"
      valueFrom = "${data.aws_secretsmanager_secret.auth_server_misc.arn}:AWS_SECRET_KEY::"
    }
    COGNITO_CLIENT_ID = {
      name      = "COGNITO_CLIENT_ID"
      valueFrom = "${data.aws_secretsmanager_secret.auth_server_misc.arn}:COGNITO_CLIENT_ID::"
    }
    COGNITO_CLIENT_SECRET = {
      name      = "COGNITO_CLIENT_SECRET"
      valueFrom = "${data.aws_secretsmanager_secret.auth_server_misc.arn}:COGNITO_CLIENT_SECRET::"
    }
    COGNITO_USER_POOL_ID = {
      name      = "COGNITO_USER_POOL_ID"
      valueFrom = "${data.aws_secretsmanager_secret.auth_server_misc.arn}:COGNITO_USER_POOL_ID::"
    }
  }
  account_number = data.aws_caller_identity.current.account_id
}

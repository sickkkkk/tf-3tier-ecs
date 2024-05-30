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
  env_vars       = {
    DEPLOY_TIMESTAMP    = timestamp()
  }
  secrets        = {}
  account_number = data.aws_caller_identity.current.account_id
}
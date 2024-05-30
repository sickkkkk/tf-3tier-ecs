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
  account_number = data.aws_caller_identity.current.account_id
}

module "backend-cluster" {
  source = "../../../../modules/ecs-cluster"

  cluster_name                   = var.cluster_name
  env                            = var.env
  region                         = var.region
  service_discovery_private_fqdn = "${local.short_region}.${local.env_short_names[var.env]}.${var.root_domain_public_fqdn}"
  vpc_id                         = data.terraform_remote_state.metacity-core.outputs.vpc_id

}
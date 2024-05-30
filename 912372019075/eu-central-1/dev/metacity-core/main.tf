module "vpc" {
  source                 = "../../../../modules/network"
  metacity_vpc_cidr      = var.vpc_cidr
  env                    = var.env
  region                 = var.region
  vpc_endpoint_ssm_sg_id = module.security.vpc_endpoint_ssm_sg_id
}

module "security" {
  source            = "../../../../modules/security"
  metacity_vpc_cidr = var.vpc_cidr
  metacity_vpc_id   = module.vpc.vpc_id
  env               = var.env
  region            = var.region
}

module "iam" {
  depends_on = [module.vpc]
  source     = "../../../../modules/iam"
  env        = var.env
  region     = var.region
}

module "cloudwatch_logs" {
  env    = var.env
  region = var.region
  source = "../../../../modules/logging"
}
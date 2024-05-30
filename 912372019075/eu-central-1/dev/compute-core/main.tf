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
}

resource "aws_key_pair" "sshkp" {
  key_name   = "sshkp-${local.short_region}-${local.env_short_names[var.env]}"
  public_key = data.aws_secretsmanager_secret_version.computekp.secret_string
}

module "db_agent" {
  source                   = "../../../../modules/ec2"
  ami_id                   = data.aws_ami.ubuntu2204_latest.id
  iam_instance_profile_arn = data.terraform_remote_state.metacity-core.outputs.db_agent_instance_profile_arn
  instance_kp_name         = aws_key_pair.sshkp.key_name
  desired_count            = "1"
  min_instance_count       = "1"
  max_instance_count       = "2"
  instance_type            = "t3.nano"
  nametag_prefix           = "dbagent"
  env                      = var.env
  region                   = var.region
  sg_id                    = data.terraform_remote_state.metacity-core.outputs.gs_public_sg_id
  vpc_subnet_groups        = data.terraform_remote_state.metacity-core.outputs.public_subnet_ids
  templated_userdata_script = templatefile("../../../../modules/ec2/userdata_scripts/db_agent.sh", {
    db_version  = "15.2"
    auth_db_id  = "${data.terraform_remote_state.rds-backend.outputs.auth_db_identifier}"
    region      = "${var.region}"
    secret_path = "dev/rds/auth_db"
  })
}

module "delivery_server" {
  source                   = "../../../../modules/ec2"
  ami_id                   = data.aws_ami.ubuntu2204_latest.id
  iam_instance_profile_arn = data.terraform_remote_state.metacity-core.outputs.delivery_server_instance_profile_arn
  instance_kp_name         = aws_key_pair.sshkp.key_name
  desired_count            = "1"
  min_instance_count       = "1"
  max_instance_count       = "2"
  instance_type            = "c6a.large"
  nametag_prefix           = "delivery"
  env                      = var.env
  region                   = var.region
  sg_id                    = data.terraform_remote_state.metacity-core.outputs.delivery_server_sg_id
  vpc_subnet_groups        = data.terraform_remote_state.metacity-core.outputs.public_subnet_ids
  templated_userdata_script = templatefile("../../../../modules/ec2/userdata_scripts/delivery-server.sh", {
    region             = "${var.region}",
    server_environment = "${var.env}"
  })
}

module "bastion_host" {
  source                   = "../../../../modules/ec2"
  ami_id                   = data.aws_ami.ubuntu2204_latest.id
  iam_instance_profile_arn = data.terraform_remote_state.metacity-core.outputs.ec2_bastion_instance_profile_arn
  instance_kp_name         = aws_key_pair.sshkp.key_name
  desired_count            = "1"
  min_instance_count       = "1"
  max_instance_count       = "2"
  instance_type            = "t3.nano"
  nametag_prefix           = "bastion"
  is_bastion_host          = true
  env                      = var.env
  region                   = var.region
  sg_id                    = data.terraform_remote_state.metacity-core.outputs.vpc_bastion_sg_id
  vpc_subnet_groups        = data.terraform_remote_state.metacity-core.outputs.private_subnet_ids
  templated_userdata_script = templatefile("../../../../modules/ec2/userdata_scripts/bastion_host.sh", {
  message = "Hello from Bastion Instance" })
}
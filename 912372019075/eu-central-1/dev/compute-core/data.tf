data "terraform_remote_state" "metacity-core" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "core/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "terraform_remote_state" "rds-backend" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "rds/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "aws_secretsmanager_secret_version" "computekp" {
  secret_id = "dev/compute/public/sshkp"
}

data "aws_ami" "ubuntu2204_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_route53_zone" "root_domain" {
  name = "decartel.co"
}
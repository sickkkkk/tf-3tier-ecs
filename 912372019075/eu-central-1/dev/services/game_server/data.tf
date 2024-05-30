
data "terraform_remote_state" "rds-backend" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "rds/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "terraform_remote_state" "compute-core" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "compute/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "terraform_remote_state" "landing-zone" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "lz/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "terraform_remote_state" "metacity-core" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "core/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "terraform_remote_state" "backend-cluster" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "ecs/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "root_domain" {
  name = "decartel.co"
}
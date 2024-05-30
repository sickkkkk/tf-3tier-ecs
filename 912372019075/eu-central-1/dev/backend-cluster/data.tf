data "terraform_remote_state" "metacity-core" {
  backend = "s3"
  config = {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "core/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

data "aws_caller_identity" "current" {}
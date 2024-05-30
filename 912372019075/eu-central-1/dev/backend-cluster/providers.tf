terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "ecs/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

# Configure the AWS Provider
provider "aws" {

  region = var.region

  default_tags {
    tags = {
      region    = "${var.region}"
      env       = "${var.env}"
      terraform = "True"
      project   = "Uncalled"
    }
  }
}
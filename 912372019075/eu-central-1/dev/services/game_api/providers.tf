terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "tf-infra-dev-eu-central-1"
    key            = "services/game_api/develop/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-infra-state-lock-eu-central-1"
  }
}

# Configure the AWS Provider
provider "aws" {

  region = var.region

  default_tags {
    tags = {
      region    = lower("${var.region}")
      env       = lower("${var.env}")
      terraform = "true"
      project   = lower("${var.project_name}")
      service   = lower("${var.service_name}")
    }
  }
}
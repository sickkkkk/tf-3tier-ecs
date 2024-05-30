data "aws_availability_zones" "available_azs" {
  state = "available"
}

data "aws_default_tags" "current" {}
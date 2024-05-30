locals {
  selected_azs = slice(data.aws_availability_zones.available_azs.names, 0, 3)
}

locals {
  endpoints = {
    "endpoint-ssm" = {
      name = "ssm"
    },
    "endpoint-ssmm-essages" = {
      name = "ssmmessages"
    },
    "endpoint-ec2-messages" = {
      name = "ec2messages"
    }
  }
}

locals {
  aws_region = var.region
  split_region = split("-", local.aws_region)
  short_region = format("%s%s-%s", substr(local.split_region[0], 0, 2), substr(local.split_region[1], 0, 1), local.split_region[2])
  env_short_names = {
    develop = "dev"
    editor-dev = "dev_ed"
    testing = "test"
    production = "prod"
  }
}

resource "aws_vpc" "metacity_vpc" {
  cidr_block       = var.metacity_vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "metacity_vpc-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.metacity_vpc.id
  for_each          = local.endpoints
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.${each.value.name}"
  private_dns_enabled = true
  # Add a security group to the VPC endpoint
  security_group_ids = [var.vpc_endpoint_ssm_sg_id]
  subnet_ids = aws_subnet.metacity_private[*].id
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.metacity_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = ["${aws_route_table.metacity_private_rtb.id}"] # Replace with your route table IDs
  policy          = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": ["arn:aws:s3:::*/*"]
        }
      ]
    }
    POLICY
}

resource "aws_subnet" "metacity_public" {
  count = length(local.selected_azs)
  cidr_block = cidrsubnet(var.metacity_vpc_cidr, 8, count.index)
  availability_zone = element(local.selected_azs, count.index)
  vpc_id = aws_vpc.metacity_vpc.id
  map_public_ip_on_launch = true


  tags = {
    Name = "${local.short_region}-${local.env_short_names[var.env]}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "metacity_private" {
  count = length(local.selected_azs)
  cidr_block = cidrsubnet(var.metacity_vpc_cidr, 8, count.index + length(local.selected_azs))
  availability_zone = element(local.selected_azs, count.index)
  vpc_id = aws_vpc.metacity_vpc.id

  tags = {
    Name = "${local.short_region}-${local.env_short_names[var.env]}-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "metacity_public_igw" {
  vpc_id     = aws_vpc.metacity_vpc.id
  tags = {
    Name = "metacity_public_igw-${local.short_region}-${local.env_short_names[var.env]}"
  }  
}

resource "aws_route_table" "metacity_public_rtb" {
  vpc_id = aws_vpc.metacity_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.metacity_public_igw.id
  }  
  tags = {
    Name = "metacity_public_rtb-${local.short_region}-${local.env_short_names[var.env]}"
  }  
}

resource "aws_route_table" "metacity_private_rtb" {
  vpc_id = aws_vpc.metacity_vpc.id

  tags = {
    Name = "metacity_private_rtb-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_route_table_association" "metacity_private_rta" {
  count = length(local.selected_azs)

  subnet_id      = aws_subnet.metacity_private[count.index].id
  route_table_id = aws_route_table.metacity_private_rtb.id
}

resource "aws_route_table_association" "metacity_public_rta" {
  count = length(local.selected_azs)

  subnet_id      = aws_subnet.metacity_public[count.index].id
  route_table_id = aws_route_table.metacity_public_rtb.id
}
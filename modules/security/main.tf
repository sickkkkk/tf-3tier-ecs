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

resource "aws_security_group" "auth_service_alb_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "auth_service_alb_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "SG for External LBs"

  ingress {
    description      = "Allow HTTPS traffic to ALB"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "auth_service_alb_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "gitlab_master_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "gitlab_master_sg"
  description = "Allow from ALB to Gitlab Master Instance"

  ingress {
    description      = "Allow inbound HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow inbound HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow inbound SSH to custom port"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitlab_master_sg"
  }
}

resource "aws_security_group" "auth_service_ecs_tasks_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "auth_service_ecs_tasks_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow inbound HTTP traffic to Service cluster"


  ingress {
    description      = "allow from ALB only"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = [var.metacity_vpc_cidr]
    security_groups  = [aws_security_group.auth_service_alb_sg.id,aws_security_group.gs_public_sg.id,aws_security_group.nats_server_sg.id]
  }

  ingress {
    description      = "allow from ALB only"
    from_port        = 8085
    to_port          = 8085
    protocol         = "tcp"
    cidr_blocks      = [var.metacity_vpc_cidr]
    security_groups  = [aws_security_group.auth_service_alb_sg.id,aws_security_group.gs_public_sg.id,aws_security_group.nats_server_sg.id]
  }

  ingress {
    description      = "allow inbound TCP traffic to dedicated server"
    from_port        = 7777
    to_port          = 7777
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow inbound UDP traffic to dedicated server"
    from_port        = 7777
    to_port          = 7777
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "auth_service_ecs_tasks_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "backend_db_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "backend_db_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow traffic to RDS"


  ingress {
    description      = "Allow to 5432 port"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_security_group.auth_service_ecs_tasks_sg.id,aws_security_group.gs_public_sg.id,aws_security_group.vpc_bastion_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "backend_db_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "gs_public_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "gs_public_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow connections to game server instance"

  ingress {
    description      = "Game Server SSH"
    from_port        = 22666
    to_port          = 22666
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow SSH  for ec2 instance connect"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["3.120.181.40/29"] # EC2 Instance Connect Ip Ranges
    /*
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html
    If your users will use the Amazon EC2 console to connect to an instance, ensure that the security 
    group associated with your instance allows inbound SSH traffic from the IP address range for EC2_INSTANCE_CONNECT. 
    To identify the address range, download the JSON file provided by AWS and filter for the subset for EC2 Instance Connect, 
    using EC2_INSTANCE_CONNECT as the service value. These IP address ranges differ between AWS Regions. 
    For more information about downloading the JSON file and filtering by service, see AWS IP address ranges in the Amazon VPC User Guide.
    */

    # curl -O https://ip-ranges.amazonaws.com/ip-ranges.json
    # jq '.prefixes[] | select(.service == "EC2_INSTANCE_CONNECT" and .region == "us-east-1") | .ip_prefix' ip-ranges.json
    # "18.206.107.24/29" for us-east-1 specificaly
  }

  ingress {
    description      = "Game Server inbound UDP ports"
    from_port        = 7777
    to_port          = 7777
    protocol         = "UDP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Game Server inbound TCP ports"
    from_port        = 7777
    to_port          = 7777
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Game Server inbound UDP ports"
    from_port        = 7787
    to_port          = 7787
    protocol         = "UDP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Game Server inbound TCP ports"
    from_port        = 7787
    to_port          = 7787
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "gs_public_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "nats_server_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "nats_server_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow connections to NATS server instance"

  ingress {
    description      = "NATS Server SSH"
    from_port        = 22666
    to_port          = 22666
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow SSH for ec2 instance connect"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["3.120.181.40/29"] # EC2 Instance Connect Ip Ranges
    /*
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html
    If your users will use the Amazon EC2 console to connect to an instance, ensure that the security 
    group associated with your instance allows inbound SSH traffic from the IP address range for EC2_INSTANCE_CONNECT. 
    To identify the address range, download the JSON file provided by AWS and filter for the subset for EC2 Instance Connect, 
    using EC2_INSTANCE_CONNECT as the service value. These IP address ranges differ between AWS Regions. 
    For more information about downloading the JSON file and filtering by service, see AWS IP address ranges in the Amazon VPC User Guide.
    */

    # curl -O https://ip-ranges.amazonaws.com/ip-ranges.json
    # jq '.prefixes[] | select(.service == "EC2_INSTANCE_CONNECT" and .region == "us-east-1") | .ip_prefix' ip-ranges.json
    # "18.206.107.24/29" for us-east-1 specificaly
  }

  ingress {
    description      = "Game Server inbound TCP ports"
    from_port        = 4222
    to_port          = 4222
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Game Server inbound TCP ports"
    from_port        = 8222
    to_port          = 8222
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "nats_server_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "vpc_endpoint_ssm_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "vpc_endpoint_ssm_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow from outside to ALB and to DEV inbound traffic"

  ingress {
    description      = "Allow HTTPS traffic to ALB"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.metacity_vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc_endpoint_ssm_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "vpc_bastion_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "vpc_bastion_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow from outside to ALB and to DEV inbound traffic"

  ingress {
    description      = "Allow HTTPS traffic to instance"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SSH traffic to instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.metacity_vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc_bastion_sg-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_security_group" "delivery_server_sg" {
  vpc_id      = var.metacity_vpc_id
  name        = "delivery_server_sg-${local.short_region}-${local.env_short_names[var.env]}"
  description = "Allow connections to delivery server"

  ingress {
    description      = "Allow HTTPS traffic to instance"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow SSH  for ec2 instance connect"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["3.120.181.40/29"] # EC2 Instance Connect Ip Ranges
    /*
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html
    If your users will use the Amazon EC2 console to connect to an instance, ensure that the security 
    group associated with your instance allows inbound SSH traffic from the IP address range for EC2_INSTANCE_CONNECT. 
    To identify the address range, download the JSON file provided by AWS and filter for the subset for EC2 Instance Connect, 
    using EC2_INSTANCE_CONNECT as the service value. These IP address ranges differ between AWS Regions. 
    For more information about downloading the JSON file and filtering by service, see AWS IP address ranges in the Amazon VPC User Guide.
    */

    # curl -O https://ip-ranges.amazonaws.com/ip-ranges.json
    # jq '.prefixes[] | select(.service == "EC2_INSTANCE_CONNECT" and .region == "us-east-1") | .ip_prefix' ip-ranges.json
    # "18.206.107.24/29" for us-east-1 specificaly
  }

  egress {
    description = "Allow HTTPS traffic to instance"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "delivery_server_sg"
  }
}
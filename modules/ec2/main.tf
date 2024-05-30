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

resource "aws_launch_template" "lt" {
  name = "${var.nametag_prefix}-${local.short_region}-${local.env_short_names[var.env]}-${md5("${var.templated_userdata_script}")}"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = var.instance_kp_name
  vpc_security_group_ids = [var.sg_id]
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      data.aws_default_tags.current.tags,
      {
        Name = "${var.nametag_prefix}-${local.short_region}-${local.env_short_names[var.env]}",
        isBastion = "${var.is_bastion_host}"
      }
    )
  }
  
  iam_instance_profile {
    arn = "${var.iam_instance_profile_arn}"
  }

  user_data = base64encode("${var.templated_userdata_script}")
}

resource "aws_autoscaling_group" "ec2_asg" {
  name = "${var.nametag_prefix}-${local.short_region}-${local.env_short_names[var.env]}-${md5("${var.templated_userdata_script}")}"
  vpc_zone_identifier = var.vpc_subnet_groups
  desired_capacity   = var.desired_count
  max_size           = var.max_instance_count
  min_size           = var.min_instance_count
  
  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }  
  lifecycle {
    create_before_destroy = true
  }
  instance_refresh {
    strategy = "Rolling"
      preferences {
        min_healthy_percentage = 50
      }
  }
}
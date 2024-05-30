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

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "backendEcsTaskExecutionRole-${local.short_region}-${local.env_short_names[var.env]}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role" "dd_gs_role" {
  name               = "ddGSBackendPolicy-${local.short_region}-${local.env_short_names[var.env]}"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "gitlab_master_role" {
  name               = "gitlab_master_role-${local.short_region}-${local.env_short_names[var.env]}"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "db_agent_role" {
  name               = "db_agent_role-${local.short_region}-${local.env_short_names[var.env]}"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "delivery_server_role" {
  name               = "deliveryServerRole-${local.short_region}-${local.env_short_names[var.env]}"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "dd_backend_policy" {
  name        = "dd_backend_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Allows S3 readonly actions for S3"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowS3ReadAccess",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "dynamodb:Query",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Scan"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:dynamodb:*:345116575440:table/*-server-release"
        },
        {
            "Effect": "Allow",
            "Action": "ec2:AssociateAddress",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_policy" "gitlab_master_policy" {
  name        = "gitlab_master_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Allows S3 actions for GitLab Master Instance"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowS3AccessToObjectStorage",
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "arn:aws:s3:::git-decartel-co-*"
        },
        {
      "Effect": "Allow",
      "Action": [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
      ],
      "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ec2messages:AcknowledgeMessage",
              "ec2messages:DeleteMessage",
              "ec2messages:FailMessage",
              "ec2messages:GetEndpoint",
              "ec2messages:GetMessages",
              "ec2messages:SendReply"
          ],
          "Resource": "*"
      }
    ]
})
}


resource "aws_iam_policy" "db_agent_policy" {
  name        = "db_agent_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Allows deploy specific actrions for Agent Instances"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
              {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3ReadAccess",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "arn:aws:s3:::tf-infra-*"
        },
        {
            "Sid": "AllowSecretsManagerReadWrite",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:*"
            ],
            "Resource": "arn:aws:secretsmanager:*:912372019075:secret:dev/rds/*"
        },
        {
            "Sid": "AllowRDSAccess",
            "Effect": "Allow",
            "Action": [
                "rds:*"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_policy" "ecs_backend_task_execution_policy" {
  name        = "ecs_backend_task_execution_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Allows readonly actions for ECS Backend Task"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*",
                "secretsmanager:*"
            ],
            "Resource": "*"
        }
    ]
})
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_backend_task_execution_policy.arn
}


resource "aws_iam_policy_attachment" "dd_backend_policy_attachment" {
  name       = "dd_backend_policy_attachment-${local.short_region}-${local.env_short_names[var.env]}"
  roles      = [aws_iam_role.dd_gs_role.name]
  policy_arn = aws_iam_policy.dd_backend_policy.arn
}

resource "aws_iam_policy_attachment" "gitlab_master_policy_attachment" {
  name       = "gitlab_master_policy_attachment-${local.short_region}-${local.env_short_names[var.env]}"
  roles      = [aws_iam_role.gitlab_master_role.name]
  policy_arn = aws_iam_policy.gitlab_master_policy.arn
}

resource "aws_iam_policy_attachment" "db_agent_policy_attachment" {
  name       = "db_agent_policy_attachment-${local.short_region}-${local.env_short_names[var.env]}"
  roles      = [aws_iam_role.db_agent_role.name]
  policy_arn = aws_iam_policy.db_agent_policy.arn
}

resource "aws_iam_instance_profile" "dd_backend_instance_profile" {
  name = "dd_backend_instance_profile-${local.short_region}-${local.env_short_names[var.env]}"
  role = aws_iam_role.dd_gs_role.name
}

resource "aws_iam_instance_profile" "db_agent_instance_profile" {
  name = "db_agent_instance_profile-${local.short_region}-${local.env_short_names[var.env]}"
  role = aws_iam_role.db_agent_role.name
}

resource "aws_iam_instance_profile" "gitlab_master_instance_profile" {
  name = "gitlab_master_instance_profile-${local.short_region}-${local.env_short_names[var.env]}"
  role = aws_iam_role.gitlab_master_role.name
}

resource "aws_iam_role" "ec2_bastion_role" {
  name = "ec2_bastion_role-${local.short_region}-${local.env_short_names[var.env]}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_bastion_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_bastion_role.name
}

resource "aws_iam_instance_profile" "ec2_bastion_instance_profile" {
  name = "EC2_SSM_Instance_Profile-${local.short_region}-${local.env_short_names[var.env]}"
  role = aws_iam_role.ec2_bastion_role.name
}



resource "aws_iam_policy" "delivery_server_policy" {
  name        = "delivery_server_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Allows S3 read and write actions for S3"
  policy      = file("${path.module}/policies/delivery_server_policy.json")
}

resource "aws_iam_role_policy_attachment" "delivery_server_role" {
  role       = aws_iam_role.delivery_server_role.name
  policy_arn = aws_iam_policy.delivery_server_policy.arn
}

resource "aws_iam_instance_profile" "delivery_server_instance_profile" {
  name = "delivery_server_instance_profile-${local.short_region}-${local.env_short_names[var.env]}"
  role = aws_iam_role.delivery_server_role.name
}

/* Setrvice user for auth_server */
resource "aws_iam_user" "auth_service_user" {
  name = "auth_service_user-${local.short_region}-${local.env_short_names[var.env]}"
  force_destroy = true
}

resource "aws_iam_policy" "auth_service_user_policy" {
  name        = "auth_service_user_policy-${local.short_region}-${local.env_short_names[var.env]}"
  path        = "/"
  description = "Policy granting access to AWS for auth_service internal user"

  policy = file("${path.module}/policies/auth_service_user_policy.json")
}

resource "aws_iam_user_policy_attachment" "auth_service_user_policy_attachment" {
  user       = aws_iam_user.auth_service_user.name
  policy_arn = aws_iam_policy.auth_service_user_policy.arn
}

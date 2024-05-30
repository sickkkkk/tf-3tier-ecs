resource "aws_cognito_user_pool" "pool" {
  name = "user-pool-${local.short_region}-${local.env_short_names[var.env]}"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
  }

  schema {
    name                     = "nickname"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true # false for "sub"
    required                 = true # true for "sub"
    string_attribute_constraints {  # if it is a string
      min_length = 3                # 10 for "birthdate"
      max_length = 32               # 10 for "birthdate"
    }
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "client-${local.short_region}-${local.env_short_names[var.env]}"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = ["http://localhost:8080/login", "https://auth.${local.env_short_names[var.env]}.uncalled.${var.base_domain}/login"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "auth-${local.short_region}-${local.env_short_names[var.env]}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_route53_record" "cognito_auth_r53_alias" {
  name    = aws_cognito_user_pool_domain.main.domain
  type    = "A"
  zone_id = data.aws_route53_zone.decartel_root.id

  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.main.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}
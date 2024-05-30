output "wildcard_dev_cert_arn" {
  value = aws_acm_certificate.wildcard_dev.arn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "cognito_user_pool_client_secret" {
  value     = aws_cognito_user_pool_client.client.client_secret
  sensitive = true
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.main.domain
}
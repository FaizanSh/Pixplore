output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "user_pool_issuer" {
  value = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.user_pool.arn
}

output "cognito_client_secret" {
  value = aws_cognito_user_pool_client.user_pool_client.client_secret
}

output "cognito_token_url" {
  value = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.us-east-1.amazoncognito.com/oauth2/token"
}
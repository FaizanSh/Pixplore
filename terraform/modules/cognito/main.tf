resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  # Require email at sign-up
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }

  auto_verified_attributes = ["email"]  # verify email

  password_policy {
    minimum_length    = 8
    require_numbers   = true
    require_uppercase = true
  }

  verification_message_template {
    email_subject = "Verify your account"
    email_message = "Your verification code is {####}"
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain      = var.user_pool_domain # unique in region
  user_pool_id = aws_cognito_user_pool.user_pool.id
}


resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name  = var.user_pool_client_name

  # Add explicit_auth_flows to enable USER_PASSWORD_AUTH - wasn't able to get tokken from CLI
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"

  # OAuth 2.0 Configuration
  allowed_oauth_flows       = ["code"]  # Enables the authorization code grant flow
  allowed_oauth_flows_user_pool_client = true  # Enable OAuth 2.0 flows for this user pool client - This is for frontend to use code and then get the auth
  allowed_oauth_scopes      = ["email", "openid", "profile"]  # Scopes available
  supported_identity_providers = ["COGNITO"] # Uses Cognito as the identity provider

  # Specify the URLs for redirection after login/logout
  callback_urls = [
    var.cognito_callback_url
  ]

  logout_urls = [
    var.cognito_logout_url
  ]
}
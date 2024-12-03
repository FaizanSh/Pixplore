# Define the API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "PixploreHTTPAPI"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for all Lambda functions with Cognito integration"

  # CORS
  cors_configuration {
    allow_headers = ["Authorization", "Content-Type", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = ["*"]
    expose_headers = ["Access-Control-Allow-Origin"]
    max_age = 3600
  }
}

# Define Cognito Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name                     = "CognitoAuthorizer"
  api_id                   = aws_apigatewayv2_api.http_api.id
  authorizer_type          = "JWT"
  identity_sources         = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = var.cognito_user_pool_issuer
  }
}

# Define routes for each Lambda function
resource "aws_apigatewayv2_route" "routes" {
  count           = 3 # Number of Lambda modules
  api_id          = aws_apigatewayv2_api.http_api.id
  route_key       = count.index == 0 ? "GET /${var.lambda_paths[count.index]}" : "POST /${var.lambda_paths[count.index]}" # Dynamic routes
  target          = "integrations/${aws_apigatewayv2_integration.lambda_integrations[count.index].id}"

  # Attach Cognito Authorizer only for routes where count != 0
  authorizer_id = count.index == 0 ? null : aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "search_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /search"

  target = "integrations/${aws_apigatewayv2_integration.load_balancer_integration.id}"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id # remove this if you don't want to authenticate your API calls
}

resource "aws_apigatewayv2_integration" "load_balancer_integration" {
  api_id            = aws_apigatewayv2_api.http_api.id
  integration_type  = "HTTP_PROXY"
  integration_uri   = "http://${var.ecs_alb_dns_name}/search" # Use the Load Balancer's DNS name
  integration_method = "ANY"
}

# Define integrations for each Lambda
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  count             = 3
  api_id            = aws_apigatewayv2_api.http_api.id
  integration_type  = "AWS_PROXY"
  integration_uri   = var.lambda_invoke_arns[count.index]  # The ARN of the Lambda function
  integration_method = "POST"
}

# Define the stage for the API deployment
resource "aws_apigatewayv2_stage" "http_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

# Grant API Gateway permissions to invoke Lambda functions
resource "aws_lambda_permission" "allow_api_gateway" {
  count        = 3
  statement_id = "AllowAPIGatewayInvoke-${count.index}"
  action       = "lambda:InvokeFunction"
  function_name = var.lambda_names[count.index] # Dynamic Lambda names
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

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
  count           = 5 # Number of Lambda modules
  api_id          = aws_apigatewayv2_api.http_api.id
  route_key       = count.index == 0 ? "GET /${var.lambda_paths[count.index]}" : "POST /${var.lambda_paths[count.index]}" # Dynamic routes
  target          = "integrations/${aws_apigatewayv2_integration.lambda_integrations[count.index].id}"

  # Attach Cognito Authorizer only for routes where count != 0
  authorizer_id = count.index == 0 ? null : aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Define integrations for each Lambda
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  count             = 5
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
  count        = 5
  statement_id = "AllowAPIGatewayInvoke-${count.index}"
  action       = "lambda:InvokeFunction"
  function_name = var.lambda_names[count.index] # Dynamic Lambda names
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


# # Define the API Gateway
# resource "aws_api_gateway_rest_api" "api" {
#   name        = "PixploreAPI"
#   description = "API Gateway for all Lambda functions with Cognito integration"
# }

# # Define resources for each Lambda module
# resource "aws_api_gateway_resource" "lambda_resources" {
#   count       = 5 # Number of Lambda modules
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = var.lambda_paths[count.index] # Dynamic paths
# }

# # Define Cognito Authorizer
# resource "aws_api_gateway_authorizer" "cognito_authorizer" {
#   name          = "CognitoAuthorizer"
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   type          = "COGNITO_USER_POOLS"
#   provider_arns = [var.cognito_user_pool_arn]
#   identity_source = "method.request.header.Authorization"
# }

# # Define methods for each resource (Secured with Cognito)
# resource "aws_api_gateway_method" "secured_methods" {
#   count         = 4
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.lambda_resources[count.index + 1].id
#   http_method   = "POST"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
# }

# # Callback URL endpoint where no Cognito authentication is required
# resource "aws_api_gateway_method" "callback_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.lambda_resources[0].id  # Adjust index
#   http_method   = "POST"
  
#   # No authorization for this endpoint
#   authorization = "NONE"
# }

# # Define integrations for each Lambda
# resource "aws_api_gateway_integration" "lambda_integrations" {
#   count                   = 5
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method = count.index == 0 ? aws_api_gateway_method.callback_method.http_method : aws_api_gateway_method.secured_methods[count.index - 1].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = var.lambda_invoke_arns[count.index] # Dynamic Lambda ARN
# }

# # Deployment
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on  = [aws_api_gateway_integration.lambda_integrations]
#   rest_api_id = aws_api_gateway_rest_api.api.id
# }

# # Create a stage for the API deployment
# resource "aws_api_gateway_stage" "api_stage" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   stage_name    = "prod"
#   deployment_id = aws_api_gateway_deployment.api_deployment.id
# }

# # Grant API Gateway permissions to invoke Lambdas
# resource "aws_lambda_permission" "allow_api_gateway" {
#   count        = 5
#   statement_id = "AllowAPIGatewayInvoke-${count.index}"
#   action       = "lambda:InvokeFunction"
#   function_name = var.lambda_names[count.index] # Dynamic Lambda names
#   principal     = "apigateway.amazonaws.com"
# }






# Optional: Method Request Settings (Require Authorization Header)
# resource "aws_api_gateway_method_request" "method_request" {
#   count        = 5
#   rest_api_id  = aws_api_gateway_rest_api.api.id
#   resource_id  = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method  = "POST"
#   request_parameters = {
#     "method.request.header.Authorization" = true
#   }
# }



# resource "aws_api_gateway_rest_api" "api" {
#   name        = "PixploreAPI"
#   description = "API Gateway for all Lambda functions"
# }

# # Define resources for each Lambda module
# resource "aws_api_gateway_resource" "lambda_resources" {
#   count       = 4 # Number of Lambda modules
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = var.lambda_paths[count.index] # Dynamic paths
# }

# # Define methods for each resource
# resource "aws_api_gateway_method" "get_methods" {
#   count         = 4
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# # Define integrations for each Lambda
# resource "aws_api_gateway_integration" "lambda_integrations" {
#   count                   = 4
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method             = aws_api_gateway_method.get_methods[count.index].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = var.lambda_invoke_arns[count.index] # Dynamic Lambda ARN
# }

# # Deployment
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on  = [aws_api_gateway_integration.lambda_integrations]
#   rest_api_id = aws_api_gateway_rest_api.api.id
# }

# # Create a stage for the API deployment
# resource "aws_api_gateway_stage" "api_stage" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = "prod" 
#   deployment_id = aws_api_gateway_deployment.api_deployment.id
# }

# # Grant API Gateway permissions to invoke Lambdas
# resource "aws_lambda_permission" "allow_api_gateway" {
#   count        = 4
#   statement_id = "AllowAPIGatewayInvoke-${count.index}"
#   action       = "lambda:InvokeFunction"
#   function_name = var.lambda_names[count.index] # Dynamic Lambda names
#   principal     = "apigateway.amazonaws.com"
# }




# resource "aws_api_gateway_rest_api" "api" {
#   name        = "PixploreAPI"
#   description = "API Gateway for all Lambda functions"
# }

# # Define resources for each Lambda module
# resource "aws_api_gateway_resource" "lambda_resources" {
#   count       = 5 # Number of Lambda modules
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = var.lambda_paths[count.index] # Dynamic paths
# }

# # Define methods for each resource
# resource "aws_api_gateway_method" "get_methods" {
#   count         = 5
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# # Define integrations for each Lambda
# resource "aws_api_gateway_integration" "lambda_integrations" {
#   count                   = 5
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.lambda_resources[count.index].id
#   http_method             = aws_api_gateway_method.get_methods[count.index].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.lambda_arns[count.index]}/invocations"
# }

# # Deployment (this creates the 'prod' stage automatically)
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on  = [aws_api_gateway_integration.lambda_integrations]
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = "prod"
# }

# # Grant API Gateway permissions to invoke Lambdas
# resource "aws_lambda_permission" "allow_api_gateway" {
#   count        = 5
#   statement_id = "AllowAPIGatewayInvoke-${count.index}"
#   action       = "lambda:InvokeFunction"
#   function_name = var.lambda_names[count.index] # Dynamic Lambda names
#   principal     = "apigateway.amazonaws.com"
# }

# # Define local value for api gateway routes
# locals {
#   api_gateway_routes = [
#     for i in range(5) : "${aws_api_gateway_deployment.api_deployment.invoke_url}/${aws_api_gateway_resource.lambda_resources[i].path_part}"
#   ]
# }

resource "aws_api_gateway_rest_api" "api" {
  name        = "PixploreAPI"
  description = "API Gateway for all Lambda functions"
}

# Define resources for each Lambda module
resource "aws_api_gateway_resource" "lambda_resources" {
  count       = 4 # Number of Lambda modules
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.lambda_paths[count.index] # Dynamic paths
}

# Define methods for each resource
resource "aws_api_gateway_method" "get_methods" {
  count         = 4
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.lambda_resources[count.index].id
  http_method   = "POST"
  authorization = "NONE"
}

# Define integrations for each Lambda
resource "aws_api_gateway_integration" "lambda_integrations" {
  count                   = 4
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.lambda_resources[count.index].id
  http_method             = aws_api_gateway_method.get_methods[count.index].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns[count.index] # Dynamic Lambda ARN
}

# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integrations]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# Create a stage for the API deployment
resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod" 
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

# Grant API Gateway permissions to invoke Lambdas
resource "aws_lambda_permission" "allow_api_gateway" {
  count        = 4
  statement_id = "AllowAPIGatewayInvoke-${count.index}"
  action       = "lambda:InvokeFunction"
  function_name = var.lambda_names[count.index] # Dynamic Lambda names
  principal     = "apigateway.amazonaws.com"
}




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

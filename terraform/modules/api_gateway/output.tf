output "api_gateway_urls" {
  description = "List of all API Gateway routes"
  value = [
    for i in range(4) : 
    "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/prod/${var.lambda_paths[i]}"
  ]
}

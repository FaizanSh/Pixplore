variable "region" {
  default = "us-east-1"
}

variable "lambda_paths" {
  description = "Paths for each Lambda function in the API Gateway"
  default     = ["landing-page", "image-data", "upload-photo", "image-analyse", "image-massage"]
}

variable "lambda_names" {
  description = "Names for each Lambda function in the API Gateway"
}

variable "lambda_invoke_arns" {
  description = "ARNs for each Lambda function in the API Gateway"
}

variable "cognito_user_pool_client_id" {
  type = string
  description = "The Cognito User Pool Client ID"
}

variable "cognito_user_pool_issuer" {
  type = string
  description = "The Cognito User Pool Issuer URL"
}

variable "cognito_user_pool_arn" {
  type = string
  description = "The Cognito User Pool ARN"
}

variable "ecs_alb_dns_name" {
  type = string
  description = "The DNS name of the Application Load Balancer"
  
}
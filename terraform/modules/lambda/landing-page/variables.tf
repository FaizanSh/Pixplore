variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.10"
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cognito_client_id" {
  description = "Cognito App Client ID"
  type        = string
}

variable "cognito_client_secret" {
  description = "Cognito App Client Secret"
  type        = string
}

variable "cognito_token_url" {
  description = "Cognito token endpoint"
  type        = string
}

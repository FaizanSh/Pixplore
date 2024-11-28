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
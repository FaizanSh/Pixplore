variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket that triggers the Lambda function"
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}



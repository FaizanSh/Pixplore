output "lambda_execution_role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_exec_role.arn
}
# output "lambda_name" {
#   description = "Name of the Lambda function"
#   value       = aws_lambda_function.this.function_name
# }

output "lambda_name" {
  description = "The name of the Analysis Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "lambda_invoke_arn" {
  description = "The ARN of the Lambda function for invoking"
  value       = aws_lambda_function.lambda_function.arn
}

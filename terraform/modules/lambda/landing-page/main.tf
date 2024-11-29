resource "aws_iam_role" "lambda_execution_role" {
  name = "landing_page_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "landing_page_cognito_policy"
  description = "IAM policy for Cognito access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:InitiateAuth",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  runtime          = var.runtime
  handler          = var.handler
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = var.filename
  source_code_hash = var.source_code_hash

  environment {
    variables = {
      COGNITO_CLIENT_ID     = var.cognito_client_id
      COGNITO_CLIENT_SECRET = var.cognito_client_secret
      COGNITO_TOKEN_URL     = var.cognito_token_url
    }
  }
}
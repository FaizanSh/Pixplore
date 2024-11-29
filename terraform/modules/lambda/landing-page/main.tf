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

resource "aws_lb_target_group" "landing_tg" {
  name        = "image-analysis-tg"  # Name of the Target Group
  target_type = "lambda"             # Specify that the target is a Lambda function
}

resource "aws_lambda_permission" "elb_invoke_permission" {
  statement_id  = "AllowExecutionFromELB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.landing_tg.arn
}

resource "aws_lb_target_group_attachment" "landing_page_tg_attachment" {
  target_group_arn = aws_lb_target_group.landing_tg.arn
  target_id        = aws_lambda_function.this.arn

  depends_on = [aws_lambda_permission.elb_invoke_permission]
}
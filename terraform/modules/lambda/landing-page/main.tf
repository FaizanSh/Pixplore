resource "aws_iam_role" "lambda_execution_role" {
  name = "landing_page_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["lambda.amazonaws.com","elasticloadbalancing.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  name       = "lambda_execution_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  runtime          = var.runtime
  handler          = var.handler
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = var.filename
  source_code_hash = var.source_code_hash
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

resource "aws_lb_target_group_attachment" "landing_tg_attachment" {
  target_group_arn = aws_lb_target_group.landing_tg.arn
  target_id        = aws_lambda_function.this.arn
  
  # depends_on = [aws_lambda_permission.allow_elb_to_invoke_landing_page]
}
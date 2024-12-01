resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/payload/lambda_function_payload.zip"
  function_name    = var.lambda_name
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("${path.module}/payload/lambda_function_payload.zip")
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Policy to allow Lambda to send messages to SQS
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "${var.lambda_name}-sqs-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sqs:SendMessage",
        Effect = "Allow",
        Resource = "arn:aws:sqs:us-east-1:890742567343:image-processing-queue"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# EventBridge rule for S3 -> Lambda
resource "aws_cloudwatch_event_rule" "s3_to_lambda_rule" {
  name        = "${var.lambda_name}_event_rule"
  description = "EventBridge rule to route S3 events to Lambda"
  event_pattern = jsonencode({
      "source": ["aws.s3"],
      "detail-type": ["Object Created"],
      "detail": {
        "bucket": {
          "name": ["image-processing-bucket-001"]
        }
      }
    })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.s3_to_lambda_rule.name
  arn  = aws_lambda_function.lambda_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_to_lambda_rule.arn
}

output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

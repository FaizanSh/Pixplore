resource "aws_iam_role" "lambda_execution_role" {
  name = "image_queue_lambda_execution_role"

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

resource "aws_iam_policy" "s3_sqs_access_policy" {
  name = "image_queue_s3_sqs_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::Pixplore-S3-1/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = "arn:aws:sqs:${var.region}:your-account-id:${var.queue_name}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_sqs_policy_attachment" {
  name       = "image_queue_s3_sqs_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.s3_sqs_access_policy.arn
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
      IMAGE_QUEUE = var.queue_name
    }
  }
}

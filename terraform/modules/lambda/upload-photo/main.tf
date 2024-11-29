resource "aws_iam_role" "lambda_execution_role" {
  name = "upload_photo_lambda_execution_role"

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

resource "aws_iam_policy" "s3_access_policy" {
  name = "upload_photo_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.images_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "upload_photo_s3_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
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
      IMAGES_BUCKET                    = var.images_bucket
      DEFAULT_SIGNEDURL_EXPIRY_SECONDS = var.default_signedurl_expiry_seconds
    }
  }
}


resource "aws_lb_target_group" "upload_photo_tg" {
  name        = "upload-photo-tg"  # Name of the Target Group
  target_type = "lambda"             # Specify that the target is a Lambda function
}

resource "aws_lambda_permission" "elb_invoke_permission" {
  statement_id  = "AllowExecutionFromELB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.upload_photo_tg.arn
}

resource "aws_lb_target_group_attachment" "upload_photo_tg_attachment" {
  target_group_arn = aws_lb_target_group.upload_photo_tg.arn
  target_id        = aws_lambda_function.this.arn

  # depends_on = [aws_lambda_permission.allow_elb_to_invoke_upload_photo]
}

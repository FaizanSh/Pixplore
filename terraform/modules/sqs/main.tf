resource "aws_sqs_queue" "image_processing_queue" {
  name = "image-processing-queue"
}

resource "aws_sqs_queue_policy" "image_processing_queue_policy" {
  queue_url = aws_sqs_queue.image_processing_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.lambda_execution_arn
        },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.image_processing_queue.arn
      }
    ]
  })
}

output "sqs_queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.image_processing_queue.id
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.image_processing_queue.arn
}

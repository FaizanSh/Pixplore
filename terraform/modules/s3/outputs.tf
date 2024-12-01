output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}


# output "bucket_name" {
#   description = "The name of the S3 bucket"
#   value       = aws_s3_bucket.image_bucket.bucket
# }

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

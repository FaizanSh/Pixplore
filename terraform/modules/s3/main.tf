# Explicitly set the AWS provider region
provider "aws" {
  region = "us-east-1"  # Explicitly set the region
}

# Define the S3 bucket resource
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  # tags   = var.tags
  tags = {
    Name = var.bucket_name
  }
}

# S3 Bucket Notification for EventBridge
resource "aws_s3_bucket_notification" "s3_event_bridge" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}

# Optionally enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

# Configure CORS for the S3 bucket
resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = ["*"]  # Allow all headers
    allowed_methods = ["GET", "POST", "PUT"]  # Specify allowed methods
    allowed_origins = ["*"]  # Specify allowed origin
    expose_headers  = ["ETag"]  # Expose ETag header
    max_age_seconds = 3000  # Cache CORS preflight response for 3000 seconds
  }
 
}
# resource "aws_cloudfront_distribution" "cdn" {
#   origin {
#     domain_name = var.s3_bucket_domain
#     origin_id   = "S3-${var.s3_bucket_arn}"

#     s3_origin_config {
#       origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "CloudFront distribution for S3 bucket"
#   default_root_object = "index.html"

#   default_cache_behavior {
#     target_origin_id       = "S3-${var.s3_bucket_arn}"
#     viewer_protocol_policy = "redirect-to-https"

#     allowed_methods = ["GET", "HEAD", "OPTIONS"]
#     cached_methods = ["GET", "HEAD"]

#     # Define how cookies and query strings are handled
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#   }

#   price_class = "PriceClass_100"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   # Add viewer_certificate block for HTTPS
#   viewer_certificate {
#     cloudfront_default_certificate = true  # Use CloudFront's default certificate
#   }

# }



# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-${var.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object

  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Create Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for S3 bucket ${var.s3_bucket_name}"
}

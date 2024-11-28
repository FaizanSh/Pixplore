# variable "s3_bucket_domain" {
#   description = "The domain name of the S3 bucket"
#   type        = string
# }

# variable "s3_bucket_arn" {
#   description = "The ARN of the S3 bucket"
#   type        = string
# }





variable "s3_bucket_name" {
  description = "Name of the S3 bucket to connect to CloudFront"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "Default root object served by CloudFront"
  type        = string
  default     = "index.html"
}

variable "default_ttl" {
  description = "Default TTL for CloudFront caching"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for CloudFront caching"
  type        = number
  default     = 86400
}

variable "price_class" {
  description = "CloudFront price class (e.g., PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}
